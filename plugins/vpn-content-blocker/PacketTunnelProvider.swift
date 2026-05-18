import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {

    private let logger = OSLog(subsystem: "com.shield.vpn", category: "tunnel")
    private var blockedDomains: Set<String> = []
    private var dnsProxyUDPSession: NWUDPSession?
    private let upstreamDNS = "1.1.1.1" // Cloudflare DNS
    private let upstreamDNSPort: UInt16 = 53

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("Shield VPN tunnel starting", log: logger, type: .info)

        // Load blocked domains from App Group shared container
        loadBlockedDomains()

        // Configure the tunnel
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")

        // DNS settings - intercept all DNS queries
        let dnsSettings = NEDNSSettings(servers: ["127.0.0.1"])
        dnsSettings.matchDomains = [""] // Match all domains
        settings.dnsSettings = dnsSettings

        // IPv4 settings - route only DNS through the tunnel
        let ipv4 = NEIPv4Settings(addresses: ["10.0.0.1"], subnetMasks: ["255.255.255.0"])
        // Only route DNS traffic, not all traffic
        ipv4.includedRoutes = [NEIPv4Route(destinationAddress: "10.0.0.1", subnetMask: "255.255.255.255")]
        settings.ipv4Settings = ipv4

        // MTU
        settings.mtu = 1500

        setTunnelNetworkSettings(settings) { [weak self] error in
            if let error = error {
                os_log("Failed to set tunnel settings: %{public}@", log: self?.logger ?? .default, type: .error, error.localizedDescription)
                completionHandler(error)
                return
            }

            os_log("Shield VPN tunnel started successfully", log: self?.logger ?? .default, type: .info)
            self?.startDNSProxy()
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Shield VPN tunnel stopping", log: logger, type: .info)
        dnsProxyUDPSession?.cancel()
        completionHandler()
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Handle messages from the main app (e.g., updated blocklist)
        if let message = String(data: messageData, encoding: .utf8) {
            if message == "reload" {
                loadBlockedDomains()
                os_log("Blocklist reloaded: %d domains", log: logger, type: .info, blockedDomains.count)
            }
        }
        completionHandler?(nil)
    }

    // MARK: - DNS Proxy

    private func startDNSProxy() {
        // Read DNS packets from the tunnel interface
        readPackets()
    }

    private func readPackets() {
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self else { return }

            for (index, packet) in packets.enumerated() {
                self.handlePacket(packet, protocolFamily: protocols[index])
            }

            // Continue reading
            self.readPackets()
        }
    }

    private func handlePacket(_ packet: Data, protocolFamily: NSNumber) {
        // Parse the IP packet to extract DNS query
        guard packet.count > 28 else { return } // Minimum IP + UDP header

        // Check if it's a UDP packet (protocol 17) going to port 53
        let ipHeaderLength = Int(packet[0] & 0x0F) * 4
        guard packet.count > ipHeaderLength + 8 else { return }

        let protocol_num = packet[9]
        guard protocol_num == 17 else { return } // UDP only

        let destPort = UInt16(packet[ipHeaderLength + 2]) << 8 | UInt16(packet[ipHeaderLength + 3])
        guard destPort == 53 else { return }

        // Extract DNS payload
        let dnsPayload = packet.subdata(in: (ipHeaderLength + 8)..<packet.count)

        // Parse the DNS query to get the domain name
        if let domain = parseDNSQueryDomain(dnsPayload) {
            let normalizedDomain = domain.lowercased()

            // Check if domain should be blocked
            if shouldBlockDomain(normalizedDomain) {
                os_log("BLOCKED: %{public}@", log: logger, type: .info, normalizedDomain)

                // Return a DNS response pointing to 127.0.0.1 (localhost - redirects to app)
                if let blockedResponse = createBlockedDNSResponse(
                    originalPacket: packet,
                    dnsPayload: dnsPayload,
                    ipHeaderLength: ipHeaderLength
                ) {
                    packetFlow.writePackets([blockedResponse], withProtocols: [protocolFamily])
                }
                return
            }
        }

        // Forward non-blocked DNS queries to upstream DNS
        forwardDNSQuery(packet: packet, protocolFamily: protocolFamily, ipHeaderLength: ipHeaderLength, dnsPayload: dnsPayload)
    }

    // MARK: - Domain Blocking Logic

    private func shouldBlockDomain(_ domain: String) -> Bool {
        // Direct match
        if blockedDomains.contains(domain) { return true }

        // Subdomain match (e.g., "www.pornhub.com" matches "pornhub.com")
        for blocked in blockedDomains {
            if domain.hasSuffix("." + blocked) { return true }
        }

        return false
    }

    // MARK: - DNS Parsing

    private func parseDNSQueryDomain(_ data: Data) -> String? {
        guard data.count > 12 else { return nil } // DNS header is 12 bytes

        var offset = 12 // Skip DNS header
        var domainParts: [String] = []

        while offset < data.count {
            let labelLength = Int(data[offset])
            if labelLength == 0 { break }

            offset += 1
            guard offset + labelLength <= data.count else { return nil }

            let labelData = data.subdata(in: offset..<(offset + labelLength))
            if let label = String(data: labelData, encoding: .utf8) {
                domainParts.append(label)
            }
            offset += labelLength
        }

        return domainParts.isEmpty ? nil : domainParts.joined(separator: ".")
    }

    private func createBlockedDNSResponse(originalPacket: Data, dnsPayload: Data, ipHeaderLength: Int) -> Data? {
        guard dnsPayload.count >= 12 else { return nil }

        var response = Data()

        // Copy transaction ID
        response.append(dnsPayload[0])
        response.append(dnsPayload[1])

        // Flags: Standard response, no error
        response.append(0x81) // QR=1, Opcode=0, AA=0, TC=0, RD=1
        response.append(0x80) // RA=1, Z=0, RCODE=0

        // Questions: 1
        response.append(0x00)
        response.append(0x01)

        // Answers: 1
        response.append(0x00)
        response.append(0x01)

        // Authority + Additional: 0
        response.append(contentsOf: [0x00, 0x00, 0x00, 0x00])

        // Copy the question section
        var questionEnd = 12
        while questionEnd < dnsPayload.count {
            if dnsPayload[questionEnd] == 0 {
                questionEnd += 5 // null byte + QTYPE (2) + QCLASS (2)
                break
            }
            questionEnd += Int(dnsPayload[questionEnd]) + 1
        }

        if questionEnd > 12 && questionEnd <= dnsPayload.count {
            response.append(dnsPayload.subdata(in: 12..<questionEnd))
        }

        // Answer: pointer to name in question + A record pointing to 127.0.0.1 (localhost)
        response.append(0xC0) // Pointer
        response.append(0x0C) // Offset 12 (start of question name)
        response.append(contentsOf: [0x00, 0x01]) // TYPE A
        response.append(contentsOf: [0x00, 0x01]) // CLASS IN
        response.append(contentsOf: [0x00, 0x00, 0x00, 0x3C]) // TTL 60 seconds
        response.append(contentsOf: [0x00, 0x04]) // RDLENGTH 4
        response.append(contentsOf: [0x7F, 0x00, 0x00, 0x01]) // 127.0.0.1 (localhost)

        // Build the full IP+UDP packet response
        return buildResponsePacket(
            originalPacket: originalPacket,
            ipHeaderLength: ipHeaderLength,
            dnsResponse: response
        )
    }

    private func buildResponsePacket(originalPacket: Data, ipHeaderLength: Int, dnsResponse: Data) -> Data? {
        var responsePacket = Data(originalPacket)

        // Swap source and destination IP addresses
        let srcIPRange = 12..<16
        let dstIPRange = 16..<20
        let srcIP = originalPacket.subdata(in: srcIPRange)
        let dstIP = originalPacket.subdata(in: dstIPRange)
        responsePacket.replaceSubrange(srcIPRange, with: dstIP)
        responsePacket.replaceSubrange(dstIPRange, with: srcIP)

        // Swap source and destination ports
        let srcPortRange = ipHeaderLength..<(ipHeaderLength + 2)
        let dstPortRange = (ipHeaderLength + 2)..<(ipHeaderLength + 4)
        let srcPort = originalPacket.subdata(in: srcPortRange)
        let dstPort = originalPacket.subdata(in: dstPortRange)
        responsePacket.replaceSubrange(srcPortRange, with: dstPort)
        responsePacket.replaceSubrange(dstPortRange, with: srcPort)

        // Replace DNS payload
        let udpHeaderLength = 8
        let udpPayloadStart = ipHeaderLength + udpHeaderLength
        responsePacket.replaceSubrange(udpPayloadStart..<responsePacket.count, with: dnsResponse)

        // Update IP total length
        let totalLength = UInt16(ipHeaderLength + udpHeaderLength + dnsResponse.count)
        responsePacket[2] = UInt8(totalLength >> 8)
        responsePacket[3] = UInt8(totalLength & 0xFF)

        // Update UDP length
        let udpLength = UInt16(udpHeaderLength + dnsResponse.count)
        responsePacket[ipHeaderLength + 4] = UInt8(udpLength >> 8)
        responsePacket[ipHeaderLength + 5] = UInt8(udpLength & 0xFF)

        // Clear UDP checksum (optional for IPv4)
        responsePacket[ipHeaderLength + 6] = 0
        responsePacket[ipHeaderLength + 7] = 0

        // Recalculate IP header checksum
        responsePacket[10] = 0
        responsePacket[11] = 0
        var checksum: UInt32 = 0
        for i in stride(from: 0, to: ipHeaderLength, by: 2) {
            checksum += UInt32(responsePacket[i]) << 8 | UInt32(responsePacket[i + 1])
        }
        while checksum > 0xFFFF {
            checksum = (checksum & 0xFFFF) + (checksum >> 16)
        }
        let checksumResult = ~UInt16(checksum)
        responsePacket[10] = UInt8(checksumResult >> 8)
        responsePacket[11] = UInt8(checksumResult & 0xFF)

        return responsePacket
    }

    private func forwardDNSQuery(packet: Data, protocolFamily: NSNumber, ipHeaderLength: Int, dnsPayload: Data) {
        // Create UDP session to upstream DNS if needed
        let endpoint = NWHostEndpoint(hostname: upstreamDNS, port: String(upstreamDNSPort))
        let session = createUDPSession(to: endpoint, from: nil)

        session.setReadHandler({ [weak self] newPackets, error in
            guard let self = self, let responseData = newPackets?.first else { return }

            // Build response packet and write back to tunnel
            if let responsePacket = self.buildResponsePacket(
                originalPacket: packet,
                ipHeaderLength: ipHeaderLength,
                dnsResponse: responseData
            ) {
                self.packetFlow.writePackets([responsePacket], withProtocols: [protocolFamily])
            }

            session.cancel()
        }, maxDatagrams: 1)

        session.writeDatagram(dnsPayload) { error in
            if let error = error {
                os_log("DNS forward error: %{public}@", log: self.logger, type: .error, error.localizedDescription)
                session.cancel()
            }
        }
    }

    // MARK: - Blocklist Management

    private func loadBlockedDomains() {
        blockedDomains = []

        // Try to load from App Group shared container (dynamic list from app)
        if let sharedURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.shield.contentblocker"
        ) {
            let domainsURL = sharedURL.appendingPathComponent("blockedDomains.json")
            if let data = try? Data(contentsOf: domainsURL),
               let domains = try? JSONDecoder().decode([String].self, from: data) {
                blockedDomains = Set(domains.map { $0.lowercased() })
                os_log("Loaded %d domains from shared container", log: logger, type: .info, blockedDomains.count)
                return
            }
        }

        // Fall back to bundled default list
        if let url = Bundle.main.url(forResource: "blockedDomains", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let domains = try? JSONDecoder().decode([String].self, from: data) {
            blockedDomains = Set(domains.map { $0.lowercased() })
            os_log("Loaded %d domains from bundle", log: logger, type: .info, blockedDomains.count)
        }
    }
}

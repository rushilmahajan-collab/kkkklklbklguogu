import { GCDWebServer } from 'react-native-gcd-web-server';

const SCRIPTURES = [
  {
    text: 'Finally, brothers and sisters, whatever is true, whatever is noble, whatever is right, whatever is pure, whatever is lovely, whatever is admirable—if anything is excellent or praiseworthy—think about such things.',
    reference: 'Philippians 4:8'
  },
  {
    text: 'Therefore, I urge you, brothers and sisters, in view of God\'s mercy, to offer your bodies as a living sacrifice, holy and pleasing to God—this is your true and proper worship.',
    reference: 'Romans 12:1'
  },
  {
    text: 'But put on the Lord Jesus Christ, and make no provision for the flesh, to gratify its desires.',
    reference: 'Romans 13:14'
  },
  {
    text: 'Flee from sexual immorality. All other sins a person commits are outside the body, but whoever sins sexually, sins against their own body.',
    reference: '1 Corinthians 6:18'
  },
  {
    text: 'Do not be deceived: neither the sexually immoral nor idolaters nor adulterers nor men who have sex with men nor thieves nor the greedy nor drunkards nor slanderers nor swindlers will inherit the kingdom of God.',
    reference: '1 Corinthians 6:9-10'
  },
];

export class BlockPageServer {
  private static instance: BlockPageServer;
  private webServer: GCDWebServer | null = null;
  private isRunning = false;

  static getInstance(): BlockPageServer {
    if (!BlockPageServer.instance) {
      BlockPageServer.instance = new BlockPageServer();
    }
    return BlockPageServer.instance;
  }

  async start(): Promise<void> {
    if (this.isRunning) return;

    try {
      this.webServer = new GCDWebServer();

      // Serve the block page for all requests
      this.webServer.addDefaultHandler((request: any) => {
        const html = this.generateBlockPageHTML(request.path);
        return {
          statusCode: 200,
          contentType: 'text/html; charset=utf-8',
          body: html,
        };
      });

      // Start server on localhost:80
      await this.webServer.start(80, 'localhost');
      this.isRunning = true;
      console.log('Block page server started on http://127.0.0.1');
    } catch (error) {
      console.error('Failed to start block page server:', error);
    }
  }

  async stop(): Promise<void> {
    if (this.webServer && this.isRunning) {
      try {
        await this.webServer.stop();
        this.isRunning = false;
        console.log('Block page server stopped');
      } catch (error) {
        console.error('Failed to stop block page server:', error);
      }
    }
  }

  private generateBlockPageHTML(requestPath: string): string {
    const scripture = SCRIPTURES[Math.floor(Math.random() * SCRIPTURES.length)];
    const domain = this.extractDomainFromPath(requestPath);

    return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Content Blocked - Shield</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 500px;
            width: 100%;
            padding: 40px;
            text-align: center;
        }

        .shield-icon {
            font-size: 60px;
            margin-bottom: 20px;
        }

        h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 10px;
            font-weight: 700;
        }

        .domain {
            color: #666;
            font-size: 14px;
            margin-bottom: 30px;
            word-break: break-all;
            background: #f5f5f5;
            padding: 10px;
            border-radius: 8px;
            font-family: monospace;
        }

        .message {
            color: #555;
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .scripture-section {
            background: #f9f7ff;
            border-left: 4px solid #667eea;
            padding: 20px;
            margin: 30px 0;
            border-radius: 8px;
            text-align: left;
        }

        .scripture-text {
            color: #333;
            font-size: 16px;
            font-style: italic;
            line-height: 1.8;
            margin-bottom: 15px;
        }

        .scripture-reference {
            color: #667eea;
            font-weight: 600;
            font-size: 14px;
        }

        .buttons {
            display: flex;
            gap: 10px;
            margin-top: 30px;
        }

        button {
            flex: 1;
            padding: 12px 20px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .btn-secondary {
            background: #f0f0f0;
            color: #333;
        }

        .btn-secondary:hover {
            background: #e0e0e0;
        }

        .info {
            color: #999;
            font-size: 13px;
            margin-top: 20px;
        }

        @media (max-width: 480px) {
            .container {
                padding: 30px 20px;
            }

            h1 {
                font-size: 24px;
            }

            .buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="shield-icon">🛡️</div>

        <h1>Content Blocked</h1>

        <div class="domain">${domain || 'This website'}</div>

        <div class="message">
            <p>This website has been blocked to help protect your purity and digital well-being.</p>
        </div>

        <div class="scripture-section">
            <div class="scripture-text">"${scripture.text}"</div>
            <div class="scripture-reference">— ${scripture.reference}</div>
        </div>

        <div class="buttons">
            <button class="btn-primary" onclick="openApp()">Open Shield App</button>
            <button class="btn-secondary" onclick="goBack()">Go Back</button>
        </div>

        <div class="info">
            <p>For support or to modify your settings, open the Shield app.</p>
        </div>
    </div>

    <script>
        function openApp() {
            // Try to open the Shield app via deep link
            window.location = 'shield://home';
            // Fallback after 1 second (in case deep link fails)
            setTimeout(() => {
                window.location = 'shield://blocked?domain=${domain}';
            }, 1000);
        }

        function goBack() {
            if (window.history.length > 1) {
                window.history.back();
            }
        }
    </script>
</body>
</html>
    `;
  }

  private extractDomainFromPath(path: string): string {
    try {
      // Try to extract domain from Host header or path
      const url = new URL('http://' + path);
      return url.hostname;
    } catch {
      return path.split('/')[0] || 'unknown';
    }
  }
}

export default BlockPageServer;

import Link from "next/link";

const FEATURES = [
  {
    emoji: "💰",
    role: "CFO",
    title: "Chief Financial Officer",
    desc: "Analyzes your spending, tracks investments, and builds financial plans. Connects to your bank via Plaid.",
    color: "#10b981",
  },
  {
    emoji: "📅",
    role: "EA",
    title: "Executive Assistant",
    desc: "Plans your day, manages your calendar, preps you for meetings, and protects your time ruthlessly.",
    color: "#ec4899",
  },
  {
    emoji: "⚡",
    role: "CTO",
    title: "Chief Technology Officer",
    desc: "Oversees your digital life, recommends tools, automates workflows, and keeps your tech stack lean.",
    color: "#6366f1",
  },
  {
    emoji: "👑",
    role: "CEO",
    title: "Chief Executive Officer",
    desc: "Your strategic visionary. Sets direction, reviews performance, and ensures all departments align.",
    color: "#f59e0b",
  },
  {
    emoji: "⚙️",
    role: "COO",
    title: "Chief Operating Officer",
    desc: "Builds systems, optimizes habits, and ensures your daily operations run like a well-oiled machine.",
    color: "#f97316",
  },
  {
    emoji: "🧠",
    role: "CHRO",
    title: "Chief People Officer",
    desc: "Manages your wellbeing, relationships, learning, and personal growth as your most valuable asset.",
    color: "#8b5cf6",
  },
];

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[#0a0a0f] text-[#f0f0ff]">
      {/* Nav */}
      <nav className="flex items-center justify-between px-6 py-4 border-b border-[#2a2a3d] max-w-7xl mx-auto">
        <div className="flex items-center gap-2">
          <span className="text-2xl">🏢</span>
          <span className="font-bold text-xl">LifeOS</span>
        </div>
        <div className="flex items-center gap-4">
          <Link
            href="/login"
            className="text-[#8888aa] hover:text-[#f0f0ff] transition-colors text-sm"
          >
            Sign in
          </Link>
          <Link
            href="/register"
            className="bg-[#6366f1] hover:bg-[#818cf8] text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
          >
            Get Started Free
          </Link>
        </div>
      </nav>

      {/* Hero */}
      <section className="max-w-5xl mx-auto px-6 pt-24 pb-20 text-center">
        <div className="inline-flex items-center gap-2 bg-[#1a1a27] border border-[#2a2a3d] rounded-full px-4 py-1.5 text-sm text-[#8888aa] mb-8">
          <span className="w-2 h-2 rounded-full bg-[#10b981] inline-block animate-pulse"></span>
          AI-powered executive team for your life
        </div>
        <h1 className="text-5xl md:text-7xl font-bold mb-6 leading-tight">
          Run your life
          <br />
          <span className="gradient-text">like a company</span>
        </h1>
        <p className="text-xl text-[#8888aa] max-w-2xl mx-auto mb-10 leading-relaxed">
          Get your own board of directors — CFO, CTO, EA, and more — powered by AI.
          Every aspect of your life, optimized by executives who work 24/7 for you.
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link
            href="/register"
            className="bg-[#6366f1] hover:bg-[#818cf8] text-white px-8 py-4 rounded-xl text-lg font-semibold transition-colors"
          >
            Build Your Board →
          </Link>
          <Link
            href="/login"
            className="bg-[#1a1a27] hover:bg-[#2a2a3d] text-[#f0f0ff] px-8 py-4 rounded-xl text-lg font-semibold transition-colors border border-[#2a2a3d]"
          >
            Sign In
          </Link>
        </div>
      </section>

      {/* Features Grid */}
      <section className="max-w-6xl mx-auto px-6 pb-24">
        <h2 className="text-3xl font-bold text-center mb-4">Meet your executive team</h2>
        <p className="text-center text-[#8888aa] mb-12">
          Build your org chart from scratch or start with our C-suite template
        </p>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {FEATURES.map((f) => (
            <div
              key={f.role}
              className="bg-[#12121a] border border-[#2a2a3d] rounded-2xl p-6 hover:-translate-y-1 transition-transform"
            >
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center text-2xl mb-4"
                style={{ backgroundColor: f.color + "22", border: `1px solid ${f.color}44` }}
              >
                {f.emoji}
              </div>
              <div className="text-xs font-semibold mb-1" style={{ color: f.color }}>
                {f.role}
              </div>
              <h3 className="font-bold text-lg mb-2">{f.title}</h3>
              <p className="text-[#8888aa] text-sm leading-relaxed">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* CTA */}
      <section className="max-w-3xl mx-auto px-6 pb-24 text-center">
        <div className="bg-gradient-to-br from-[#6366f1]/20 to-[#a78bfa]/10 border border-[#6366f1]/30 rounded-3xl p-12">
          <h2 className="text-4xl font-bold mb-4">Your board is waiting</h2>
          <p className="text-[#8888aa] mb-8 text-lg">
            Join thousands of people treating their life like the company it is.
          </p>
          <Link
            href="/register"
            className="bg-[#6366f1] hover:bg-[#818cf8] text-white px-8 py-4 rounded-xl text-lg font-semibold transition-colors inline-block"
          >
            Start for Free
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-[#2a2a3d] py-8 text-center text-[#8888aa] text-sm">
        <p>LifeOS — Run your life like a company</p>
      </footer>
    </div>
  );
}

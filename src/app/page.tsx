import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen text-white">
      {/* Hero Section */}
      <section className="relative py-20 px-8">
        <div className="max-w-5xl mx-auto text-center">
          <h1 className="text-7xl font-black tracking-tight mb-6">
            <span className="gradient-text">QUAD</span>
            <span className="text-2xl align-super text-slate-500 ml-2">Framework</span>
          </h1>
          <p className="text-2xl font-semibold text-blue-300 mb-4">
            Quick Unified Agentic Development
          </p>
          <p className="text-xl text-slate-400 mb-8 max-w-2xl mx-auto">
            A modern software development methodology for the AI era.
            Replace Agile ceremonies with AI agents and documentation-first practices.
          </p>

          {/* Circle of Functions - Super Blocks */}
          <div className="max-w-4xl mx-auto mb-12">
            <p className="text-lg font-semibold text-slate-400 mb-6 tracking-widest uppercase">Circle of Functions</p>
            <div className="grid grid-cols-4 gap-3 mb-8">
              {/* Block 1 - Method */}
              <div className="relative group">
                <div className="absolute inset-0 bg-gradient-to-br from-blue-500 to-blue-700 rounded-2xl blur-xl opacity-30 group-hover:opacity-50 transition-opacity"></div>
                <div className="relative bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-6 border border-blue-500/30 hover:border-blue-400/50 transition-all hover:scale-105 hover:-translate-y-1">
                  <div className="text-5xl font-black bg-gradient-to-br from-blue-400 to-blue-600 bg-clip-text text-transparent mb-2">1</div>
                  <div className="text-xs font-bold text-blue-400 tracking-wider uppercase">Method</div>
                  <div className="text-sm text-white font-semibold mt-2">QUAD</div>
                </div>
              </div>
              {/* Block 2 - Dimensions */}
              <div className="relative group">
                <div className="absolute inset-0 bg-gradient-to-br from-green-500 to-emerald-700 rounded-2xl blur-xl opacity-30 group-hover:opacity-50 transition-opacity"></div>
                <div className="relative bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-6 border border-green-500/30 hover:border-green-400/50 transition-all hover:scale-105 hover:-translate-y-1">
                  <div className="text-5xl font-black bg-gradient-to-br from-green-400 to-emerald-600 bg-clip-text text-transparent mb-2">2</div>
                  <div className="text-xs font-bold text-green-400 tracking-wider uppercase">Dimensions</div>
                  <div className="text-sm text-white font-semibold mt-2">Biz + Tech</div>
                </div>
              </div>
              {/* Block 3 - Axioms */}
              <div className="relative group">
                <div className="absolute inset-0 bg-gradient-to-br from-amber-500 to-orange-700 rounded-2xl blur-xl opacity-30 group-hover:opacity-50 transition-opacity"></div>
                <div className="relative bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-6 border border-amber-500/30 hover:border-amber-400/50 transition-all hover:scale-105 hover:-translate-y-1">
                  <div className="text-5xl font-black bg-gradient-to-br from-amber-400 to-orange-600 bg-clip-text text-transparent mb-2">3</div>
                  <div className="text-xs font-bold text-amber-400 tracking-wider uppercase">Axioms</div>
                  <div className="text-sm text-white font-semibold mt-2">Core Truths</div>
                </div>
              </div>
              {/* Block 4 - Circles */}
              <div className="relative group">
                <div className="absolute inset-0 bg-gradient-to-br from-purple-500 to-violet-700 rounded-2xl blur-xl opacity-30 group-hover:opacity-50 transition-opacity"></div>
                <div className="relative bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-6 border border-purple-500/30 hover:border-purple-400/50 transition-all hover:scale-105 hover:-translate-y-1">
                  <div className="text-5xl font-black bg-gradient-to-br from-purple-400 to-violet-600 bg-clip-text text-transparent mb-2">4</div>
                  <div className="text-xs font-bold text-purple-400 tracking-wider uppercase">Circles</div>
                  <div className="text-sm text-white font-semibold mt-2">Teams</div>
                </div>
              </div>
            </div>
            <p className="text-slate-400 max-w-2xl mx-auto">
              QUAD combines four functional circles with AI agents at every step
              and a documentation-first approach. The result: faster delivery,
              consistent quality, and no knowledge silos.
            </p>
          </div>

          <div className="flex gap-4 justify-center">
            <Link
              href="/concept"
              className="px-8 py-4 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-semibold text-lg"
            >
              Read the Concept
            </Link>
            <Link
              href="/case-study"
              className="px-8 py-4 bg-white/10 text-white rounded-xl hover:bg-white/20 transition-colors border border-white/20 font-semibold text-lg"
            >
              View Case Study
            </Link>
          </div>
        </div>
      </section>

      {/* The 1-2-3-4 Hierarchy */}
      <section className="py-16 px-8 bg-slate-800/30">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold mb-8 text-center">The 1-2-3-4 Hierarchy</h2>
          <div className="grid grid-cols-4 gap-4">
            {[
              { num: "1", term: "METHOD", items: ["QUAD"], desc: "Quick Unified Agentic Development" },
              { num: "2", term: "DIMENSIONS", items: ["Business", "Technical"], desc: "The two focus axes" },
              { num: "3", term: "AXIOMS", items: ["Operators", "AI Agents", "Docs-First"], desc: "Foundational truths" },
              { num: "4", term: "CIRCLES", items: ["Management", "Development", "QA", "Infrastructure"], desc: "Functional teams" },
            ].map((item) => (
              <div key={item.num} className="glass-card rounded-xl p-6 text-center">
                <div className="text-4xl font-black text-blue-400 mb-3">{item.num}</div>
                <div className="text-sm font-bold text-white mb-3">{item.term}</div>
                <div className="space-y-1 mb-3">
                  {item.items.map((i) => (
                    <div key={i} className="text-sm text-blue-300">{i}</div>
                  ))}
                </div>
                <div className="text-xs text-slate-500">{item.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* The 4 Circles */}
      <section className="py-16 px-8">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold mb-8 text-center">The 4 Circles</h2>
          <div className="grid md:grid-cols-2 gap-6">
            {[
              {
                num: 1,
                name: "Management",
                focus: "Business 80% / Technical 20%",
                mode: "Dedicated",
                roles: ["Business Analyst", "Project Manager", "Tech Lead"],
                agents: ["Story Agent", "Scheduling Agent", "Doc Agent"],
                color: "blue",
              },
              {
                num: 2,
                name: "Development",
                focus: "Business 30% / Technical 70%",
                mode: "Mostly Dedicated",
                roles: ["Full Stack", "Backend", "UI", "Mobile"],
                agents: ["Dev Agent (UI)", "Dev Agent (API)", "Code Review"],
                color: "green",
              },
              {
                num: 3,
                name: "QA",
                focus: "Business 30% / Technical 70%",
                mode: "Mostly Shared",
                roles: ["QA Engineer", "Automation", "Performance", "Security"],
                agents: ["UI Test Agent", "API Test Agent", "Test Generator"],
                color: "yellow",
              },
              {
                num: 4,
                name: "Infrastructure",
                focus: "Business 20% / Technical 80%",
                mode: "Always Shared",
                roles: ["DevOps", "SRE", "Cloud Engineer", "DBA"],
                agents: ["Deploy Agent", "Monitoring Agent", "Incident Agent"],
                color: "purple",
              },
            ].map((circle) => (
              <div
                key={circle.num}
                className={`circle-${circle.name.toLowerCase()} rounded-xl p-6 border`}
              >
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className={`w-12 h-12 rounded-full bg-${circle.color}-500/30 flex items-center justify-center text-${circle.color}-300 font-bold text-xl`}>
                      {circle.num}
                    </div>
                    <div>
                      <h3 className="font-bold text-white text-lg">{circle.name} Circle</h3>
                      <p className="text-xs text-slate-400">{circle.focus}</p>
                    </div>
                  </div>
                  <span className={`text-xs px-3 py-1 rounded-full bg-${circle.color}-500/20 text-${circle.color}-300`}>
                    {circle.mode}
                  </span>
                </div>
                <div className="flex flex-wrap gap-2 mb-3">
                  {circle.roles.map((role) => (
                    <span key={role} className="px-2 py-1 bg-slate-600/30 text-slate-300 rounded text-xs">
                      {role}
                    </span>
                  ))}
                </div>
                <div className="text-xs text-slate-500">
                  <span className="text-slate-400">AI Agents:</span>{" "}
                  {circle.agents.join(", ")}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Key Benefits */}
      <section className="py-16 px-8 bg-slate-800/30">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold mb-8 text-center">Why QUAD?</h2>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              { icon: "90%", title: "Less Meetings", desc: "AI Scheduling Agent replaces daily standups" },
              { icon: "4x", title: "Faster Onboarding", desc: "New devs read flow docs instead of shadowing" },
              { icon: "0", title: "Knowledge Silos", desc: "Everything documented, nothing in heads" },
              { icon: "80%", title: "Less Test Writing", desc: "AI generates test cases from flow docs" },
              { icon: "1", title: "Source of Truth", desc: "Git is the source, wikis sync from Git" },
              { icon: "4wk", title: "Cycles Not Sprints", desc: "Monthly cycles with less context switching" },
            ].map((benefit) => (
              <div key={benefit.title} className="glass-card rounded-xl p-6 text-center">
                <div className="text-3xl font-black text-blue-400 mb-3">{benefit.icon}</div>
                <h3 className="font-semibold text-white mb-2">{benefit.title}</h3>
                <p className="text-sm text-slate-400">{benefit.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Quick Navigation */}
      <section className="py-16 px-8">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold mb-8 text-center">Explore QUAD</h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              {
                title: "Main Concept",
                desc: "The complete QUAD methodology - Operators, AI Agents, Docs-First approach",
                href: "/concept",
                icon: "💡",
              },
              {
                title: "Technical Details",
                desc: "Deep-dive: Agent patterns, flow docs, organizational hierarchy",
                href: "/details",
                icon: "📋",
              },
              {
                title: "Terminology",
                desc: "QUAD jargon glossary - Cycle, Pulse, Trajectory, Checkpoint",
                href: "/jargons",
                icon: "📖",
              },
              {
                title: "Executive Summary",
                desc: "High-level overview for executives and quick reference",
                href: "/summary",
                icon: "📝",
              },
              {
                title: "Case Study",
                desc: "Calculator App: Agile vs QUAD - see the dramatic difference",
                href: "/case-study",
                icon: "🧮",
              },
              {
                title: "Dashboard Demo",
                desc: "See how a QUAD implementation dashboard might look",
                href: "/demo",
                icon: "🌐",
              },
            ].map((card) => (
              <Link
                key={card.href}
                href={card.href}
                className="glass-card rounded-xl p-6 hover:bg-white/10 transition-all group"
              >
                <div className="text-3xl mb-3">{card.icon}</div>
                <h3 className="text-lg font-bold text-white mb-2 group-hover:text-blue-300 transition-colors">
                  {card.title}
                </h3>
                <p className="text-sm text-slate-400">{card.desc}</p>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-16 px-8 bg-gradient-to-r from-blue-500/10 to-purple-500/10">
        <div className="max-w-2xl mx-auto text-center">
          <h2 className="text-3xl font-bold mb-4">Ready to Transform Your Development?</h2>
          <p className="text-slate-400 mb-8">
            Start with the Main Concept for a complete understanding, or explore the Case Study to see QUAD in action.
          </p>
          <div className="flex gap-4 justify-center">
            <Link
              href="/concept"
              className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-semibold"
            >
              Read Main Concept
            </Link>
            <Link
              href="https://a2vibecreators.com"
              target="_blank"
              className="px-6 py-3 bg-white/10 text-white rounded-lg hover:bg-white/20 transition-colors border border-white/20"
            >
              About A2 Vibe Creators
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}

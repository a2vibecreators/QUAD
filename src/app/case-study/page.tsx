"use client";

import Link from "next/link";
import PageNavigation from "@/components/PageNavigation";

export default function QUADCaseStudy() {
  const sections = [
    { id: "project", title: "The Project" },
    { id: "comparison", title: "Comparison" },
  ];

  return (
    <div className="min-h-screen text-white">
      <PageNavigation sections={sections} />
      {/* Hero Section */}
      <section className="pt-8 pb-12 px-6">
        <div className="max-w-4xl mx-auto text-center">
          <div className="inline-block px-4 py-1 bg-blue-500/20 rounded-full text-blue-300 text-sm font-medium mb-4">
            Case Study
          </div>
          <h1 className="text-5xl font-bold mb-4">
            Calculator Web App
          </h1>
          <p className="text-xl text-slate-400 mb-6">
            Agile vs QUAD - A Side-by-Side Comparison
          </p>
          <p className="text-slate-300 max-w-2xl mx-auto">
            See how a simple calculator project would be built using traditional Agile/Scrum
            compared to QUAD methodology. Understand where human gates exist and where
            AI agents can run autonomously.
          </p>
        </div>
      </section>

      {/* Project Scope */}
      <section id="project" className="py-12 px-6 bg-slate-800/30">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-2xl font-bold mb-6 text-center">The Project</h2>
          <div className="bg-white/5 rounded-xl p-6 border border-white/10">
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <h3 className="font-semibold text-blue-300 mb-2">Scope</h3>
                <p className="text-slate-300 text-sm">Build a web-based calculator with basic operations (+, -, *, /)</p>
              </div>
              <div>
                <h3 className="font-semibold text-blue-300 mb-2">Features</h3>
                <ul className="text-sm text-slate-300 space-y-1">
                  <li>Basic arithmetic operations</li>
                  <li>Clear and backspace functionality</li>
                  <li>Keyboard support</li>
                  <li>Responsive design</li>
                  <li>Unit tests</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Visual Comparison */}
      <section id="comparison" className="py-16 px-6">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-4">Process Flow Comparison</h2>
          <p className="text-slate-400 text-center mb-12 max-w-2xl mx-auto">
            See the dramatic difference in human effort and time investment
          </p>

          <div className="grid md:grid-cols-2 gap-8">
            {/* Agile Flow */}
            <div className="bg-red-500/10 rounded-2xl p-6 border border-red-500/20">
              <h3 className="text-xl font-bold text-red-300 mb-6 text-center">Agile/Scrum Approach</h3>

              <div className="space-y-4">
                {[
                  { phase: "Sprint Planning", icon: "Human", time: "4 hrs", desc: "Team estimates, grooming" },
                  { phase: "Daily Standups", icon: "Human", time: "2.5 hrs", desc: "15 min x 10 days" },
                  { phase: "Development", icon: "Human", time: "40-60 hrs", desc: "Manual coding, reviews" },
                  { phase: "Testing", icon: "Human", time: "10-20 hrs", desc: "Manual QA, bug fixes" },
                  { phase: "Sprint Review", icon: "Human", time: "2 hrs", desc: "Demo, retrospective" },
                  { phase: "Deployment", icon: "Human", time: "2-4 hrs", desc: "Manual pipeline" },
                ].map((item, i) => (
                  <div key={i} className="flex items-center gap-3 bg-slate-900/30 rounded-lg p-3">
                    <div className="w-12 h-12 rounded-full bg-red-500/20 flex items-center justify-center text-xl shrink-0">
                      {item.icon === "Human" ? "👤" : "🤖"}
                    </div>
                    <div className="flex-1">
                      <div className="flex justify-between items-center">
                        <span className="font-medium text-white">{item.phase}</span>
                        <span className="text-red-300 text-sm font-mono">{item.time}</span>
                      </div>
                      <p className="text-xs text-slate-400">{item.desc}</p>
                    </div>
                  </div>
                ))}
              </div>

              <div className="mt-6 pt-4 border-t border-red-500/20 text-center">
                <div className="text-3xl font-bold text-red-400">64-88 hrs</div>
                <div className="text-sm text-slate-400">Human effort over 2 weeks</div>
              </div>
            </div>

            {/* QUAD Flow */}
            <div className="bg-green-500/10 rounded-2xl p-6 border border-green-500/20">
              <h3 className="text-xl font-bold text-green-300 mb-6 text-center">QUAD Approach</h3>

              <div className="space-y-4">
                {[
                  { phase: "Requirements", icon: "Human", time: "30 min", desc: "BA writes brief, reviews AI output" },
                  { phase: "Story Agent", icon: "AI", time: "5 min", desc: "Auto-generates detailed stories" },
                  { phase: "Dev Agents", icon: "AI", time: "15 min", desc: "Scaffolds UI + API code" },
                  { phase: "Code Review", icon: "Human", time: "2-3 hrs", desc: "Developer reviews AI code" },
                  { phase: "Test Agents", icon: "AI", time: "9 min", desc: "Generates & runs all tests" },
                  { phase: "QA + Deploy", icon: "Mixed", time: "1 hr", desc: "Human QA, auto deploy" },
                ].map((item, i) => (
                  <div key={i} className="flex items-center gap-3 bg-slate-900/30 rounded-lg p-3">
                    <div className={`w-12 h-12 rounded-full flex items-center justify-center text-xl shrink-0 ${
                      item.icon === "Human" ? "bg-blue-500/20" :
                      item.icon === "AI" ? "bg-green-500/20" : "bg-purple-500/20"
                    }`}>
                      {item.icon === "Human" ? "👤" : item.icon === "AI" ? "🤖" : "🔄"}
                    </div>
                    <div className="flex-1">
                      <div className="flex justify-between items-center">
                        <span className="font-medium text-white">{item.phase}</span>
                        <span className="text-green-300 text-sm font-mono">{item.time}</span>
                      </div>
                      <p className="text-xs text-slate-400">{item.desc}</p>
                    </div>
                  </div>
                ))}
              </div>

              <div className="mt-6 pt-4 border-t border-green-500/20 text-center">
                <div className="text-3xl font-bold text-green-400">5-6 hrs</div>
                <div className="text-sm text-slate-400">Human effort over 2-3 days</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Comparison */}
      <section className="py-12 px-6 bg-slate-800/50">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-2xl font-bold text-center mb-8">Summary Comparison</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { metric: "Human Hours", agile: "64-88", quad: "5-6", improvement: "92%" },
              { metric: "Meeting Time", agile: "12-16 hrs", quad: "1.5 hrs", improvement: "90%" },
              { metric: "Duration", agile: "2 weeks", quad: "2-3 days", improvement: "85%" },
              { metric: "AI Automation", agile: "0%", quad: "~90%", improvement: "Max" },
            ].map((stat) => (
              <div key={stat.metric} className="bg-white/5 rounded-xl p-4 border border-white/10 text-center">
                <div className="text-xs text-slate-400 mb-2">{stat.metric}</div>
                <div className="text-sm text-red-400 line-through mb-1">Agile: {stat.agile}</div>
                <div className="text-lg font-bold text-green-400">QUAD: {stat.quad}</div>
                <div className="text-xs text-blue-300 mt-1">{stat.improvement} better</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Human Gates */}
      <section className="py-16 px-6">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-4">Human Gates in QUAD</h2>
          <p className="text-slate-400 text-center mb-12 max-w-2xl mx-auto">
            These are non-negotiable human approval points. AI assists, humans decide.
          </p>

          <div className="grid md:grid-cols-2 gap-6">
            {[
              {
                gate: "Gate 1: Requirements Approval",
                who: "Business Analyst / Product Owner",
                when: "After Story Agent generates detailed stories",
                what: "Review acceptance criteria, edge cases, estimates",
                time: "30 minutes",
                icon: "📋"
              },
              {
                gate: "Gate 2: Code Review",
                who: "Developer / Tech Lead",
                when: "After Dev Agent generates code",
                what: "Review logic, patterns, security, quality",
                time: "2-3 hours",
                icon: "💻"
              },
              {
                gate: "Gate 3: QA Sign-off",
                who: "QA Engineer",
                when: "After Test Agents complete automation",
                what: "Review results, exploratory testing",
                time: "1 hour",
                icon: "✅"
              },
              {
                gate: "Gate 4: Production Approval",
                who: "Tech Lead / Director",
                when: "Before Deploy Agent pushes to production",
                what: "Final sign-off, risk assessment, rollback plan",
                time: "15-30 minutes",
                icon: "🚀"
              },
            ].map((item) => (
              <div key={item.gate} className="bg-blue-500/10 rounded-xl p-5 border border-blue-500/20">
                <div className="flex items-center gap-3 mb-3">
                  <span className="text-2xl">{item.icon}</span>
                  <h3 className="font-bold text-blue-300">{item.gate}</h3>
                </div>
                <div className="space-y-2 text-sm">
                  <div><span className="text-slate-400">Who:</span> <span className="text-white">{item.who}</span></div>
                  <div><span className="text-slate-400">When:</span> <span className="text-white">{item.when}</span></div>
                  <div><span className="text-slate-400">What:</span> <span className="text-white">{item.what}</span></div>
                  <div><span className="text-slate-400">Time:</span> <span className="text-green-300 font-mono">{item.time}</span></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* AI Autonomous Zones */}
      <section className="py-16 px-6 bg-slate-800/50">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-4">AI Autonomous Zones</h2>
          <p className="text-slate-400 text-center mb-12 max-w-2xl mx-auto">
            These tasks run without human intervention - fully automated by AI agents
          </p>

          <div className="space-y-4">
            {[
              {
                zone: "Zone 1: Story Expansion",
                agent: "Story Agent",
                input: "Brief requirement from BA",
                output: "Detailed user stories with acceptance criteria",
                trigger: "Immediately on input"
              },
              {
                zone: "Zone 2: Code Generation",
                agent: "Dev Agent (UI + API)",
                input: "Approved user stories",
                output: "Scaffolded code, components, services",
                trigger: "On story approval"
              },
              {
                zone: "Zone 3: Test Generation & Execution",
                agent: "Test Generator + UI Test + API Test",
                input: "Code and flow documentation",
                output: "Test cases, execution results, coverage report",
                trigger: "On code push"
              },
              {
                zone: "Zone 4: DEV/QA Deployment",
                agent: "Deploy Agent",
                input: "Code merge + tests passing",
                output: "Deployed to DEV/QA environment",
                trigger: "On merge (PROD needs approval)"
              },
              {
                zone: "Zone 5: Documentation Generation",
                agent: "Documentation Agent",
                input: "Code changes, API endpoints",
                output: "Updated flow docs, API docs, changelog",
                trigger: "On deployment"
              },
            ].map((item, i) => (
              <div key={item.zone} className="bg-green-500/10 rounded-xl p-5 border border-green-500/20">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center text-green-300 font-bold text-sm">
                    {i + 1}
                  </div>
                  <h3 className="font-bold text-green-300">{item.zone}</h3>
                  <span className="ml-auto px-3 py-1 bg-green-500/20 rounded-full text-xs text-green-300">AUTO</span>
                </div>
                <div className="grid md:grid-cols-4 gap-4 text-sm">
                  <div>
                    <span className="text-slate-500 block text-xs mb-1">Agent</span>
                    <span className="text-white">{item.agent}</span>
                  </div>
                  <div>
                    <span className="text-slate-500 block text-xs mb-1">Input</span>
                    <span className="text-slate-300">{item.input}</span>
                  </div>
                  <div>
                    <span className="text-slate-500 block text-xs mb-1">Output</span>
                    <span className="text-slate-300">{item.output}</span>
                  </div>
                  <div>
                    <span className="text-slate-500 block text-xs mb-1">Trigger</span>
                    <span className="text-blue-300">{item.trigger}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Key Takeaways */}
      <section className="py-16 px-6">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-8">Key Takeaways</h2>

          <div className="grid md:grid-cols-2 gap-6">
            {[
              {
                title: "Simple Projects = Big Wins",
                desc: "Even a 'simple' calculator has ~50 test cases. AI generates them in seconds vs hours manually.",
                icon: "🎯"
              },
              {
                title: "Human Brains for Human Decisions",
                desc: "Is the UX intuitive? Is the code secure? Is it production-ready? These need human judgment.",
                icon: "🧠"
              },
              {
                title: "AI for Repetitive Work",
                desc: "Scaffolding, test cases, deployments, documentation - let AI handle the repetitive tasks.",
                icon: "🤖"
              },
              {
                title: "Documentation = Test Cases",
                desc: "Flow docs auto-generate test checklists. QA never asks 'what should I test?'",
                icon: "📚"
              },
            ].map((item) => (
              <div key={item.title} className="bg-white/5 rounded-xl p-6 border border-white/10">
                <div className="text-3xl mb-3">{item.icon}</div>
                <h3 className="font-bold text-white mb-2">{item.title}</h3>
                <p className="text-sm text-slate-400">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Get Started */}
      <section className="py-16 px-6 bg-slate-800/50">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl font-bold mb-4">Apply This to Your Project</h2>
          <p className="text-slate-400 mb-8">Start small, add agents gradually</p>

          <div className="grid grid-cols-4 gap-4 mb-8">
            {[
              { week: "Week 1-2", action: "Story Agent", focus: "AI-enhanced requirements" },
              { week: "Week 3-4", action: "+ Dev Agent", focus: "AI code scaffolding" },
              { week: "Week 5-6", action: "+ Test Agents", focus: "Automated testing" },
              { week: "Week 7+", action: "Full Pipeline", focus: "End-to-end automation" },
            ].map((phase) => (
              <div key={phase.week} className="bg-white/5 rounded-lg p-4 border border-white/10">
                <div className="text-xs text-slate-500">{phase.week}</div>
                <div className="text-blue-300 font-semibold">{phase.action}</div>
                <div className="text-xs text-slate-400 mt-1">{phase.focus}</div>
              </div>
            ))}
          </div>

          <div className="flex gap-4 justify-center">
            <Link href="/" className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-semibold">
              Learn QUAD Methodology
            </Link>
            <Link href="/demo" className="px-6 py-3 bg-white/10 text-white rounded-lg hover:bg-white/20 transition-colors font-semibold border border-white/30">
              Try QUAD Dashboard
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}

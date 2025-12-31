"use client";

import PageNavigation from "@/components/PageNavigation";
import TermWithLens from "@/components/TermWithLens";

export default function QUADConcept() {
  const sections = [
    { id: "hierarchy", title: "1-2-3-4 Hierarchy" },
    { id: "what-is", title: "What is QUAD" },
    { id: "axioms", title: "3 Axioms" },
    { id: "circles", title: "4 Circles" },
    { id: "pipeline", title: "Agent Pipeline" },
    { id: "docs-first", title: "Docs-First" },
    { id: "cycle", title: "QUAD Cycle" },
  ];

  return (
    <div className="min-h-screen text-white">
      <PageNavigation sections={sections} />
      <div className="max-w-4xl mx-auto p-8">
        {/* Header */}
        <div className="mb-12">
          <div className="flex items-center gap-3 mb-4">
            <span className="text-3xl">💡</span>
            <h1 className="text-4xl font-bold">Main Concept</h1>
          </div>
          <p className="text-slate-400">
            QUAD - Circle of Functions: The complete methodology
          </p>
        </div>

        {/* The 1-2-3-4 Hierarchy */}
        <section id="hierarchy" className="mb-12 scroll-mt-32">
          <h2 className="text-2xl font-bold mb-6 text-blue-300">The 1-2-3-4 Hierarchy</h2>
          <div className="bg-gradient-to-r from-blue-500/10 to-purple-500/10 rounded-xl p-6 border border-blue-500/20 mb-6">
            <div className="grid grid-cols-4 gap-4 text-center">
              {[
                { num: "1", term: "METHOD", items: ["QUAD"], desc: "Quick Unified Agentic Development" },
                { num: "2", term: "DIMENSIONS", items: ["Business", "Technical"], desc: "The two focus axes (B/T ratios)" },
                { num: "3", term: "AXIOMS", items: ["Operators", "AI Agents", "Docs-First"], desc: "Foundational truths" },
                { num: "4", term: "CIRCLES", items: ["Management", "Development", "QA", "Infrastructure"], desc: "Functional teams" },
              ].map((item) => (
                <div key={item.num} className="bg-slate-800/50 rounded-xl p-4 border border-slate-700">
                  <div className="text-3xl font-black text-blue-400 mb-2">{item.num}</div>
                  <div className="text-sm font-bold text-white mb-2">{item.term}</div>
                  <div className="space-y-1 mb-2">
                    {item.items.map((i) => (
                      <div key={i} className="text-xs text-blue-300">{i}</div>
                    ))}
                  </div>
                  <div className="text-xs text-slate-500">{item.desc}</div>
                </div>
              ))}
            </div>
            <p className="text-center text-sm text-slate-400 mt-4">
              Each circle = a <strong className="text-white">function</strong> with dedicated people who perform that function
            </p>
          </div>
        </section>

        {/* What is QUAD */}
        <section id="what-is" className="mb-12 scroll-mt-32">
          <h2 className="text-2xl font-bold mb-6 text-blue-300">What is QUAD?</h2>
          <div className="bg-white/5 rounded-xl p-6 border border-white/10 mb-6">
            <div className="grid grid-cols-4 gap-4 text-center mb-6">
              {[
                { letter: "Q", word: "Quick", desc: "Fast iterations, AI-powered" },
                { letter: "U", word: "Unified", desc: "4 circles working together" },
                { letter: "A", word: "Agentic", desc: "AI agents at every step" },
                { letter: "D", word: "Development", desc: "Building software, not processes" },
              ].map((item) => (
                <div key={item.letter} className="p-4">
                  <div className="text-4xl font-black text-blue-400 mb-1">{item.letter}</div>
                  <div className="text-lg font-semibold text-white">{item.word}</div>
                  <div className="text-xs text-slate-400 mt-1">{item.desc}</div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* The 3 Axioms */}
        <section id="axioms" className="mb-12 scroll-mt-32">
          <h2 className="text-2xl font-bold mb-6 text-blue-300">The 3 Axioms</h2>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              {
                num: 1,
                title: "Operators",
                desc: "Human specialists who execute circle functions. Each circle has dedicated people (BA, PM, Dev, QA, DevOps) who apply their expertise to transform inputs into outputs.",
                color: "blue",
              },
              {
                num: 2,
                title: "AI Agents",
                desc: "Every circle has AI agents that handle repetitive tasks: Story expansion, code scaffolding, test generation, deployment automation.",
                color: "green",
              },
              {
                num: 3,
                title: "Docs-First",
                desc: "Documentation is written BEFORE code. Flow documents define UI, API, DB, and test cases. QA never asks 'what should I test?'",
                color: "purple",
              },
            ].map((axiom) => (
              <div
                key={axiom.num}
                className={`bg-${axiom.color}-500/10 rounded-xl p-6 border border-${axiom.color}-500/20`}
              >
                <div className={`w-10 h-10 rounded-full bg-${axiom.color}-500/20 flex items-center justify-center text-${axiom.color}-300 font-bold mb-4`}>
                  {axiom.num}
                </div>
                <h3 className="text-xl font-bold text-white mb-2">{axiom.title}</h3>
                <p className="text-sm text-slate-400">{axiom.desc}</p>
              </div>
            ))}
          </div>
        </section>

        {/* The 4 Circles Detail */}
        <section id="circles" className="mb-12 scroll-mt-32">
          <h2 className="text-2xl font-bold mb-6 text-blue-300">The 4 Circles in Detail</h2>

          {[
            {
              name: "Management",
              circleNum: 1,
              focus: "Business 80% / Technical 20%",
              resourceMode: "Dedicated",
              resourceDesc: "per project",
              roles: ["Business Analyst", "Project Manager", "Tech Lead"],
              agents: [
                { name: "Story Agent", trigger: "BA writes requirement", output: "Enhanced story with specs, acceptance criteria" },
                { name: "Scheduling Agent", trigger: "Meeting needed", output: "Optimal time, calendar blocks, action items" },
                { name: "Documentation Agent", trigger: "Feature complete", output: "Auto-generated flow docs, wiki updates" },
                { name: "Estimation Agent", trigger: "Story ready", output: "Multi-agent pipeline: complexity, confidence, effort" },
              ],
              color: "blue",
            },
            {
              name: "Development",
              circleNum: 2,
              focus: "Business 30% / Technical 70%",
              resourceMode: "Mostly Dedicated",
              resourceDesc: "can be shared across small projects",
              roles: ["Full Stack Developer", "Backend Developer", "UI Developer", "Mobile Developer"],
              agents: [
                { name: "Dev Agent (UI)", trigger: "Story assigned", output: "Scaffolded UI components, platform-specific code" },
                { name: "Dev Agent (API)", trigger: "Story assigned", output: "Controllers, services, DTOs, entities" },
                { name: "Code Review Agent", trigger: "PR created", output: "Pre-review for patterns, security, style" },
                { name: "Refactor Agent", trigger: "Code smell detected", output: "Improvement suggestions, deduplication" },
              ],
              color: "green",
            },
            {
              name: "QA",
              circleNum: 3,
              focus: "Business 30% / Technical 70%",
              resourceMode: "Mostly Shared",
              resourceDesc: "across projects within a director",
              roles: ["QA Engineer", "Automation Engineer", "Performance Tester", "Security Tester"],
              agents: [
                { name: "UI Test Agent", trigger: "DEV deployed", output: "Playwright/XCTest automation runs" },
                { name: "API Test Agent", trigger: "DEV deployed", output: "REST API test suite execution" },
                { name: "Performance Agent", trigger: "QA deployed", output: "Load tests, bottleneck identification" },
                { name: "Test Generator", trigger: "New code pushed", output: "Test cases from code and flow docs" },
              ],
              color: "yellow",
            },
            {
              name: "Infrastructure",
              circleNum: 4,
              focus: "Business 20% / Technical 80%",
              resourceMode: "Always Shared",
              resourceDesc: "across all directors",
              roles: ["DevOps Engineer", "SRE", "Cloud Engineer", "DBA"],
              agents: [
                { name: "Deploy Agent (DEV)", trigger: "PR merged to develop", output: "Build and deploy to DEV" },
                { name: "Deploy Agent (QA)", trigger: "Tests pass + PR approved", output: "Deploy to QA environment" },
                { name: "Deploy Agent (PROD)", trigger: "QA approved", output: "Deploy to production with rollback" },
                { name: "Monitoring Agent", trigger: "Always running", output: "Log watching, alerts on anomalies" },
              ],
              color: "purple",
            },
          ].map((circle, idx) => (
            <div key={circle.name} className="mb-8 bg-slate-700/30 rounded-xl p-6 border border-slate-600/50">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-full bg-${circle.color}-500/20 flex items-center justify-center text-${circle.color}-300 text-xl font-bold`}>
                    {idx + 1}
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-white">
                      <TermWithLens term={`Circle ${circle.circleNum}`}>{circle.name}</TermWithLens> Circle
                    </h3>
                    <p className="text-sm text-slate-400">{circle.focus}</p>
                  </div>
                </div>
                <div className={`px-3 py-1 rounded-full text-xs font-medium bg-${circle.color}-500/20 text-${circle.color}-300 border border-${circle.color}-500/30`}>
                  {circle.resourceMode}
                  <span className="text-slate-500 ml-1">({circle.resourceDesc})</span>
                </div>
              </div>

              <div className="mb-4">
                <div className="text-xs text-slate-500 mb-2">ROLES</div>
                <div className="flex flex-wrap gap-2">
                  {circle.roles.map((role) => (
                    <span key={role} className="px-3 py-1 bg-slate-600/30 text-slate-300 rounded-full text-sm">
                      {role}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <div className="text-xs text-slate-500 mb-2">AI AGENTS</div>
                <div className="grid md:grid-cols-2 gap-3">
                  {circle.agents.map((agent) => (
                    <div key={agent.name} className="bg-green-500/10 rounded-lg p-3 border border-green-500/20">
                      <div className="font-semibold text-green-300 text-sm mb-1">{agent.name}</div>
                      <div className="text-xs text-slate-500">Trigger: {agent.trigger}</div>
                      <div className="text-xs text-slate-400">Output: {agent.output}</div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </section>

        {/* AI Agent Pipeline */}
        <section id="pipeline" className="mb-12 scroll-mt-32">
          <h2 className="text-2xl font-bold mb-6 text-blue-300">AI Agent Pipeline</h2>
          <div className="bg-slate-800/50 rounded-xl p-6 border border-slate-700">
            <div className="flex items-center justify-between overflow-x-auto pb-4">
              {[
                { name: "Story Agent", icon: "📝", output: "Horizon" },
                { name: "Dev Agent", icon: "💻", output: "Code Push" },
                { name: "Deploy (DEV)", icon: "🚀", output: "DEV Ready" },
                { name: "Test Agents", icon: "🧪", output: "Tests Pass" },
                { name: "PR Agent", icon: "📋", output: "PR Created" },
                { name: "Deploy (QA)", icon: "✅", output: "QA Ready" },
                { name: "Deploy (PROD)", icon: "🎯", output: "Production" },
              ].map((step, i) => (
                <div key={step.name} className="flex items-center">
                  <div className="text-center min-w-[100px]">
                    <div className="w-12 h-12 mx-auto rounded-full bg-blue-500/20 flex items-center justify-center text-2xl mb-2">
                      {step.icon}
                    </div>
                    <div className="text-xs font-medium text-white">{step.name}</div>
                    <div className="text-xs text-slate-500">{step.output}</div>
                  </div>
                  {i < 6 && (
                    <div className="text-slate-600 mx-2">→</div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Docs-First */}
        <section id="docs-first" className="mb-12 scroll-mt-32">
          <h2 className="text-2xl font-bold mb-6 text-blue-300">Docs-First Approach</h2>
          <div className="grid md:grid-cols-2 gap-6">
            <div className="bg-red-500/10 rounded-xl p-6 border border-red-500/20">
              <h3 className="font-bold text-red-300 mb-4">Traditional (Code-First)</h3>
              <ol className="space-y-2 text-sm text-slate-400">
                <li>1. Developer writes code</li>
                <li>2. Code gets reviewed</li>
                <li>3. QA asks "what should I test?"</li>
                <li>4. Documentation written after (or never)</li>
                <li>5. New team member: "where is X?"</li>
              </ol>
            </div>
            <div className="bg-green-500/10 rounded-xl p-6 border border-green-500/20">
              <h3 className="font-bold text-green-300 mb-4">QUAD (Docs-First)</h3>
              <ol className="space-y-2 text-sm text-slate-400">
                <li>1. Flow document written first</li>
                <li>2. Test cases auto-generated from flow</li>
                <li>3. Developer implements from flow</li>
                <li>4. QA knows exactly what to test</li>
                <li>5. New team member: reads flow docs</li>
              </ol>
            </div>
          </div>
        </section>

        {/* The QUAD Cycle */}
        <section id="cycle" className="mb-12 scroll-mt-32">
          <h2 className="text-2xl font-bold mb-6 text-blue-300">
            The QUAD <TermWithLens term="Cycle">Cycle</TermWithLens> (4 Weeks)
          </h2>
          <div className="grid grid-cols-4 gap-4">
            {[
              { week: 1, focus: "Trajectory", desc: "Set priorities, expand stories, start development", color: "blue" },
              { week: 2, focus: "Flow", desc: "Development continues, testing begins, agents running", color: "green" },
              { week: 3, focus: "Flow", desc: "Features completing, QA in full swing, PRs merging", color: "green" },
              { week: 4, focus: "Checkpoint", desc: "Demo, release decision, calibration (retro)", color: "purple" },
            ].map((w) => (
              <div key={w.week} className={`bg-${w.color}-500/10 rounded-xl p-4 border border-${w.color}-500/20 text-center`}>
                <div className="text-2xl font-bold text-white mb-1">Week {w.week}</div>
                <div className={`text-sm font-semibold text-${w.color}-300 mb-2`}>
                  <TermWithLens term={w.focus}>{w.focus}</TermWithLens>
                </div>
                <p className="text-xs text-slate-400">{w.desc}</p>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}

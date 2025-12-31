"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import Breadcrumb from "./Breadcrumb";

// Define all pages in order for prev/next navigation
const pages = [
  { href: "/", title: "QUAD Home", icon: "◇", short: "QUAD", section: "brand" },
  { href: "/discovery", title: "Discovery Assessment", icon: "🔍", short: "Discovery", section: "explore" },
  { href: "/pitch", title: "Value Proposition", icon: "💰", short: "Pitch", section: "explore" },
  { href: "/flow", title: "Source of Truth Flow", icon: "🔄", short: "Flow", section: "explore" },
  { href: "/concept", title: "Main Concept", icon: "💡", short: "Concept", section: "explore" },
  { href: "/architecture", title: "Agent Architecture", icon: "🏗️", short: "Arch", section: "explore" },
  { href: "/details", title: "Technical Details", icon: "📋", short: "Details", section: "explore" },
  { href: "/jargons", title: "Terminology", icon: "📖", short: "Terms", section: "explore" },
  { href: "/summary", title: "Executive Summary", icon: "📝", short: "Summary", section: "explore" },
  { href: "/case-study", title: "Case Study", icon: "🧮", short: "Case", section: "try" },
  { href: "/demo", title: "Dashboard Demo", icon: "🌐", short: "Demo", section: "try" },
  { href: "/configure", title: "Configure QUAD", icon: "⚙️", short: "Config", section: "try" },
  { href: "/platform", title: "QUAD Platform", icon: "🏢", short: "Platform", section: "try" },
  { href: "/quiz", title: "QUAD Quiz", icon: "🎯", short: "Quiz", section: "try" },
  { href: "/cheatsheet", title: "Cheat Sheet", icon: "📄", short: "Cheat", section: "resources" },
  { href: "/onboarding", title: "Onboarding Requirements", icon: "🎯", short: "Onboard", section: "resources" },
  { href: "/docs", title: "Documentation", icon: "📚", short: "Docs", section: "resources" },
  { href: "/mm-pitch", title: "Enterprise Pitch", icon: "🏢", short: "MM Pitch", section: "resources" },
];

// Group pages by section
const explorePages = pages.filter(p => p.section === "explore");
const tryPages = pages.filter(p => p.section === "try");
const resourcePages = pages.filter(p => p.section === "resources");

// Flow definitions
const flows = [
  { id: "explore", name: "EXPLORE", color: "blue", pages: explorePages },
  { id: "try", name: "TRY", color: "green", pages: tryPages },
  { id: "resources", name: "RESOURCES", color: "purple", pages: resourcePages },
];

// Helper to get flow info for a page
function getFlowInfo(pathname: string) {
  for (const flow of flows) {
    const pageIndex = flow.pages.findIndex(p => p.href === pathname);
    if (pageIndex !== -1) {
      return {
        flow,
        pageIndex,
        totalPages: flow.pages.length,
        prevInFlow: pageIndex > 0 ? flow.pages[pageIndex - 1] : null,
        nextInFlow: pageIndex < flow.pages.length - 1 ? flow.pages[pageIndex + 1] : null,
        isFirstInFlow: pageIndex === 0,
        isLastInFlow: pageIndex === flow.pages.length - 1,
      };
    }
  }
  return null;
}

// Get next flow after current
function getNextFlow(currentFlowId: string) {
  const currentIndex = flows.findIndex(f => f.id === currentFlowId);
  if (currentIndex < flows.length - 1) {
    return flows[currentIndex + 1];
  }
  return null;
}

// Get previous flow before current
function getPrevFlow(currentFlowId: string) {
  const currentIndex = flows.findIndex(f => f.id === currentFlowId);
  if (currentIndex > 0) {
    return flows[currentIndex - 1];
  }
  return null;
}

interface PageNavigationProps {
  sections?: { id: string; title: string }[];
}

export default function PageNavigation({ sections }: PageNavigationProps) {
  const pathname = usePathname();
  const currentIndex = pages.findIndex((p) => p.href === pathname);
  const currentPage = pages[currentIndex];
  const [menuOpen, setMenuOpen] = useState(false);
  const [activeSection, setActiveSection] = useState<string | null>(sections?.[0]?.id || null);

  // Get flow-based navigation info
  const flowInfo = getFlowInfo(pathname);
  const nextFlow = flowInfo ? getNextFlow(flowInfo.flow.id) : null;
  const prevFlow = flowInfo ? getPrevFlow(flowInfo.flow.id) : null;

  // Track active section using Intersection Observer
  useEffect(() => {
    if (!sections || sections.length === 0) return;

    const observers: IntersectionObserver[] = [];
    const sectionElements: { id: string; element: HTMLElement }[] = [];

    sections.forEach((section) => {
      const element = document.getElementById(section.id);
      if (element) {
        sectionElements.push({ id: section.id, element });
      }
    });

    // Create observer for each section
    sectionElements.forEach(({ id, element }) => {
      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              setActiveSection(id);
            }
          });
        },
        {
          rootMargin: "-100px 0px -60% 0px", // Trigger when section is near top
          threshold: 0,
        }
      );
      observer.observe(element);
      observers.push(observer);
    });

    return () => {
      observers.forEach((observer) => observer.disconnect());
    };
  }, [sections]);

  const scrollToSection = (id: string) => {
    setActiveSection(id);
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  // Color classes for each flow
  const flowColors: Record<string, { bg: string; text: string; border: string; activeBg: string }> = {
    blue: { bg: "bg-blue-500/10", text: "text-blue-400", border: "border-blue-500/30", activeBg: "bg-blue-500/20" },
    green: { bg: "bg-green-500/10", text: "text-green-400", border: "border-green-500/30", activeBg: "bg-green-500/20" },
    purple: { bg: "bg-purple-500/10", text: "text-purple-400", border: "border-purple-500/30", activeBg: "bg-purple-500/20" },
  };

  const handleFlowClick = (flowId: string) => {
    setMenuOpen(true);
    // Optional: scroll to that flow section in the menu
  };

  return (
    <>
      {/* Breadcrumb Navigation */}
      <Breadcrumb onFlowClick={handleFlowClick} />

      {/* Top Navigation Bar - Flow-Based */}
      <div className="sticky top-0 z-50 bg-slate-900/95 backdrop-blur-sm border-b border-slate-700/50">
        {/* Main Nav Row */}
        <div className="max-w-7xl mx-auto px-4 py-2">
          <div className="flex items-center justify-between">
            {/* Left: Home Button */}
            <Link
              href="/"
              className={`flex items-center gap-2 px-3 py-2 rounded-lg transition-all font-bold ${
                pathname === "/"
                  ? "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                  : "bg-slate-800/50 text-white hover:bg-slate-700/50 border border-slate-700"
              }`}
            >
              <span className="text-xl font-bold text-blue-400">◇</span>
              <span className="text-sm font-bold hidden sm:inline">Home</span>
            </Link>

            {/* Center: Flow Navigation */}
            {pathname !== "/" && flowInfo && (
              <div className="flex items-center gap-1">
                {flows.map((flow) => {
                  const isActive = flowInfo.flow.id === flow.id;
                  const colors = flowColors[flow.color];
                  const indexInFlow = isActive ? flowInfo.pageIndex + 1 : 0;

                  return (
                    <div key={flow.id} className="flex items-center">
                      {isActive ? (
                        // Active flow with prev/next arrows
                        <div className={`flex items-center gap-1 px-2 py-1 rounded-lg ${colors.activeBg} border ${colors.border}`}>
                          {/* Prev in flow */}
                          {flowInfo.prevInFlow ? (
                            <Link
                              href={flowInfo.prevInFlow.href}
                              className={`p-1 rounded hover:bg-white/10 ${colors.text}`}
                              title={`Previous: ${flowInfo.prevInFlow.title}`}
                            >
                              ←
                            </Link>
                          ) : prevFlow ? (
                            <Link
                              href={prevFlow.pages[prevFlow.pages.length - 1].href}
                              className="p-1 rounded hover:bg-white/10 text-slate-500"
                              title={`Back to ${prevFlow.name}`}
                            >
                              ←
                            </Link>
                          ) : (
                            <span className="p-1 text-slate-600">←</span>
                          )}

                          {/* Flow name + progress */}
                          <span className={`text-xs font-bold ${colors.text} px-1`}>
                            {flow.name}
                          </span>
                          <span className="text-[10px] text-slate-400">
                            {indexInFlow}/{flow.pages.length}
                          </span>

                          {/* Next in flow */}
                          {flowInfo.nextInFlow ? (
                            <Link
                              href={flowInfo.nextInFlow.href}
                              className={`p-1 rounded hover:bg-white/10 ${colors.text}`}
                              title={`Next: ${flowInfo.nextInFlow.title}`}
                            >
                              →
                            </Link>
                          ) : nextFlow ? (
                            <Link
                              href={nextFlow.pages[0].href}
                              className={`p-1 rounded hover:bg-white/10 ${flowColors[nextFlow.color].text}`}
                              title={`Continue to ${nextFlow.name}`}
                            >
                              →
                            </Link>
                          ) : (
                            <Link
                              href="/"
                              className="p-1 rounded hover:bg-white/10 text-green-400"
                              title="Complete! Back to Home"
                            >
                              ✓
                            </Link>
                          )}
                        </div>
                      ) : (
                        // Inactive flow - clickable to jump to first page
                        <Link
                          href={flow.pages[0].href}
                          className={`px-2 py-1 rounded-lg text-xs font-medium ${colors.text} hover:${colors.bg} transition-all hidden sm:block`}
                          title={`Jump to ${flow.name}`}
                        >
                          {flow.name} ({flow.pages.length})
                        </Link>
                      )}
                    </div>
                  );
                })}
              </div>
            )}

            {/* Right: Menu Button */}
            <button
              onClick={() => setMenuOpen(!menuOpen)}
              className={`flex items-center gap-2 px-3 py-2 rounded-lg transition-all ${
                menuOpen
                  ? "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                  : "bg-slate-800/50 text-slate-300 hover:bg-slate-700/50 border border-slate-700"
              }`}
            >
              <span className="text-sm font-medium hidden sm:inline">Menu</span>
              <span>{menuOpen ? "✕" : "☰"}</span>
            </button>
          </div>
        </div>

        {/* Dropdown Menu - Clean Grid Layout */}
        {menuOpen && (
          <div className="border-t border-slate-700/50 bg-slate-900/98">
            <div className="max-w-5xl mx-auto p-4">
              {/* Three Column Layout for Desktop */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">

                {/* Column 1: Explore QUAD */}
                <div>
                  <div className="flex items-center gap-2 mb-3 pb-2 border-b border-blue-500/30">
                    <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                    <span className="text-blue-400 font-semibold text-sm uppercase tracking-wide">Explore QUAD</span>
                  </div>
                  <div className="space-y-1">
                    {explorePages.map((page) => (
                      <Link
                        key={page.href}
                        href={page.href}
                        onClick={() => setMenuOpen(false)}
                        className={`flex items-center gap-3 p-2 rounded-lg transition-all ${
                          pathname === page.href
                            ? "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                            : "text-slate-300 hover:text-white hover:bg-slate-800/50"
                        }`}
                      >
                        <span className="text-lg w-6 text-center">{page.icon}</span>
                        <span className="text-sm">{page.title}</span>
                      </Link>
                    ))}
                  </div>
                </div>

                {/* Column 2: Try QUAD */}
                <div>
                  <div className="flex items-center gap-2 mb-3 pb-2 border-b border-green-500/30">
                    <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span className="text-green-400 font-semibold text-sm uppercase tracking-wide">Try QUAD</span>
                  </div>
                  <div className="space-y-1">
                    {tryPages.map((page) => (
                      <Link
                        key={page.href}
                        href={page.href}
                        onClick={() => setMenuOpen(false)}
                        className={`flex items-center gap-3 p-2 rounded-lg transition-all ${
                          pathname === page.href
                            ? "bg-green-500/20 text-green-300 border border-green-500/30"
                            : "text-slate-300 hover:text-white hover:bg-slate-800/50"
                        }`}
                      >
                        <span className="text-lg w-6 text-center">{page.icon}</span>
                        <span className="text-sm">{page.title}</span>
                      </Link>
                    ))}
                  </div>
                </div>

                {/* Column 3: Resources */}
                <div>
                  <div className="flex items-center gap-2 mb-3 pb-2 border-b border-purple-500/30">
                    <div className="w-2 h-2 bg-purple-500 rounded-full"></div>
                    <span className="text-purple-400 font-semibold text-sm uppercase tracking-wide">Resources</span>
                  </div>
                  <div className="space-y-1">
                    {resourcePages.map((page) => (
                      <Link
                        key={page.href}
                        href={page.href}
                        onClick={() => setMenuOpen(false)}
                        className={`flex items-center gap-3 p-2 rounded-lg transition-all ${
                          pathname === page.href
                            ? "bg-purple-500/20 text-purple-300 border border-purple-500/30"
                            : "text-slate-300 hover:text-white hover:bg-slate-800/50"
                        }`}
                      >
                        <span className="text-lg w-6 text-center">{page.icon}</span>
                        <span className="text-sm">{page.title}</span>
                      </Link>
                    ))}
                  </div>
                </div>
              </div>

              {/* Home Link at Bottom */}
              <div className="mt-4 pt-4 border-t border-slate-700/50">
                <Link
                  href="/"
                  onClick={() => setMenuOpen(false)}
                  className={`flex items-center justify-center gap-2 p-3 rounded-lg transition-all ${
                    pathname === "/"
                      ? "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                      : "bg-slate-800/50 text-slate-300 hover:text-white hover:bg-slate-700/50 border border-slate-700"
                  }`}
                >
                  <span className="text-xl font-bold text-blue-400">◇</span>
                  <span className="font-bold">QUAD Home</span>
                </Link>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Section anchors (if sections provided) */}
      {sections && sections.length > 0 && (
        <div className="sticky top-[48px] z-40 bg-slate-800/90 backdrop-blur-sm border-b border-slate-700/30">
          <div className="max-w-7xl mx-auto px-4 py-2">
            <div className="flex items-center gap-2 overflow-x-auto text-sm">
              <span className="text-slate-500 shrink-0 text-xs">§</span>
              {sections.map((section) => (
                <button
                  key={section.id}
                  onClick={() => scrollToSection(section.id)}
                  className={`px-3 py-1 rounded-full text-xs whitespace-nowrap transition-all ${
                    activeSection === section.id
                      ? "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                      : "text-slate-400 hover:text-white hover:bg-slate-700/50"
                  }`}
                >
                  {section.title}
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Scroll to top button */}
      <button
        onClick={scrollToTop}
        className="fixed bottom-6 right-6 z-50 w-10 h-10 bg-blue-600 hover:bg-blue-700 text-white rounded-full shadow-lg flex items-center justify-center transition-all hover:scale-110 text-sm"
        title="Back to top"
      >
        ↑
      </button>

      {/* Bottom Navigation - Flow-Based */}
      <div className="mt-16 border-t border-slate-700/50 pt-8 pb-16">
        <div className="max-w-4xl mx-auto px-4">

          {/* Flow Progress Bar */}
          {pathname !== "/" && flowInfo && (
            <div className="mb-8">
              <div className="flex items-center justify-between mb-2">
                <span className={`text-xs font-semibold ${flowColors[flowInfo.flow.color].text}`}>
                  {flowInfo.flow.name} Progress
                </span>
                <span className="text-xs text-slate-400">
                  {flowInfo.pageIndex + 1} of {flowInfo.totalPages} in this flow
                </span>
              </div>
              <div className="h-1.5 bg-slate-800 rounded-full overflow-hidden">
                <div
                  className={`h-full transition-all duration-300 ${
                    flowInfo.flow.color === "blue" ? "bg-blue-500" :
                    flowInfo.flow.color === "green" ? "bg-green-500" : "bg-purple-500"
                  }`}
                  style={{ width: `${((flowInfo.pageIndex + 1) / flowInfo.totalPages) * 100}%` }}
                ></div>
              </div>
            </div>
          )}

          {/* Prev/Next Cards - Flow-Based */}
          {flowInfo && (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {/* Previous Button */}
              {flowInfo.prevInFlow ? (
                <Link
                  href={flowInfo.prevInFlow.href}
                  className={`flex items-center gap-4 rounded-xl p-5 border transition-all group ${
                    flowColors[flowInfo.flow.color].bg
                  } ${flowColors[flowInfo.flow.color].border} hover:bg-slate-800`}
                >
                  <span className={`text-3xl ${flowColors[flowInfo.flow.color].text} transition-colors`}>←</span>
                  <div className="flex-1 min-w-0">
                    <div className={`text-xs uppercase tracking-wide mb-1 ${flowColors[flowInfo.flow.color].text}`}>
                      Previous in {flowInfo.flow.name}
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-lg">{flowInfo.prevInFlow.icon}</span>
                      <span className="font-semibold text-white truncate">
                        {flowInfo.prevInFlow.title}
                      </span>
                    </div>
                  </div>
                </Link>
              ) : prevFlow ? (
                <Link
                  href={prevFlow.pages[prevFlow.pages.length - 1].href}
                  className={`flex items-center gap-4 rounded-xl p-5 border transition-all group ${
                    flowColors[prevFlow.color].bg
                  } ${flowColors[prevFlow.color].border} hover:bg-slate-800`}
                >
                  <span className={`text-3xl ${flowColors[prevFlow.color].text} transition-colors`}>←</span>
                  <div className="flex-1 min-w-0">
                    <div className={`text-xs uppercase tracking-wide mb-1 ${flowColors[prevFlow.color].text}`}>
                      Back to {prevFlow.name}
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-lg">{prevFlow.pages[prevFlow.pages.length - 1].icon}</span>
                      <span className="font-semibold text-white truncate">
                        {prevFlow.pages[prevFlow.pages.length - 1].title}
                      </span>
                    </div>
                  </div>
                </Link>
              ) : (
                <div className="hidden sm:block"></div>
              )}

              {/* Next Button */}
              {flowInfo.nextInFlow ? (
                <Link
                  href={flowInfo.nextInFlow.href}
                  className={`flex items-center gap-4 rounded-xl p-5 border transition-all group ${
                    flowColors[flowInfo.flow.color].activeBg
                  } ${flowColors[flowInfo.flow.color].border} hover:bg-slate-800`}
                >
                  <div className="flex-1 min-w-0 text-right">
                    <div className={`text-xs uppercase tracking-wide mb-1 ${flowColors[flowInfo.flow.color].text}`}>
                      Next in {flowInfo.flow.name}
                    </div>
                    <div className="flex items-center justify-end gap-2">
                      <span className="font-semibold text-white truncate">
                        {flowInfo.nextInFlow.title}
                      </span>
                      <span className="text-lg">{flowInfo.nextInFlow.icon}</span>
                    </div>
                  </div>
                  <span className={`text-3xl ${flowColors[flowInfo.flow.color].text} transition-colors`}>→</span>
                </Link>
              ) : nextFlow ? (
                <Link
                  href={nextFlow.pages[0].href}
                  className={`flex items-center gap-4 rounded-xl p-5 border transition-all group ${
                    flowColors[nextFlow.color].activeBg
                  } ${flowColors[nextFlow.color].border} hover:bg-slate-800`}
                >
                  <div className="flex-1 min-w-0 text-right">
                    <div className={`text-xs uppercase tracking-wide mb-1 ${flowColors[nextFlow.color].text}`}>
                      Continue to {nextFlow.name}
                    </div>
                    <div className="flex items-center justify-end gap-2">
                      <span className="font-semibold text-white truncate">
                        {nextFlow.pages[0].title}
                      </span>
                      <span className="text-lg">{nextFlow.pages[0].icon}</span>
                    </div>
                  </div>
                  <span className={`text-3xl ${flowColors[nextFlow.color].text} transition-colors`}>→</span>
                </Link>
              ) : (
                <Link
                  href="/"
                  className="flex items-center gap-4 bg-gradient-to-r from-green-600/20 to-green-500/10 hover:from-green-600/30 hover:to-green-500/20 rounded-xl p-5 border border-green-500/30 hover:border-green-400/50 transition-all group sm:col-span-2"
                >
                  <div className="flex-1 text-center">
                    <div className="text-xs text-green-400 uppercase tracking-wide mb-1">All Flows Complete!</div>
                    <div className="flex items-center justify-center gap-2">
                      <span className="text-xl">◇</span>
                      <span className="font-semibold text-white group-hover:text-green-200">
                        Back to QUAD Home
                      </span>
                    </div>
                  </div>
                </Link>
              )}
            </div>
          )}

          {/* Flow Overview */}
          {pathname !== "/" && flowInfo && (
            <div className="mt-8 flex items-center justify-center gap-2">
              {flows.map((flow, idx) => {
                const isActive = flowInfo.flow.id === flow.id;
                const isCompleted = flows.indexOf(flowInfo.flow) > idx;
                return (
                  <div key={flow.id} className="flex items-center gap-2">
                    <Link
                      href={flow.pages[0].href}
                      className={`flex items-center gap-1 px-2 py-1 rounded text-xs transition-all ${
                        isActive
                          ? `${flowColors[flow.color].activeBg} ${flowColors[flow.color].text} border ${flowColors[flow.color].border}`
                          : isCompleted
                          ? `${flowColors[flow.color].text} opacity-50`
                          : "text-slate-500 hover:text-slate-300"
                      }`}
                    >
                      {isCompleted && <span>✓</span>}
                      <span>{flow.name}</span>
                    </Link>
                    {idx < flows.length - 1 && <span className="text-slate-600">→</span>}
                  </div>
                );
              })}
            </div>
          )}

          {/* Quick Jump to Home */}
          {pathname !== "/" && (
            <div className="mt-6 text-center">
              <Link
                href="/"
                className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-white transition-colors"
              >
                <span className="text-blue-400">◇</span>
                <span>Back to QUAD Home</span>
              </Link>
            </div>
          )}

        </div>
      </div>
    </>
  );
}

"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

// Define all pages in order for prev/next navigation
const pages = [
  { href: "/", title: "QUAD Home", icon: "◇", short: "QUAD", section: "brand" },
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
  { href: "/docs", title: "Documentation", icon: "📚", short: "Docs", section: "resources" },
];

// Group pages by section
const explorePages = pages.filter(p => p.section === "explore");
const tryPages = pages.filter(p => p.section === "try");
const resourcePages = pages.filter(p => p.section === "resources");

interface PageNavigationProps {
  sections?: { id: string; title: string }[];
}

export default function PageNavigation({ sections }: PageNavigationProps) {
  const pathname = usePathname();
  const currentIndex = pages.findIndex((p) => p.href === pathname);
  const prevPage = currentIndex > 0 ? pages[currentIndex - 1] : null;
  const nextPage = currentIndex < pages.length - 1 ? pages[currentIndex + 1] : null;
  const [menuOpen, setMenuOpen] = useState(false);

  const scrollToSection = (id: string) => {
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  return (
    <>
      {/* Top Navigation Bar - Full Menu */}
      <div className="sticky top-0 z-50 bg-slate-900/95 backdrop-blur-sm border-b border-slate-700/50">
        {/* Main Nav Row */}
        <div className="max-w-7xl mx-auto px-4 py-2">
          <div className="flex items-center justify-between">
            {/* Logo/Home */}
            <Link
              href="/"
              className="flex items-center gap-2 text-white hover:text-blue-300 transition-colors font-bold"
            >
              <span className="text-xl font-bold text-blue-400">◇</span>
              <span className="text-sm font-bold hidden sm:inline">QUAD</span>
            </Link>

            {/* Desktop Menu - Grouped Sections */}
            <div className="hidden lg:flex items-center gap-4">
              {/* Explore QUAD Section */}
              <div className="flex items-center gap-1">
                <span className="text-xs text-slate-500 mr-1">Explore:</span>
                {explorePages.map((page) => (
                  <Link
                    key={page.href}
                    href={page.href}
                    className={`px-2 py-1 rounded-lg text-xs font-medium transition-all ${
                      pathname === page.href
                        ? "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                        : "text-slate-400 hover:text-white hover:bg-slate-800/50"
                    }`}
                  >
                    <span className="mr-1">{page.icon}</span>
                    {page.short}
                  </Link>
                ))}
              </div>

              {/* Divider */}
              <span className="text-slate-700">|</span>

              {/* Try QUAD Section */}
              <div className="flex items-center gap-1">
                <span className="text-xs text-slate-500 mr-1">Try:</span>
                {tryPages.map((page) => (
                  <Link
                    key={page.href}
                    href={page.href}
                    className={`px-2 py-1 rounded-lg text-xs font-medium transition-all ${
                      pathname === page.href
                        ? "bg-green-500/20 text-green-300 border border-green-500/30"
                        : "text-slate-400 hover:text-white hover:bg-slate-800/50"
                    }`}
                  >
                    <span className="mr-1">{page.icon}</span>
                    {page.short}
                  </Link>
                ))}
              </div>

              {/* Divider */}
              <span className="text-slate-700">|</span>

              {/* Resources Section */}
              {resourcePages.map((page) => (
                <Link
                  key={page.href}
                  href={page.href}
                  className={`px-2 py-1 rounded-lg text-xs font-medium transition-all ${
                    pathname === page.href
                      ? "bg-purple-500/20 text-purple-300 border border-purple-500/30"
                      : "text-slate-400 hover:text-white hover:bg-slate-800/50"
                  }`}
                >
                  <span className="mr-1">{page.icon}</span>
                  {page.short}
                </Link>
              ))}
            </div>

            {/* Tablet Menu - Icons Only */}
            <div className="hidden md:flex lg:hidden items-center gap-1">
              {pages.slice(1).map((page) => (
                <Link
                  key={page.href}
                  href={page.href}
                  className={`p-2 rounded-lg text-lg transition-all ${
                    pathname === page.href
                      ? "bg-blue-500/20 border border-blue-500/30"
                      : "hover:bg-slate-800/50"
                  }`}
                  title={page.title}
                >
                  {page.icon}
                </Link>
              ))}
            </div>

            {/* Mobile Menu Button */}
            <button
              onClick={() => setMenuOpen(!menuOpen)}
              className="md:hidden p-2 text-slate-400 hover:text-white"
            >
              {menuOpen ? "✕" : "☰"}
            </button>

            {/* Prev/Next - Desktop */}
            <div className="hidden sm:flex items-center gap-2">
              {prevPage && (
                <Link
                  href={prevPage.href}
                  className="px-3 py-1.5 rounded-lg text-xs text-slate-400 hover:text-white hover:bg-slate-800/50 transition-all"
                >
                  ← {prevPage.short}
                </Link>
              )}
              {nextPage && (
                <Link
                  href={nextPage.href}
                  className="px-3 py-1.5 rounded-lg text-xs bg-blue-600 text-white hover:bg-blue-700 transition-all"
                >
                  {nextPage.short} →
                </Link>
              )}
            </div>
          </div>
        </div>

        {/* Mobile Menu Dropdown */}
        {menuOpen && (
          <div className="md:hidden border-t border-slate-700/50 bg-slate-900/98 p-3">
            {/* Home */}
            <Link
              href="/"
              onClick={() => setMenuOpen(false)}
              className={`block p-3 rounded-lg text-center mb-3 ${
                pathname === "/"
                  ? "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                  : "text-slate-400 hover:text-white hover:bg-slate-800/50"
              }`}
            >
              <span className="text-xl font-bold text-blue-400">◇</span>
              <span className="ml-2 font-bold">QUAD Home</span>
            </Link>

            {/* Explore Section */}
            <div className="mb-3">
              <div className="text-xs text-slate-500 px-2 mb-2 font-semibold">EXPLORE QUAD</div>
              <div className="grid grid-cols-4 gap-1">
                {explorePages.map((page) => (
                  <Link
                    key={page.href}
                    href={page.href}
                    onClick={() => setMenuOpen(false)}
                    className={`p-2 rounded-lg text-center transition-all ${
                      pathname === page.href
                        ? "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                        : "text-slate-400 hover:text-white hover:bg-slate-800/50"
                    }`}
                  >
                    <div className="text-lg mb-1">{page.icon}</div>
                    <div className="text-[10px] truncate">{page.short}</div>
                  </Link>
                ))}
              </div>
            </div>

            {/* Try Section */}
            <div className="mb-3">
              <div className="text-xs text-slate-500 px-2 mb-2 font-semibold">TRY QUAD</div>
              <div className="grid grid-cols-4 gap-1">
                {tryPages.map((page) => (
                  <Link
                    key={page.href}
                    href={page.href}
                    onClick={() => setMenuOpen(false)}
                    className={`p-2 rounded-lg text-center transition-all ${
                      pathname === page.href
                        ? "bg-green-500/20 text-green-300 border border-green-500/30"
                        : "text-slate-400 hover:text-white hover:bg-slate-800/50"
                    }`}
                  >
                    <div className="text-lg mb-1">{page.icon}</div>
                    <div className="text-[10px] truncate">{page.short}</div>
                  </Link>
                ))}
              </div>
            </div>

            {/* Resources Section */}
            <div>
              <div className="text-xs text-slate-500 px-2 mb-2 font-semibold">RESOURCES</div>
              <div className="grid grid-cols-4 gap-1">
                {resourcePages.map((page) => (
                  <Link
                    key={page.href}
                    href={page.href}
                    onClick={() => setMenuOpen(false)}
                    className={`p-2 rounded-lg text-center transition-all ${
                      pathname === page.href
                        ? "bg-purple-500/20 text-purple-300 border border-purple-500/30"
                        : "text-slate-400 hover:text-white hover:bg-slate-800/50"
                    }`}
                  >
                    <div className="text-lg mb-1">{page.icon}</div>
                    <div className="text-[10px] truncate">{page.short}</div>
                  </Link>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Section anchors (if sections provided) */}
      {sections && sections.length > 0 && (
        <div className="sticky top-[48px] z-40 bg-slate-800/90 backdrop-blur-sm border-b border-slate-700/30">
          <div className="max-w-7xl mx-auto px-4 py-2">
            <div className="flex items-center gap-3 overflow-x-auto text-sm">
              <span className="text-slate-500 shrink-0 text-xs">§</span>
              {sections.map((section, i) => (
                <button
                  key={section.id}
                  onClick={() => scrollToSection(section.id)}
                  className="text-slate-400 hover:text-white transition-colors whitespace-nowrap text-xs"
                >
                  {section.title}
                  {i < sections.length - 1 && <span className="ml-3 text-slate-600">|</span>}
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

      {/* Bottom Navigation */}
      <div className="mt-16 border-t border-slate-700/50 pt-8 pb-16">
        <div className="max-w-4xl mx-auto px-4">
          {/* Prev/Next Cards */}
          <div className="flex items-center justify-between mb-8">
            {prevPage ? (
              <Link
                href={prevPage.href}
                className="flex items-center gap-3 bg-slate-800/50 hover:bg-slate-800 rounded-xl p-4 border border-slate-700 transition-all group"
              >
                <span className="text-2xl text-slate-500 group-hover:text-blue-400">←</span>
                <div>
                  <div className="text-xs text-slate-500">Previous</div>
                  <div className="font-semibold text-white group-hover:text-blue-300">
                    {prevPage.icon} {prevPage.title}
                  </div>
                </div>
              </Link>
            ) : (
              <div></div>
            )}

            {nextPage ? (
              <Link
                href={nextPage.href}
                className="flex items-center gap-3 bg-slate-800/50 hover:bg-slate-800 rounded-xl p-4 border border-slate-700 transition-all group text-right"
              >
                <div>
                  <div className="text-xs text-slate-500">Next</div>
                  <div className="font-semibold text-white group-hover:text-blue-300">
                    {nextPage.icon} {nextPage.title}
                  </div>
                </div>
                <span className="text-2xl text-slate-500 group-hover:text-blue-400">→</span>
              </Link>
            ) : (
              <div></div>
            )}
          </div>

        </div>
      </div>
    </>
  );
}

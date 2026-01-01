"use client";

import { useState, useEffect } from "react";
import Link from "next/link";

interface Member {
  id: string;
  user_id: string;
  role: string | null;
  allocation_pct: number | null;
  user: {
    full_name: string | null;
    email: string;
  };
}

interface Circle {
  id: string;
  circle_number: number;
  circle_name: string;
  description: string | null;
  lead_user_id: string | null;
  is_active: boolean;
  lead?: {
    full_name: string | null;
    email: string;
  };
  members: Member[];
}

const circleColors: Record<number, { bg: string; border: string; text: string; icon: string }> = {
  1: { bg: "bg-blue-50", border: "border-blue-200", text: "text-blue-700", icon: "M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m12 5.197v-1a6 6 0 00-6-6" },
  2: { bg: "bg-green-50", border: "border-green-200", text: "text-green-700", icon: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
  3: { bg: "bg-purple-50", border: "border-purple-200", text: "text-purple-700", icon: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" },
  4: { bg: "bg-orange-50", border: "border-orange-200", text: "text-orange-700", icon: "M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2" },
};

const defaultCircleDescriptions: Record<number, string> = {
  1: "Management Circle: Product owners, scrum masters, project managers who own the Q (Question) and A (Allocate) stages.",
  2: "Development Circle: Engineers, developers, architects who own the U (Understand) and D (Deliver) stages.",
  3: "QA Circle: Testers, quality engineers who support the D (Deliver) stage with validation.",
  4: "Infrastructure Circle: DevOps, SRE, platform engineers who support deployment and operations.",
};

export default function CirclesPage() {
  const [circles, setCircles] = useState<Circle[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCircle, setSelectedCircle] = useState<Circle | null>(null);
  const [showAddMemberModal, setShowAddMemberModal] = useState(false);

  // Mock data for demo
  useEffect(() => {
    const mockCircles: Circle[] = [
      {
        id: "c1",
        circle_number: 1,
        circle_name: "Management",
        description: defaultCircleDescriptions[1],
        lead_user_id: "u1",
        is_active: true,
        lead: { full_name: "Sarah Manager", email: "sarah@company.com" },
        members: [
          { id: "m1", user_id: "u1", role: "lead", allocation_pct: 100, user: { full_name: "Sarah Manager", email: "sarah@company.com" } },
          { id: "m2", user_id: "u2", role: "member", allocation_pct: 50, user: { full_name: "Mike Scrum", email: "mike@company.com" } },
        ],
      },
      {
        id: "c2",
        circle_number: 2,
        circle_name: "Development",
        description: defaultCircleDescriptions[2],
        lead_user_id: "u3",
        is_active: true,
        lead: { full_name: "Alex Lead", email: "alex@company.com" },
        members: [
          { id: "m3", user_id: "u3", role: "lead", allocation_pct: 100, user: { full_name: "Alex Lead", email: "alex@company.com" } },
          { id: "m4", user_id: "u4", role: "member", allocation_pct: 100, user: { full_name: "Jane Dev", email: "jane@company.com" } },
          { id: "m5", user_id: "u5", role: "member", allocation_pct: 100, user: { full_name: "Bob Dev", email: "bob@company.com" } },
          { id: "m6", user_id: "u6", role: "member", allocation_pct: 75, user: { full_name: "Chris Dev", email: "chris@company.com" } },
        ],
      },
      {
        id: "c3",
        circle_number: 3,
        circle_name: "QA",
        description: defaultCircleDescriptions[3],
        lead_user_id: "u7",
        is_active: true,
        lead: { full_name: "Pat QA", email: "pat@company.com" },
        members: [
          { id: "m7", user_id: "u7", role: "lead", allocation_pct: 100, user: { full_name: "Pat QA", email: "pat@company.com" } },
          { id: "m8", user_id: "u8", role: "member", allocation_pct: 100, user: { full_name: "Taylor Test", email: "taylor@company.com" } },
        ],
      },
      {
        id: "c4",
        circle_number: 4,
        circle_name: "Infrastructure",
        description: defaultCircleDescriptions[4],
        lead_user_id: "u9",
        is_active: true,
        lead: { full_name: "Kim DevOps", email: "kim@company.com" },
        members: [
          { id: "m9", user_id: "u9", role: "lead", allocation_pct: 100, user: { full_name: "Kim DevOps", email: "kim@company.com" } },
        ],
      },
    ];

    setTimeout(() => {
      setCircles(mockCircles);
      setLoading(false);
    }, 500);
  }, []);

  const getTotalAllocation = (circle: Circle) => {
    return circle.members.reduce((sum, m) => sum + (m.allocation_pct || 0), 0);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Link href="/dashboard" className="text-gray-500 hover:text-gray-700">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
              </Link>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Team Circles</h1>
                <p className="text-sm text-gray-500">Organize your team into 4 specialized circles</p>
              </div>
            </div>
            <Link href="/flows" className="text-blue-600 hover:text-blue-700 flex items-center gap-2">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7" />
              </svg>
              View Flow Board
            </Link>
          </div>
        </div>
      </header>

      {/* Circle Overview */}
      <div className="max-w-7xl mx-auto px-4 py-6">
        {/* Circle Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {circles.map((circle) => {
            const colors = circleColors[circle.circle_number] || circleColors[1];
            return (
              <div
                key={circle.id}
                className={`${colors.bg} ${colors.border} border-2 rounded-xl p-6 hover:shadow-lg transition-shadow cursor-pointer`}
                onClick={() => setSelectedCircle(circle)}
              >
                {/* Circle Header */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className={`w-12 h-12 rounded-full ${colors.text} bg-white flex items-center justify-center`}>
                      <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={colors.icon} />
                      </svg>
                    </div>
                    <div>
                      <h2 className={`text-xl font-bold ${colors.text}`}>
                        Circle {circle.circle_number}: {circle.circle_name}
                      </h2>
                      {circle.lead && (
                        <p className="text-sm text-gray-600">
                          Led by {circle.lead.full_name || circle.lead.email}
                        </p>
                      )}
                    </div>
                  </div>
                  <span className={`${colors.text} bg-white px-3 py-1 rounded-full text-sm font-medium`}>
                    {circle.members.length} members
                  </span>
                </div>

                {/* Description */}
                <p className="text-gray-600 text-sm mb-4 line-clamp-2">{circle.description}</p>

                {/* Member Avatars */}
                <div className="flex items-center justify-between">
                  <div className="flex -space-x-2">
                    {circle.members.slice(0, 5).map((member, idx) => (
                      <div
                        key={member.id}
                        className="w-8 h-8 rounded-full bg-gray-300 border-2 border-white flex items-center justify-center text-xs font-medium text-gray-700"
                        title={member.user.full_name || member.user.email}
                      >
                        {member.user.full_name?.[0] || member.user.email[0].toUpperCase()}
                      </div>
                    ))}
                    {circle.members.length > 5 && (
                      <div className="w-8 h-8 rounded-full bg-gray-200 border-2 border-white flex items-center justify-center text-xs font-medium text-gray-600">
                        +{circle.members.length - 5}
                      </div>
                    )}
                  </div>
                  <div className="text-sm text-gray-500">
                    {getTotalAllocation(circle)}% capacity
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* QUAD Stage Mapping */}
        <div className="mt-8 bg-white rounded-xl border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Circle-Stage Responsibilities</h3>
          <div className="grid grid-cols-4 gap-4">
            {[
              { stage: "Q", name: "Question", primary: "Management", support: "Development" },
              { stage: "U", name: "Understand", primary: "Development", support: "Management" },
              { stage: "A", name: "Allocate", primary: "Management", support: "Development" },
              { stage: "D", name: "Deliver", primary: "Development", support: "QA, Infrastructure" },
            ].map((mapping) => (
              <div key={mapping.stage} className="text-center p-4 rounded-lg bg-gray-50">
                <div className="text-2xl font-bold text-gray-800 mb-1">{mapping.stage}</div>
                <div className="text-sm font-medium text-gray-700 mb-2">{mapping.name}</div>
                <div className="text-xs text-gray-500">
                  <div><span className="font-medium">Primary:</span> {mapping.primary}</div>
                  <div><span className="font-medium">Support:</span> {mapping.support}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Circle Detail Modal */}
      {selectedCircle && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full mx-4 max-h-[80vh] overflow-y-auto">
            {/* Modal Header */}
            <div className={`${circleColors[selectedCircle.circle_number].bg} p-6 rounded-t-xl`}>
              <div className="flex items-center justify-between">
                <h2 className={`text-xl font-bold ${circleColors[selectedCircle.circle_number].text}`}>
                  Circle {selectedCircle.circle_number}: {selectedCircle.circle_name}
                </h2>
                <button
                  onClick={() => setSelectedCircle(null)}
                  className="text-gray-500 hover:text-gray-700"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              <p className="text-gray-600 text-sm mt-2">{selectedCircle.description}</p>
            </div>

            {/* Modal Body */}
            <div className="p-6">
              {/* Lead */}
              {selectedCircle.lead && (
                <div className="mb-6">
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Circle Lead</h3>
                  <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                    <div className="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-medium">
                      {selectedCircle.lead.full_name?.[0] || selectedCircle.lead.email[0].toUpperCase()}
                    </div>
                    <div>
                      <div className="font-medium text-gray-900">{selectedCircle.lead.full_name}</div>
                      <div className="text-sm text-gray-500">{selectedCircle.lead.email}</div>
                    </div>
                  </div>
                </div>
              )}

              {/* Members */}
              <div>
                <div className="flex items-center justify-between mb-3">
                  <h3 className="text-sm font-medium text-gray-500">Members ({selectedCircle.members.length})</h3>
                  <button
                    onClick={() => setShowAddMemberModal(true)}
                    className="text-blue-600 hover:text-blue-700 text-sm flex items-center gap-1"
                  >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                    </svg>
                    Add Member
                  </button>
                </div>
                <div className="space-y-2">
                  {selectedCircle.members.map((member) => (
                    <div key={member.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center text-sm font-medium text-gray-700">
                          {member.user.full_name?.[0] || member.user.email[0].toUpperCase()}
                        </div>
                        <div>
                          <div className="font-medium text-gray-900">{member.user.full_name || member.user.email}</div>
                          <div className="text-xs text-gray-500">{member.role}</div>
                        </div>
                      </div>
                      <div className="flex items-center gap-4">
                        <span className="text-sm text-gray-500">{member.allocation_pct}%</span>
                        <button className="text-gray-400 hover:text-red-500">
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="border-t border-gray-200 p-4 flex justify-end gap-3">
              <button
                onClick={() => setSelectedCircle(null)}
                className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
              >
                Close
              </button>
              <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                Save Changes
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

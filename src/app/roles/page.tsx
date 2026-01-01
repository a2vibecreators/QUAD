"use client";

import { useState, useEffect } from "react";
import Link from "next/link";

type ParticipationLevel = "PRIMARY" | "SUPPORT" | "REVIEW" | "INFORM" | null;

interface Role {
  id: string;
  role_code: string;
  role_name: string;
  description: string | null;
  can_manage_company: boolean;
  can_manage_users: boolean;
  can_manage_domains: boolean;
  can_manage_flows: boolean;
  can_view_all_metrics: boolean;
  can_manage_circles: boolean;
  can_manage_resources: boolean;
  q_participation: ParticipationLevel;
  u_participation: ParticipationLevel;
  a_participation: ParticipationLevel;
  d_participation: ParticipationLevel;
  color_code: string | null;
  icon_name: string | null;
  hierarchy_level: number;
  is_system_role: boolean;
  is_active: boolean;
  _count: { users: number };
}

const participationColors: Record<string, string> = {
  PRIMARY: "bg-blue-600 text-white",
  SUPPORT: "bg-blue-100 text-blue-700",
  REVIEW: "bg-purple-100 text-purple-700",
  INFORM: "bg-gray-100 text-gray-600",
};

const participationLabels: Record<string, string> = {
  PRIMARY: "P",
  SUPPORT: "S",
  REVIEW: "R",
  INFORM: "I",
};

export default function RolesPage() {
  const [roles, setRoles] = useState<Role[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingRole, setEditingRole] = useState<Role | null>(null);

  // Mock data for demo
  useEffect(() => {
    const mockRoles: Role[] = [
      {
        id: "r1",
        role_code: "ADMIN",
        role_name: "Administrator",
        description: "Full system access, manages company settings and users",
        can_manage_company: true,
        can_manage_users: true,
        can_manage_domains: true,
        can_manage_flows: true,
        can_view_all_metrics: true,
        can_manage_circles: true,
        can_manage_resources: true,
        q_participation: "PRIMARY",
        u_participation: "REVIEW",
        a_participation: "PRIMARY",
        d_participation: "REVIEW",
        color_code: "#EF4444",
        icon_name: "shield",
        hierarchy_level: 100,
        is_system_role: true,
        is_active: true,
        _count: { users: 1 },
      },
      {
        id: "r2",
        role_code: "MANAGER",
        role_name: "Manager",
        description: "Manages users, domains, and flows. Owns Q and A stages.",
        can_manage_company: false,
        can_manage_users: true,
        can_manage_domains: true,
        can_manage_flows: true,
        can_view_all_metrics: true,
        can_manage_circles: true,
        can_manage_resources: false,
        q_participation: "PRIMARY",
        u_participation: "PRIMARY",
        a_participation: "PRIMARY",
        d_participation: "REVIEW",
        color_code: "#8B5CF6",
        icon_name: "users",
        hierarchy_level: 80,
        is_system_role: true,
        is_active: true,
        _count: { users: 2 },
      },
      {
        id: "r3",
        role_code: "TECH_LEAD",
        role_name: "Tech Lead",
        description: "Technical leadership, owns U stage with development expertise",
        can_manage_company: false,
        can_manage_users: false,
        can_manage_domains: true,
        can_manage_flows: true,
        can_view_all_metrics: true,
        can_manage_circles: true,
        can_manage_resources: true,
        q_participation: "SUPPORT",
        u_participation: "PRIMARY",
        a_participation: "SUPPORT",
        d_participation: "REVIEW",
        color_code: "#3B82F6",
        icon_name: "code",
        hierarchy_level: 60,
        is_system_role: true,
        is_active: true,
        _count: { users: 1 },
      },
      {
        id: "r4",
        role_code: "DEVELOPER",
        role_name: "Developer",
        description: "Core development work, owns D stage delivery",
        can_manage_company: false,
        can_manage_users: false,
        can_manage_domains: false,
        can_manage_flows: true,
        can_view_all_metrics: false,
        can_manage_circles: false,
        can_manage_resources: false,
        q_participation: "INFORM",
        u_participation: "SUPPORT",
        a_participation: "INFORM",
        d_participation: "PRIMARY",
        color_code: "#10B981",
        icon_name: "terminal",
        hierarchy_level: 40,
        is_system_role: true,
        is_active: true,
        _count: { users: 5 },
      },
      {
        id: "r5",
        role_code: "QA",
        role_name: "QA Engineer",
        description: "Quality assurance and testing, supports D stage",
        can_manage_company: false,
        can_manage_users: false,
        can_manage_domains: false,
        can_manage_flows: true,
        can_view_all_metrics: true,
        can_manage_circles: false,
        can_manage_resources: false,
        q_participation: "INFORM",
        u_participation: "INFORM",
        a_participation: "INFORM",
        d_participation: "SUPPORT",
        color_code: "#F59E0B",
        icon_name: "check-circle",
        hierarchy_level: 30,
        is_system_role: true,
        is_active: true,
        _count: { users: 2 },
      },
      {
        id: "r6",
        role_code: "OBSERVER",
        role_name: "Observer",
        description: "View-only access, receives updates on all stages",
        can_manage_company: false,
        can_manage_users: false,
        can_manage_domains: false,
        can_manage_flows: false,
        can_view_all_metrics: false,
        can_manage_circles: false,
        can_manage_resources: false,
        q_participation: "INFORM",
        u_participation: "INFORM",
        a_participation: "INFORM",
        d_participation: "INFORM",
        color_code: "#6B7280",
        icon_name: "eye",
        hierarchy_level: 10,
        is_system_role: true,
        is_active: true,
        _count: { users: 3 },
      },
    ];

    setTimeout(() => {
      setRoles(mockRoles);
      setLoading(false);
    }, 500);
  }, []);

  const renderParticipation = (level: ParticipationLevel) => {
    if (!level) return <span className="text-gray-300">-</span>;
    return (
      <span
        className={`inline-flex items-center justify-center w-7 h-7 rounded-full text-xs font-bold ${participationColors[level]}`}
        title={level}
      >
        {participationLabels[level]}
      </span>
    );
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
                <h1 className="text-2xl font-bold text-gray-900">Role Management</h1>
                <p className="text-sm text-gray-500">Configure roles with Q-U-A-D stage participation</p>
              </div>
            </div>
            <button
              onClick={() => setShowCreateModal(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
              Create Role
            </button>
          </div>
        </div>
      </header>

      {/* Legend */}
      <div className="bg-white border-b border-gray-200 px-4 py-3">
        <div className="max-w-7xl mx-auto flex items-center gap-6 text-sm">
          <span className="text-gray-500">Stage Participation:</span>
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-1">
              <span className={`w-6 h-6 rounded-full ${participationColors.PRIMARY} text-xs flex items-center justify-center font-bold`}>P</span>
              <span className="text-gray-600">Primary</span>
            </div>
            <div className="flex items-center gap-1">
              <span className={`w-6 h-6 rounded-full ${participationColors.SUPPORT} text-xs flex items-center justify-center font-bold`}>S</span>
              <span className="text-gray-600">Support</span>
            </div>
            <div className="flex items-center gap-1">
              <span className={`w-6 h-6 rounded-full ${participationColors.REVIEW} text-xs flex items-center justify-center font-bold`}>R</span>
              <span className="text-gray-600">Review</span>
            </div>
            <div className="flex items-center gap-1">
              <span className={`w-6 h-6 rounded-full ${participationColors.INFORM} text-xs flex items-center justify-center font-bold`}>I</span>
              <span className="text-gray-600">Inform</span>
            </div>
          </div>
        </div>
      </div>

      {/* Roles Table */}
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Q</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">U</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">A</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">D</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Hierarchy</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Users</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {roles.map((role) => (
                <tr key={role.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div
                        className="w-3 h-3 rounded-full"
                        style={{ backgroundColor: role.color_code || "#6B7280" }}
                      />
                      <div>
                        <div className="font-medium text-gray-900">{role.role_name}</div>
                        <div className="text-xs text-gray-500">{role.role_code}</div>
                      </div>
                      {role.is_system_role && (
                        <span className="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded">System</span>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 text-center">{renderParticipation(role.q_participation)}</td>
                  <td className="px-6 py-4 text-center">{renderParticipation(role.u_participation)}</td>
                  <td className="px-6 py-4 text-center">{renderParticipation(role.a_participation)}</td>
                  <td className="px-6 py-4 text-center">{renderParticipation(role.d_participation)}</td>
                  <td className="px-6 py-4 text-center">
                    <span className="text-sm text-gray-600">{role.hierarchy_level}</span>
                  </td>
                  <td className="px-6 py-4 text-center">
                    <span className="inline-flex items-center justify-center w-8 h-8 rounded-full bg-gray-100 text-sm font-medium text-gray-700">
                      {role._count.users}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button
                      onClick={() => setEditingRole(role)}
                      className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                    >
                      Edit
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Permissions Matrix */}
        <div className="mt-8 bg-white rounded-xl border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Permission Matrix</h3>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="px-4 py-2 text-left text-gray-500">Role</th>
                  <th className="px-4 py-2 text-center text-gray-500">Company</th>
                  <th className="px-4 py-2 text-center text-gray-500">Users</th>
                  <th className="px-4 py-2 text-center text-gray-500">Domains</th>
                  <th className="px-4 py-2 text-center text-gray-500">Flows</th>
                  <th className="px-4 py-2 text-center text-gray-500">Metrics</th>
                  <th className="px-4 py-2 text-center text-gray-500">Circles</th>
                  <th className="px-4 py-2 text-center text-gray-500">Resources</th>
                </tr>
              </thead>
              <tbody>
                {roles.map((role) => (
                  <tr key={role.id} className="border-b border-gray-100">
                    <td className="px-4 py-2 font-medium text-gray-900">{role.role_name}</td>
                    <td className="px-4 py-2 text-center">
                      {role.can_manage_company ? (
                        <span className="text-green-600">✓</span>
                      ) : (
                        <span className="text-gray-300">-</span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-center">
                      {role.can_manage_users ? (
                        <span className="text-green-600">✓</span>
                      ) : (
                        <span className="text-gray-300">-</span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-center">
                      {role.can_manage_domains ? (
                        <span className="text-green-600">✓</span>
                      ) : (
                        <span className="text-gray-300">-</span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-center">
                      {role.can_manage_flows ? (
                        <span className="text-green-600">✓</span>
                      ) : (
                        <span className="text-gray-300">-</span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-center">
                      {role.can_view_all_metrics ? (
                        <span className="text-green-600">✓</span>
                      ) : (
                        <span className="text-gray-300">-</span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-center">
                      {role.can_manage_circles ? (
                        <span className="text-green-600">✓</span>
                      ) : (
                        <span className="text-gray-300">-</span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-center">
                      {role.can_manage_resources ? (
                        <span className="text-green-600">✓</span>
                      ) : (
                        <span className="text-gray-300">-</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Edit Role Modal */}
      {editingRole && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h2 className="text-xl font-bold">Edit Role: {editingRole.role_name}</h2>
                <button
                  onClick={() => setEditingRole(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>

            <div className="p-6 space-y-6">
              {/* Basic Info */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Role Name</label>
                  <input
                    type="text"
                    defaultValue={editingRole.role_name}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Role Code</label>
                  <input
                    type="text"
                    defaultValue={editingRole.role_code}
                    disabled
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-50 text-gray-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea
                  defaultValue={editingRole.description || ""}
                  rows={2}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2"
                />
              </div>

              {/* Q-U-A-D Participation */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">Stage Participation</label>
                <div className="grid grid-cols-4 gap-4">
                  {(["Q", "U", "A", "D"] as const).map((stage) => (
                    <div key={stage}>
                      <label className="block text-xs text-gray-500 mb-1 text-center">
                        {stage === "Q" ? "Question" : stage === "U" ? "Understand" : stage === "A" ? "Allocate" : "Deliver"}
                      </label>
                      <select
                        defaultValue={editingRole[`${stage.toLowerCase()}_participation` as keyof Role] as string || ""}
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm"
                      >
                        <option value="">None</option>
                        <option value="PRIMARY">Primary</option>
                        <option value="SUPPORT">Support</option>
                        <option value="REVIEW">Review</option>
                        <option value="INFORM">Inform</option>
                      </select>
                    </div>
                  ))}
                </div>
              </div>

              {/* Hierarchy */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Hierarchy Level</label>
                  <input
                    type="number"
                    defaultValue={editingRole.hierarchy_level}
                    min={0}
                    max={100}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Color</label>
                  <input
                    type="color"
                    defaultValue={editingRole.color_code || "#6B7280"}
                    className="w-full h-10 border border-gray-300 rounded-lg"
                  />
                </div>
              </div>

              {/* Permissions */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">Permissions</label>
                <div className="grid grid-cols-2 gap-3">
                  {[
                    { key: "can_manage_company", label: "Manage Company" },
                    { key: "can_manage_users", label: "Manage Users" },
                    { key: "can_manage_domains", label: "Manage Domains" },
                    { key: "can_manage_flows", label: "Manage Flows" },
                    { key: "can_view_all_metrics", label: "View All Metrics" },
                    { key: "can_manage_circles", label: "Manage Circles" },
                    { key: "can_manage_resources", label: "Manage Resources" },
                  ].map((perm) => (
                    <label key={perm.key} className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        defaultChecked={editingRole[perm.key as keyof Role] as boolean}
                        className="w-4 h-4 rounded border-gray-300 text-blue-600"
                      />
                      <span className="text-sm text-gray-700">{perm.label}</span>
                    </label>
                  ))}
                </div>
              </div>
            </div>

            <div className="p-6 border-t border-gray-200 flex justify-between">
              <div>
                {!editingRole.is_system_role && (
                  <button className="text-red-600 hover:text-red-700 text-sm">Delete Role</button>
                )}
              </div>
              <div className="flex gap-3">
                <button
                  onClick={() => setEditingRole(null)}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                  Save Changes
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

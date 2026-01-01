"use client";

import { useState, useEffect } from "react";
import Link from "next/link";

interface Flow {
  id: string;
  title: string;
  description: string | null;
  quad_stage: "Q" | "U" | "A" | "D";
  stage_status: string | null;
  priority: string | null;
  assigned_to: string | null;
  assignee?: {
    full_name: string | null;
    email: string;
  };
  flow_type: string | null;
  created_at: string;
}

interface Stage {
  key: "Q" | "U" | "A" | "D";
  name: string;
  fullName: string;
  color: string;
  bgColor: string;
  borderColor: string;
}

const stages: Stage[] = [
  {
    key: "Q",
    name: "Question",
    fullName: "Question",
    color: "text-blue-700",
    bgColor: "bg-blue-50",
    borderColor: "border-blue-200"
  },
  {
    key: "U",
    name: "Understand",
    fullName: "Understand",
    color: "text-purple-700",
    bgColor: "bg-purple-50",
    borderColor: "border-purple-200"
  },
  {
    key: "A",
    name: "Allocate",
    fullName: "Allocate",
    color: "text-orange-700",
    bgColor: "bg-orange-50",
    borderColor: "border-orange-200"
  },
  {
    key: "D",
    name: "Deliver",
    fullName: "Deliver",
    color: "text-green-700",
    bgColor: "bg-green-50",
    borderColor: "border-green-200"
  },
];

const priorityColors: Record<string, string> = {
  high: "bg-red-100 text-red-700 border-red-200",
  medium: "bg-yellow-100 text-yellow-700 border-yellow-200",
  low: "bg-gray-100 text-gray-700 border-gray-200",
};

export default function FlowsBoard() {
  const [flows, setFlows] = useState<Flow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [selectedStage, setSelectedStage] = useState<"Q" | "U" | "A" | "D" | null>(null);
  const [draggedFlow, setDraggedFlow] = useState<Flow | null>(null);

  // Mock data for demo (replace with actual API call)
  useEffect(() => {
    // Simulate API call
    const mockFlows: Flow[] = [
      {
        id: "1",
        title: "Implement user authentication",
        description: "Add login/logout with JWT tokens",
        quad_stage: "D",
        stage_status: "in_progress",
        priority: "high",
        assigned_to: "user1",
        assignee: { full_name: "Jane Developer", email: "jane@company.com" },
        flow_type: "feature",
        created_at: new Date().toISOString(),
      },
      {
        id: "2",
        title: "Design dashboard layout",
        description: "Create wireframes for main dashboard",
        quad_stage: "U",
        stage_status: "in_progress",
        priority: "medium",
        assigned_to: "user2",
        assignee: { full_name: "Bob Designer", email: "bob@company.com" },
        flow_type: "design",
        created_at: new Date().toISOString(),
      },
      {
        id: "3",
        title: "Setup CI/CD pipeline",
        description: "Configure GitHub Actions for deployment",
        quad_stage: "A",
        stage_status: "pending",
        priority: "high",
        assigned_to: null,
        flow_type: "infrastructure",
        created_at: new Date().toISOString(),
      },
      {
        id: "4",
        title: "What reporting features do we need?",
        description: "Gather requirements from stakeholders",
        quad_stage: "Q",
        stage_status: "pending",
        priority: "low",
        assigned_to: null,
        flow_type: "feature",
        created_at: new Date().toISOString(),
      },
      {
        id: "5",
        title: "API rate limiting requirements",
        description: "Define rate limits for different tiers",
        quad_stage: "Q",
        stage_status: "in_progress",
        priority: "medium",
        assigned_to: "user1",
        assignee: { full_name: "Jane Developer", email: "jane@company.com" },
        flow_type: "feature",
        created_at: new Date().toISOString(),
      },
      {
        id: "6",
        title: "Database optimization",
        description: "Add indexes for slow queries",
        quad_stage: "D",
        stage_status: "completed",
        priority: "high",
        assigned_to: "user3",
        assignee: { full_name: "Alex DBA", email: "alex@company.com" },
        flow_type: "improvement",
        created_at: new Date().toISOString(),
      },
    ];

    setTimeout(() => {
      setFlows(mockFlows);
      setLoading(false);
    }, 500);
  }, []);

  const getFlowsByStage = (stage: "Q" | "U" | "A" | "D") => {
    return flows.filter((flow) => flow.quad_stage === stage);
  };

  const handleDragStart = (flow: Flow) => {
    setDraggedFlow(flow);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
  };

  const handleDrop = (stage: "Q" | "U" | "A" | "D") => {
    if (draggedFlow && draggedFlow.quad_stage !== stage) {
      // Update flow stage
      setFlows((prev) =>
        prev.map((f) =>
          f.id === draggedFlow.id ? { ...f, quad_stage: stage, stage_status: "pending" } : f
        )
      );
      // TODO: Call API to update flow stage
    }
    setDraggedFlow(null);
  };

  const getStageCount = (stage: "Q" | "U" | "A" | "D") => {
    return flows.filter((f) => f.quad_stage === stage).length;
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
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-full mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Link href="/dashboard" className="text-gray-500 hover:text-gray-700">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
              </Link>
              <h1 className="text-2xl font-bold text-gray-900">QUAD Flow Board</h1>
            </div>
            <div className="flex items-center gap-3">
              <select className="border border-gray-300 rounded-lg px-3 py-2 text-sm">
                <option>All Domains</option>
                <option>Engineering</option>
                <option>Design</option>
              </select>
              <button
                onClick={() => setShowCreateModal(true)}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
                New Flow
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Stage Explanation */}
      <div className="bg-white border-b border-gray-200 px-4 py-3">
        <div className="max-w-full mx-auto flex items-center gap-6 text-sm">
          <span className="text-gray-500">Q-U-A-D Stages:</span>
          {stages.map((stage) => (
            <div key={stage.key} className="flex items-center gap-2">
              <span className={`font-bold ${stage.color}`}>{stage.key}</span>
              <span className="text-gray-600">{stage.fullName}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Kanban Board */}
      <div className="p-4">
        <div className="grid grid-cols-4 gap-4 min-h-[calc(100vh-180px)]">
          {stages.map((stage) => (
            <div
              key={stage.key}
              className={`${stage.bgColor} ${stage.borderColor} border-2 rounded-xl p-4`}
              onDragOver={handleDragOver}
              onDrop={() => handleDrop(stage.key)}
            >
              {/* Column Header */}
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  <span className={`text-2xl font-bold ${stage.color}`}>{stage.key}</span>
                  <span className={`font-semibold ${stage.color}`}>{stage.name}</span>
                </div>
                <span className={`${stage.color} bg-white px-2 py-1 rounded-full text-sm font-medium`}>
                  {getStageCount(stage.key)}
                </span>
              </div>

              {/* Flow Cards */}
              <div className="space-y-3">
                {getFlowsByStage(stage.key).map((flow) => (
                  <div
                    key={flow.id}
                    draggable
                    onDragStart={() => handleDragStart(flow)}
                    className={`bg-white rounded-lg p-4 shadow-sm border border-gray-200 cursor-move hover:shadow-md transition-shadow ${
                      draggedFlow?.id === flow.id ? "opacity-50" : ""
                    }`}
                  >
                    {/* Priority Badge */}
                    {flow.priority && (
                      <span
                        className={`inline-block px-2 py-0.5 rounded text-xs font-medium mb-2 ${
                          priorityColors[flow.priority] || priorityColors.medium
                        }`}
                      >
                        {flow.priority.toUpperCase()}
                      </span>
                    )}

                    {/* Title */}
                    <h3 className="font-medium text-gray-900 mb-1">{flow.title}</h3>

                    {/* Description */}
                    {flow.description && (
                      <p className="text-sm text-gray-500 mb-3 line-clamp-2">{flow.description}</p>
                    )}

                    {/* Footer */}
                    <div className="flex items-center justify-between">
                      {/* Type Badge */}
                      <span className="text-xs text-gray-400 uppercase">{flow.flow_type}</span>

                      {/* Assignee */}
                      {flow.assignee ? (
                        <div className="flex items-center gap-1">
                          <div className="w-6 h-6 rounded-full bg-gray-300 flex items-center justify-center text-xs font-medium text-gray-700">
                            {flow.assignee.full_name?.[0] || flow.assignee.email[0].toUpperCase()}
                          </div>
                        </div>
                      ) : (
                        <span className="text-xs text-gray-400">Unassigned</span>
                      )}
                    </div>

                    {/* Status Badge */}
                    {flow.stage_status && (
                      <div className="mt-2 pt-2 border-t border-gray-100">
                        <span
                          className={`text-xs px-2 py-0.5 rounded ${
                            flow.stage_status === "completed"
                              ? "bg-green-100 text-green-700"
                              : flow.stage_status === "in_progress"
                              ? "bg-blue-100 text-blue-700"
                              : "bg-gray-100 text-gray-600"
                          }`}
                        >
                          {flow.stage_status.replace("_", " ")}
                        </span>
                      </div>
                    )}
                  </div>
                ))}

                {/* Empty State */}
                {getFlowsByStage(stage.key).length === 0 && (
                  <div className="text-center py-8 text-gray-400">
                    <p className="text-sm">No flows in {stage.name}</p>
                    <button
                      onClick={() => {
                        setSelectedStage(stage.key);
                        setShowCreateModal(true);
                      }}
                      className="mt-2 text-blue-600 hover:text-blue-700 text-sm"
                    >
                      + Add a flow
                    </button>
                  </div>
                )}
              </div>

              {/* Add Flow Button */}
              {getFlowsByStage(stage.key).length > 0 && (
                <button
                  onClick={() => {
                    setSelectedStage(stage.key);
                    setShowCreateModal(true);
                  }}
                  className="mt-4 w-full py-2 border-2 border-dashed border-gray-300 rounded-lg text-gray-400 hover:border-gray-400 hover:text-gray-500 transition-colors"
                >
                  + Add flow
                </button>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Create Flow Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-xl max-w-lg w-full mx-4 p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold">Create New Flow</h2>
              <button
                onClick={() => {
                  setShowCreateModal(false);
                  setSelectedStage(null);
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <form className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                <input
                  type="text"
                  placeholder="What needs to be done?"
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea
                  placeholder="Add details..."
                  rows={3}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Stage</label>
                  <select
                    defaultValue={selectedStage || "Q"}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  >
                    {stages.map((s) => (
                      <option key={s.key} value={s.key}>
                        {s.key} - {s.name}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Priority</label>
                  <select className="w-full border border-gray-300 rounded-lg px-3 py-2">
                    <option value="high">High</option>
                    <option value="medium">Medium</option>
                    <option value="low">Low</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
                <select className="w-full border border-gray-300 rounded-lg px-3 py-2">
                  <option value="feature">Feature</option>
                  <option value="bug">Bug Fix</option>
                  <option value="improvement">Improvement</option>
                  <option value="design">Design</option>
                  <option value="infrastructure">Infrastructure</option>
                </select>
              </div>

              <div className="flex justify-end gap-3 pt-4">
                <button
                  type="button"
                  onClick={() => {
                    setShowCreateModal(false);
                    setSelectedStage(null);
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                  Create Flow
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

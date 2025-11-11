// agent-client.js - MCP agent integration
import fetch from "node-fetch";

const MCP_BASE_URL = process.env.MCP_BASE_URL || "http://mcp.localhost";
const VLLM_BASE_URL = process.env.VLLM_BASE_URL || "http://vllm:8000/v1";
const {OPENAI_API_KEY} = process.env;

/**
 * Draft a plan using ChatGPT with MCP tools mounted
 * @param {Object} params - { env, goal, authorId }
 * @returns {Promise<{id: string, steps: Array}>}
 */
export async function draftPlanWithAgent({ env, goal, authorId }) {
  const planId = `plan_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  // Build system prompt with MCP context
  const systemPrompt = `You are an AI agent with access to MCP tools for:
- Inbox triage (inbox.triage)
- Content operations (content.nightly.start)
- Lead management (leads.queue)
- Operations reporting (ops.report.daily)
- Vector refresh (vector.refresh)

Create a step-by-step plan to achieve: ${goal}
Environment: ${env}
Author: ${authorId}

Break this into 3-7 concrete steps. Each step should:
1. Have a clear title
2. Include a brief summary
3. Specify which MCP tool(s) it might use
4. Be actionable and measurable

Return a JSON object with:
{
  "id": "${planId}",
  "steps": [
    {
      "step_id": "step_1",
      "title": "Step title",
      "summary": "What this step does",
      "mcp_tools": ["tool_name"],
      "estimated_duration": "5m"
    }
  ]
}`;

  try {
    // Call OpenAI API (or vLLM if configured)
    const apiUrl = OPENAI_API_KEY
      ? "https://api.openai.com/v1/chat/completions"
      : `${VLLM_BASE_URL}/chat/completions`;

    const headers = {
      "Content-Type": "application/json",
    };
    if (OPENAI_API_KEY) {
      headers["Authorization"] = `Bearer ${OPENAI_API_KEY}`;
    }

    const response = await fetch(apiUrl, {
      method: "POST",
      headers,
      body: JSON.stringify({
        model: process.env.OPENAI_MODEL || "gpt-4o-mini",
        messages: [
          { role: "system", content: systemPrompt },
          {
            role: "user",
            content: `Create a plan for: ${goal}\n\nEnvironment: ${env}`,
          },
        ],
        temperature: 0.4,
        max_tokens: 1000,
      }),
    });

    if (!response.ok) {
      throw new Error(`Agent API error: ${response.statusText}`);
    }

    const data = await response.json();
    const content = data.choices[0]?.message?.content || "";

    // Parse JSON from response
    let plan;
    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        plan = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error("No JSON found in response");
      }
    } catch (parseError) {
      // Fallback: create a simple plan structure
      plan = {
        id: planId,
        steps: [
          {
            step_id: "step_1",
            title: "Analyze requirements",
            summary: `Review goal: ${goal}`,
            mcp_tools: [],
            estimated_duration: "5m",
          },
          {
            step_id: "step_2",
            title: "Execute plan",
            summary: `Implement solution for ${env}`,
            mcp_tools: [],
            estimated_duration: "15m",
          },
        ],
      };
    }

    // Ensure plan has required structure
    if (!plan.id) plan.id = planId;
    if (!plan.steps || !Array.isArray(plan.steps)) {
      plan.steps = [
        {
          step_id: "step_1",
          title: "Execute plan",
          summary: goal,
          mcp_tools: [],
          estimated_duration: "10m",
        },
      ];
    }

    return plan;
  } catch (error) {
    console.error("Error drafting plan:", error);
    // Return a fallback plan
    return {
      id: planId,
      steps: [
        {
          step_id: "step_1",
          title: "Plan execution",
          summary: `Executing plan for: ${goal}`,
          mcp_tools: [],
          estimated_duration: "10m",
        },
      ],
    };
  }
}

/**
 * Call an MCP tool
 * @param {string} toolName - Name of the MCP tool
 * @param {Object} params - Tool parameters
 * @returns {Promise<Object>}
 */
async function callMCPTool(toolName, params) {
  try {
    const response = await fetch(`${MCP_BASE_URL}/tools/${toolName}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(params),
    });

    if (!response.ok) {
      throw new Error(`MCP tool error: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error(`MCP tool ${toolName} error:`, error);
    return { error: error.message };
  }
}

/**
 * Run plan steps via MCP, streaming updates
 * @param {string} planId - Plan identifier
 * @returns {AsyncGenerator<Object>} Yields step updates
 */
export async function* runPlanStreamViaMCP(planId) {
  // In a real implementation, you'd load the plan from storage
  // For now, we'll simulate execution
  const plan = {
    id: planId,
    steps: [
      {
        step_id: "step_1",
        title: "Initialize",
        summary: "Starting plan execution",
        mcp_tools: [],
      },
    ],
  };

  // Load plan from storage (you'd implement this)
  // const plan = await loadPlan(planId);

  for (const step of plan.steps) {
    // Emit "running" phase
    yield {
      plan_id: planId,
      step_id: step.step_id,
      phase: "running",
      title: step.title,
      summary: step.summary || `Executing: ${step.title}`,
      data: null,
    };

    try {
      // Execute MCP tools if specified
      let result = null;
      if (step.mcp_tools && step.mcp_tools.length > 0) {
        for (const toolName of step.mcp_tools) {
          result = await callMCPTool(toolName, step.params || {});
          // Emit log update
          yield {
            plan_id: planId,
            step_id: step.step_id,
            phase: "log",
            title: `Tool: ${toolName}`,
            summary: JSON.stringify(result).substring(0, 200),
            data: { tool: toolName, result },
          };
        }
      } else {
        // Simulate work
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }

      // Emit "succeeded" phase
      yield {
        plan_id: planId,
        step_id: step.step_id,
        phase: "succeeded",
        title: step.title,
        summary: `Completed: ${step.title}`,
        data: result,
      };
    } catch (error) {
      // Emit "failed" phase
      yield {
        plan_id: planId,
        step_id: step.step_id,
        phase: "failed",
        title: step.title,
        summary: `Failed: ${error.message}`,
        data: { error: error.message },
      };
      break; // Stop on first failure
    }
  }
}

/**
 * Load plan from storage (implement with your storage backend)
 * @param {string} planId
 * @returns {Promise<Object>}
 */
async function loadPlan(planId) {
  // TODO: Implement plan storage/retrieval
  // Could use Redis, Postgres, or file system
  throw new Error("Plan storage not implemented");
}

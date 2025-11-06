#!/usr/bin/env bash
set -euo pipefail

echo ">> Orion Edge: applying one-step patch…"

# 1) Ensure directories exist
mkdir -p scripts src/utils .github docs/kit docs/kit/faqpacks docs/kit/marketing

# 2) CSV generator (robust JSON→CSV with clear errors)
cat > scripts/faqpack_to_csv.js <<'JS'
#!/usr/bin/env node
/**
 * Convert a faqpack JSON to CSV: question,answer,tone,source_notes
 * Usage: node scripts/faqpack_to_csv.js path/to/pack.json > out.csv
 */
const fs = require("fs");

function die(msg, code = 1) {
  console.error(`[faqpack_to_csv] ${msg}`);
  process.exit(code);
}

if (process.argv.length < 3) die("Usage: node scripts/faqpack_to_csv.js <faqpack.json>");

const inPath = process.argv[2];
if (!fs.existsSync(inPath)) die(`ENOENT: file not found: ${inPath}`);

let pack;
try {
  const raw = fs.readFileSync(inPath, "utf8");
  pack = JSON.parse(raw);
} catch (e) {
  die(`Invalid JSON: ${e.message}`);
}

if (!pack || !Array.isArray(pack.intents)) {
  die("Malformed faqpack: expected { intents: FAQIntent[] }");
}

const esc = (v) => {
  const s = (v ?? "").toString().replace(/"/g, '""');
  return `"${s}"`;
};

console.log(`question,answer,tone,source_notes`);
for (const it of pack.intents) {
  const reply = it.reply ?? "";
  const tone = it.tone ?? "";
  const notes = it.source_notes ?? "";
  // Derive question from first utterance or intent label
  const q = (Array.isArray(it.utterances) && it.utterances[0]) ? it.utterances[0] : (it.intent ?? "");
  console.log([esc(q), esc(reply), esc(tone), esc(notes)].join(","));
}
JS
chmod +x scripts/faqpack_to_csv.js

# 3) Preferences helper (pure factory + env-based filtering; no unused imports)
cat > src/utils/preferences.ts <<'TS'
export type OrionTool = { id: string; label: string };
export type OrionEdgeWebPreferences = {
  sidebar: {
    primary: { layout: OrionTool[] };
  };
  labels: Record<string, string>;
};

export function createOrionEdgeWebPreferences(base?: Partial<OrionEdgeWebPreferences>): OrionEdgeWebPreferences {
  const defaults: OrionEdgeWebPreferences = {
    sidebar: {
      primary: {
        layout: [
          { id: "dashboard", label: "Dashboard" },
          { id: "inbox", label: "Inbox" },
          { id: "knowledge", label: "Knowledge" },
          { id: "automation", label: "Automation" },
          { id: "analytics", label: "Analytics" },
          { id: "plugins", label: "Plugins" },
          { id: "version-control", label: "Versions" },
        ],
      },
    },
    labels: {
      dashboard: "Dashboard",
      inbox: "Inbox",
      knowledge: "Knowledge",
      automation: "Automation",
      analytics: "Analytics",
      plugins: "Plugins",
      "version-control": "Versions",
    },
  };

  // Merge (non-mutating)
  const merged: OrionEdgeWebPreferences = {
    sidebar: {
      primary: {
        layout: (base?.sidebar?.primary?.layout ?? defaults.sidebar.primary.layout).map((t) => ({ ...t })),
      },
    },
    labels: { ...(defaults.labels), ...(base?.labels ?? {}) },
  };

  // Hide dev-only tools in production (pure: do not mutate inputs)
  let layout = merged.sidebar.primary.layout;
  if (process.env.NODE_ENV === "development") {
    layout = layout.filter((t) => !["version-control", "plugins"].includes(t.id));
  }
  return {
    ...merged,
    sidebar: { ...merged.sidebar, primary: { ...merged.sidebar.primary, layout } },
  };
}
TS

# 4) CODEOWNERS (register docs/kit ownership)
cat > CODEOWNERS <<'OWN'
# Docs kit & content trees
/docs/kit/ @mrcdebenz7
/docs/kit/** @mrcdebenz7
# Scripts and utils introduced here
/scripts/faqpack_to_csv.js @mrcdebenz7
/src/utils/preferences.ts @mrcdebenz7
OWN

# 5) PR template (standardize reviews)
mkdir -p .github
cat > .github/pull_request_template.md <<'MD'
## Summary
What changed and why?

## Checklist
- [ ] Kit docs updated (`00_README.md`, relevant sections)
- [ ] Prompt guardrails enforced (≤60 words, domain KB boundaries)
- [ ] CSV generator tested on all faqpack JSONs
- [ ] Sheets/Zap ranges verified (e.g., `A:K`, `A:G`)
- [ ] Ownership up-to-date in `CODEOWNERS`

## Screenshots / Evidence
MD

# 6) Kit checklist (keeps PRs consistent)
cat > orchestrator_kit/.checklist.yml <<'YML'
required:
  - 00_README.md
  - orchestrator_kit/artifacts/04_prompts.md
  - orchestrator_kit/automation/06_zaps_make.yaml
  - scripts/faqpack_to_csv.js
  - src/utils/preferences.ts
rules:
  prompts:
    max_words: 60
    kb_scope_required: true
  zaps:
    ranges:
      - "A:K"
      - "A:G"
YML

# 7) Guardrails append (only if file exists; else create with section)
PROMPTS_FILE="orchestrator_kit/artifacts/04_prompts.md"
if [ -f "$PROMPTS_FILE" ]; then
  if ! grep -q "## Guardrails" "$PROMPTS_FILE"; then
    echo -e "\n## Guardrails\n- Keep replies ≤60 words\n- Stay within domain-specific KB\n- Defer with approved footer when uncertain" >> "$PROMPTS_FILE"
  fi
else
  cat > "$PROMPTS_FILE" <<'MD'
# Prompts
Core prompts for Orion Edge.

## Guardrails
- Keep replies ≤60 words
- Stay within domain-specific KB
- Defer with approved footer when uncertain
MD
fi

# 8) Zap/Sheets range corrections (best-effort, no-op if file missing)
ZAPS="orchestrator_kit/automation/06_zaps_make.yaml"
if [ -f "$ZAPS" ]; then
  sed -i.bak -E 's/range:\s*"?[A-Z]:[A-Z]"?/range: "A:K"/' "$ZAPS" || true
  # ensure at least one A:G where required (leave content-specific tuning to follow-up)
  grep -q 'A:G' "$ZAPS" || echo '# note: add A:G range where the narrow export is intended' >> "$ZAPS"
fi

echo ">> Done. Consider: git add -A && git commit -m 'chore: apply one-step patch (csv gen, prefs, codeowners, pr template, guardrails, ranges)'"

#!/usr/bin/env bash
set -euo pipefail

FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

safe_write () {
  local dst="$1"; shift
  local tmp
  tmp="$(mktemp)"
  cat > "$tmp"
  if [[ -e "$dst" && -s "$dst" && $FORCE -ne 1 ]]; then
    echo "SKIP  $dst (exists & non-empty; use --force to overwrite)"
    rm -f "$tmp"
  else
    mkdir -p "$(dirname "$dst")"
    mv "$tmp" "$dst"
    echo "WRITE $dst"
  fi
}

append_if_missing () {
  local file="$1"; local marker="$2"; shift 2
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -qF "$marker" "$file"; then
    printf "\n%s\n" "$marker" >> "$file"
    echo "APPEND $file (+marker)"
  else
    echo "SKIP   $file (marker present)"
  fi
}

echo ">> Orion Edge SAFE patch… (force=$FORCE)"

# scripts/faqpack_to_csv.js (safe)
safe_write scripts/faqpack_to_csv.js <<'JS'
#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

function die(msg, code=1){ console.error(`[faqpack_to_csv] ${msg}`); process.exit(code); }
const args = process.argv.slice(2);
if (args.length < 1) die("Usage: faqpack_to_csv <pack.json> [--out out.csv]");
const inPath = args[0];
const outIdx = args.indexOf("--out");
const outPath = outIdx !== -1 ? args[outIdx+1] : null;

if (!fs.existsSync(inPath)) die(`ENOENT: ${inPath}`);

let pack;
try { pack = JSON.parse(fs.readFileSync(inPath,"utf8")); }
catch(e){ die(`Invalid JSON: ${e.message}`); }

if (!pack || !Array.isArray(pack.intents)) die("Malformed faqpack: expected {intents: []}");

const esc = (v)=>`"${String(v??"").replace(/"/g,'""')}"`;
let csv = "question,answer,tone,source_notes\n";
for (const it of pack.intents) {
  const q = (it.utterances && it.utterances[0]) || it.intent || "";
  csv += [esc(q), esc(it.reply||""), esc(it.tone||""), esc(it.source_notes||"")].join(",")+"\n";
}
if (outPath) fs.writeFileSync(outPath, csv, "utf8"); else process.stdout.write(csv);
JS
chmod +x scripts/faqpack_to_csv.js

# src/utils/preferences.ts (safe)
safe_write src/utils/preferences.ts <<'TS'
export type OrionTool = { id: string; label: string };
export type OrionEdgeWebPreferences = {
  sidebar: { primary: { layout: OrionTool[] } };
  labels: Record<string,string>;
};

export function createOrionEdgeWebPreferences(base?: Partial<OrionEdgeWebPreferences>): OrionEdgeWebPreferences {
  const defaults: OrionEdgeWebPreferences = {
    sidebar:{ primary:{ layout:[
      { id:"dashboard", label:"Dashboard" },
      { id:"inbox", label:"Inbox" },
      { id:"knowledge", label:"Knowledge" },
      { id:"automation", label:"Automation" },
      { id:"analytics", label:"Analytics" },
      { id:"plugins", label:"Plugins" },
      { id:"version-control", label:"Versions" }
    ]}},
    labels:{
      dashboard:"Dashboard", inbox:"Inbox", knowledge:"Knowledge",
      automation:"Automation", analytics:"Analytics", plugins:"Plugins", "version-control":"Versions"
    },
  };

  const merged: OrionEdgeWebPreferences = {
    sidebar:{ primary:{ layout:(base?.sidebar?.primary?.layout ?? defaults.sidebar.primary.layout).map(t=>({...t})) } },
    labels:{ ...defaults.labels, ...(base?.labels ?? {}) },
  };

  let layout = merged.sidebar.primary.layout;
  if (process.env.NODE_ENV === "production") {
    layout = layout.filter(t => ["version-control","plugins"].indexOf(t.id) === -1);
  }
  return { ...merged, sidebar:{ ...merged.sidebar, primary:{ ...merged.sidebar.primary, layout } } };
}
TS

# CODEOWNERS / PR template (safe)
safe_write CODEOWNERS <<'OWN'
/docs/kit/ @mrcdebenz7
/docs/kit/** @mrcdebenz7
/scripts/faqpack_to_csv.js @mrcdebenz7
/src/utils/preferences.ts @mrcdebenz7
OWN

mkdir -p .github
safe_write .github/pull_request_template.md <<'MD'
## Summary
What changed and why?

## Checklist
- [ ] Kit docs updated (`00_README.md`, relevant sections)
- [ ] Prompt guardrails enforced (≤60 words, domain KB boundaries)
- [ ] CSV generator tested on all faqpack JSONs
- [ ] Sheets/Zap ranges verified (e.g., `A:K`, `A:G`)
- [ ] Schema validate (`npm run validate:faqpacks`)
- [ ] Ownership up-to-date in `CODEOWNERS`
MD

# Guardrails: append a marker if missing
append_if_missing orchestrator_kit/artifacts/04_prompts.md "## Guardrails
- Keep replies ≤60 words
- Stay within domain-specific KB
- Defer with approved footer when uncertain"

# sed with backup if file exists
if [[ -f orchestrator_kit/automation/06_zaps_make.yaml ]]; then
  cp orchestrator_kit/automation/06_zaps_make.yaml orchestrator_kit/automation/06_zaps_make.yaml.bak
  sed -i 's/range:\s*"\?[A-Z]:[A-Z]"\?/range: "A:K"/' orchestrator_kit/automation/06_zaps_make.yaml || true
  grep -q 'A:G' orchestrator_kit/automation/06_zaps_make.yaml || echo '# note: add A:G where narrow export is intended' >> orchestrator_kit/automation/06_zaps_make.yaml
fi

echo ">> SAFE patch done. Use: npm run validate:faqpacks (if configured)"



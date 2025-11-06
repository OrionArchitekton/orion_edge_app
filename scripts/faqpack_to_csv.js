#!/usr/bin/env node
const fs = require('fs');

function csvEscape(v) {
  const s = String(v ?? '');
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

function row(q, a, vertical, intent) {
  return [
    csvEscape(vertical),
    csvEscape(q),
    csvEscape(a),
    csvEscape('friendly, concise, ≤60 words'),
    csvEscape(`faqpack:${vertical}/${intent}`)
  ].join(',');
}

function run(fp) {
  const text = fs.readFileSync(fp, 'utf8');
  const pack = JSON.parse(text);
  const vertical = pack.vertical || 'unknown';
  (pack.items || []).forEach(it => {
    const q = it.question ?? '';
    const a = it.answer ?? '';
    const intent = it.intent ?? 'general';
    process.stdout.write(row(q, a, vertical, intent) + '\n');
  });
}

try {
  const arg = process.argv[2];
  if (!arg) {
    console.error('Usage: node scripts/faqpack_to_csv.js <path-to-pack.json>');
    process.exit(1);
  }
  run(arg);
} catch (e) {
  console.error(e.message);
  process.exit(1);
}


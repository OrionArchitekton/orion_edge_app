#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

function csvEscape(v) {
  const s = String(v ?? '').replace(/\n/g, ' '); // Normalize newlines to spaces
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

function row(q, a, vertical, intent, tone, source) {
  return [
    csvEscape(vertical),
    csvEscape(q),
    csvEscape(a),
    csvEscape(tone || 'friendly, concise, ≤60 words'),
    csvEscape(source || `faqpack:${vertical}/${intent}`)
  ].join(',');
}

function processPack(fp, outputDir) {
  const text = fs.readFileSync(fp, 'utf8');
  const pack = JSON.parse(text);
  
  // Handle structure: { "vertical": [{ intent, utterances, reply, ... }] }
  const vertical = Object.keys(pack).find(k => k !== 'schema' && Array.isArray(pack[k])) || 'unknown';
  const items = pack[vertical] || [];
  
  const csvLines = ['Vertical,Q,A,Tone,Source/Notes'];
  
  items.forEach(it => {
    const intent = it.intent || 'general';
    const utterances = it.utterances || [];
    const reply = it.reply || '';
    const tone = it.tone;
    const source = it.source_notes;
    
    // Create one row per utterance
    utterances.forEach(utterance => {
      csvLines.push(row(utterance, reply, vertical, intent, tone, source));
    });
  });
  
  // Write to output directory if specified
  if (outputDir) {
    const basename = path.basename(fp, '.json');
    const outPath = path.join(outputDir, `${basename}.csv`);
    fs.mkdirSync(outputDir, { recursive: true });
    fs.writeFileSync(outPath, csvLines.join('\n') + '\n');
    console.error(`Wrote ${outPath}`);
  } else {
    // Output to stdout (for single file processing)
    csvLines.forEach(line => process.stdout.write(line + '\n'));
  }
}

try {
  const arg = process.argv[2];
  const outputDir = process.argv.find(a => a.startsWith('out='))?.split('=')[1];
  
  if (!arg) {
    console.error('Usage: node scripts/faqpack_to_csv.js <path-to-pack.json|directory> [out=./output]');
    process.exit(1);
  }
  
  const stat = fs.statSync(arg);
  
  if (stat.isDirectory()) {
    // Process all JSON files in directory (except schema.json)
    const files = fs.readdirSync(arg)
      .filter(f => f.endsWith('.json') && f !== 'schema.json')
      .map(f => path.join(arg, f));
    
    files.forEach(file => {
      processPack(file, outputDir);
    });
  } else {
    // Process single file
    processPack(arg, outputDir);
  }
} catch (e) {
  console.error(e.message);
  process.exit(1);
}


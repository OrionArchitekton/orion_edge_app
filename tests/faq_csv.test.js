const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

function run(cmd, args, opts = {}) {
  const result = spawnSync(cmd, args, { encoding: 'utf8', ...opts });
  if (result.error) throw result.error;
  return result;
}

const tmpDir = path.join(__dirname, '..', '.tmp');
fs.mkdirSync(tmpDir, { recursive: true });
const packPath = path.join(tmpDir, 'tmp_pack.json');
fs.writeFileSync(packPath, JSON.stringify({
  test_vertical: [
    { intent: 'alpha', utterances: ['hello, "world"'], reply: 'Line1\nLine2, "quoted"' },
    { intent: 'beta', utterances: ['hi'], reply: 'ok', tone: 'custom tone', source_notes: 'custom source' }
  ]
}, null, 2));

const out = run('node', ['scripts/faqpack_to_csv.js', packPath]);
if (out.status !== 0) {
  console.error(out.stderr);
  process.exit(1);
}

const csv = out.stdout.trim();
if (!csv.startsWith('Q,A,Tone,Source/Notes')) {
  console.error('Missing header row');
  process.exit(2);
}
if (!csv.includes('"hello, ""world"""')) {
  console.error('Quotes/commas not escaped as expected');
  process.exit(3);
}
if (!csv.includes('"Line1 Line2, ""quoted"""')) {
  console.error('Newlines should be normalised to spaces');
  process.exit(4);
}
if (!csv.includes('"custom tone","custom source"')) {
  console.error('tone/source columns should respect overrides');
  process.exit(5);
}

console.log('ok');


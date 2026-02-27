const fs = require('fs');
const path = require('path');

const modelsDir = path.join(__dirname, '../src/models');
const files = fs.readdirSync(modelsDir).filter(f => f.endsWith('.js'));

console.log(`Found ${files.length} models. Checking for syntax errors...`);

let failedCount = 0;
files.forEach(file => {
  try {
    const modelPath = path.join(modelsDir, file);
    require(modelPath);
    console.log(`✅ ${file} is valid`);
  } catch (error) {
    console.error(`❌ ${file} failed with error:`);
    console.error(error);
    failedCount++;
  }
});

if (failedCount === 0) {
  console.log('\nAll models verified successfully! 🎉');
  process.exit(0);
} else {
  console.log(`\nVerification failed for ${failedCount} model(s). ❌`);
  process.exit(1);
}

// 构建时配置脚本
// 用于替换 API 地址
const fs = require('fs');
const path = require('path');

const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:3000';
const configPath = path.join(__dirname, 'utils', 'api.js');

let content = fs.readFileSync(configPath, 'utf8');
content = content.replace(
  /const API_BASE_URL = .*?;/,
  `const API_BASE_URL = '${API_BASE_URL}';`
);
fs.writeFileSync(configPath, content, 'utf8');

console.log(`API_BASE_URL configured to: ${API_BASE_URL}`);



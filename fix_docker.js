const fs = require('fs');
const path = require('path');
const glob = require('glob'); // maybe not available, use fs.readdirSync

const appsDir = path.join(__dirname, 'apps');
const apps = fs.readdirSync(appsDir);

for (const app of apps) {
    const dockerfilePath = path.join(appsDir, app, 'Dockerfile');
    if (fs.existsSync(dockerfilePath)) {
        let content = fs.readFileSync(dockerfilePath, 'utf8');
        let lines = content.split('\n');
        let newLines = [];
        for (let line of lines) {
            newLines.push(line);
            if (line.startsWith('FROM node:22-alpine')) {
                newLines.push('RUN apk add --no-cache openssl ca-certificates');
            }
        }
        fs.writeFileSync(dockerfilePath, newLines.join('\n'));
        console.log('Updated ' + dockerfilePath);
    }
}

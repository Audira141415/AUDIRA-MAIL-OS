import os
import glob

dockerfiles = glob.glob('apps/*/Dockerfile')
for df in dockerfiles:
    with open(df, 'r') as f:
        lines = f.readlines()
    
    new_lines = []
    for line in lines:
        new_lines.append(line)
        if line.startswith('FROM node:22-alpine'):
            new_lines.append('RUN apk add --no-cache openssl ca-certificates\n')
            
    with open(df, 'w') as f:
        f.writelines(new_lines)
    print(f'Updated {df}')

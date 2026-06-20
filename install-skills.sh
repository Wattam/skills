#!/usr/bin/env bash
set -euo pipefail

# Install every skill in this repo globally, targeting only:
#   - universal   -> the shared global ~/.agents/skills (no extra folder created)
#   - pi          -> symlinks ~/.pi/agent/skills to the shared dir
#   - claude-code -> symlinks ~/.claude/skills to the shared dir
npx skills add . -g -y -a universal -a pi -a claude-code

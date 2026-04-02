#!/usr/bin/env bash
set -euo pipefail

# My setup for AI programming 


# Claude code
curl -fsSL https://claude.ai/install.sh | bash

# Install RTK for otimize output prompts
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

rtk init --global

# Clone my skills
gh repo clone .agents ~/.agents

#!/bin/bash

echo -e "\nCHECKING DEV TOOLS/STACK VERSIONS\n\n"

fastfetch --config examples/8

echo -e "\n\n🐍 Python: v$(python --version | awk '{print $2}')"
echo -e "🦫 Go: v$(go version | awk '{print $3}' | cut -c3-)"
echo -e "📘 TypeScript: v$(tsc --version | awk '{print $2}')"
echo -e "🦀 Rust: v$(rustc --version | awk '{print $2}')"
echo -e "📦 Conda: v$(conda --version | awk '{print $2}')"
echo -e "🦕 Deno: v$(deno --version | head -n1 | awk '{print $2}')"
echo -e "🌐 Node: v$(node --version | cut -c2-)"
echo -e "📦 Cargo: v$(cargo --version | awk '{print $2}')"
echo -e "🐳 Docker: v$(docker --version | awk '{print $3}' | tr -d ',')"
echo -e "🪐 Neovim: v$(nvim --version | head -n1 | awk '{print $2}' | cut -c2-)"

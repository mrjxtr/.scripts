#!/bin/bash

# fastfetch --config examples/8 && \
# echo -e "\n🐍 Python Version:" && python --version && \
# echo -e "\n🦫 Go Version:" && go version && \
# echo -e "\n📘 TypeScript Version:" && tsc --version && \
# echo -e "\n🦀 Rust Version:" && rustc --version && \
# echo -e "\n📦 Conda Version:" && conda --version && \
# echo -e "\n🦕 Deno Version:" && deno --version && \
# echo -e "\n🌐 Node Version:" && node --version && \
# echo -e "\n📦 Cargo Version:" && cargo --version && \
# echo -e "\n🐳 Docker Version:" && docker --version && \
# echo -e "\n🪐 Neovim Version:" && nvim --version && \
# echo -e "\n@MRJXTR - CHECK VERSIONS: DONE"

echo -e "\nCHECKING DEV TOOLS/STACK VERSIONS\n\n"

fastfetch --config examples/8

echo -e "\n\n🐍 Python: $(python --version | awk '{print $2}')"
echo -e "🦫 Go: $(go version | awk '{print $3}' | cut -c3-)"
echo -e "📘 TypeScript: $(tsc --version | awk '{print $2}')"
echo -e "🦀 Rust: $(rustc --version | awk '{print $2}')"
echo -e "📦 Conda: $(conda --version | awk '{print $2}')"
echo -e "🦕 Deno: $(deno --version | head -n1 | awk '{print $2}')"
echo -e "🌐 Node: $(node --version | cut -c2-)"
echo -e "📦 Cargo: $(cargo --version | awk '{print $2}')"
echo -e "🐳 Docker: $(docker --version | awk '{print $3}' | tr -d ',')"
echo -e "🪐 Neovim: $(nvim --version | head -n1 | awk '{print $2}')"

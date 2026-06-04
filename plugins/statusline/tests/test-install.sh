#!/usr/bin/env bash
# Tests del instalador del statusline (hook de SessionStart).
# Uso: bash plugins/statusline/tests/test-install.sh
set -u

plugin_root="$(cd "$(dirname "$0")/.." && pwd)"
installer="$plugin_root/scripts/install-statusline.sh"
fails=0

run_installer() {
    HOME="$1" CLAUDE_PLUGIN_ROOT="$plugin_root" bash "$installer" 2>/dev/null
}

assert() {
    local desc=$1 cond=$2
    if eval "$cond"; then
        echo "✓ $desc"
    else
        echo "✗ $desc"
        fails=$((fails + 1))
    fi
}

# Caso 1: destino no existe → instala
tmp=$(mktemp -d); mkdir -p "$tmp/.claude"
run_installer "$tmp"
assert "instala cuando no existe destino" "[ -f '$tmp/.claude/statusline-command.sh' ]"
assert "el archivo instalado lleva el marker" "grep -q 'managed-by-plugin: statusline@claude-statusline' '$tmp/.claude/statusline-command.sh'"
rm -rf "$tmp"

# Caso 2: destino existe SIN marker (script propio del usuario) → NO pisa
tmp=$(mktemp -d); mkdir -p "$tmp/.claude"
printf '#!/bin/bash\necho "mi statusline de contexto"\n' > "$tmp/.claude/statusline-command.sh"
run_installer "$tmp"
assert "NO pisa un script ajeno al plugin" "grep -q 'mi statusline de contexto' '$tmp/.claude/statusline-command.sh'"
rm -rf "$tmp"

# Caso 3: destino existe CON marker (versión vieja del plugin) → actualiza
tmp=$(mktemp -d); mkdir -p "$tmp/.claude"
printf '#!/bin/bash\n# managed-by-plugin: statusline@claude-statusline\necho "version vieja"\n' > "$tmp/.claude/statusline-command.sh"
run_installer "$tmp"
assert "actualiza una copia propia del plugin" "! grep -q 'version vieja' '$tmp/.claude/statusline-command.sh'"
rm -rf "$tmp"

echo
if [ "$fails" -eq 0 ]; then echo "OK: todos los tests pasan"; else echo "FALLOS: $fails"; exit 1; fi

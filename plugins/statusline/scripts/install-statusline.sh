#!/usr/bin/env bash
# Instala statusline.sh en ~/.claude/statusline-command.sh de forma NO destructiva:
# solo copia si el destino no existe o si fue creado por este plugin (lleva el marker).
src="${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh"
dest="$HOME/.claude/statusline-command.sh"
marker="managed-by-plugin: statusline@claude-statusline"

if [ -f "$dest" ] && ! grep -q "$marker" "$dest"; then
    echo "statusline plugin: $dest ya existe y no fue creado por este plugin; no se sobreescribe." \
         "Para usar el statusline del plugin, mové o borrá ese archivo y reiniciá la sesión." >&2
    exit 0
fi

cp "$src" "$dest"

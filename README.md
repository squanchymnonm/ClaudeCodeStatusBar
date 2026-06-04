# Claude Code Statusline

A custom **statusline plugin for Claude Code** with context usage alerts, formatted token counts, session/weekly rate limit tracking, and a **live subagent panel** with token speed.

*[Versión en español más abajo](#-versión-en-español)*

## Features

- **Main status line** — model name, context window usage with color alerts (`>50%` yellow ⚠️, `>=70%` red 🔥), token count with thousands separator, and session (5h) / weekly rate limit usage:

  ```
  Claude Opus 4.8 | ctx: 55% used ⚠️ | tokens: 1.323.579 | session: 55% | week: 78%
  ```

- **Subagent panel** — one row per running subagent with status icon, description, token count, elapsed time and live token speed (tok/s):

  ```
  ⚡ Explore · searching payment routes · 12.450 tok · 35s · 365 tok/s
  ✓ code-reviewer · reviewing diff · 48.200 tok · 2m 10s
  ```

## Installation

1. Add the marketplace and install the plugin (inside Claude Code):

   ```
   /plugin marketplace add squanchymnonm/ClaudeCodeStatusBar
   /plugin install statusline@claude-statusline
   ```

2. The subagent panel is enabled automatically (the plugin ships it in its `settings.json`).

3. The main status line cannot be enabled from a plugin, so a `SessionStart` hook installs the script at `~/.claude/statusline-command.sh` on every session. The install is **non-destructive**: if you already have your own script at that path, the plugin will never overwrite it (move or delete it first if you want the plugin's status line). You just need to register it **once** in `~/.claude/settings.json`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline-command.sh"
     }
   }
   ```

   Or ask Claude: *"add a statusLine pointing to ~/.claude/statusline-command.sh in my settings.json"*.

4. Restart your Claude Code session.

## Updating

Edit the scripts in `plugins/statusline/scripts/`, commit and push. Other machines pick up the change with `/plugin update statusline` (or automatically when the marketplace refreshes). The main script re-copies itself on every session start thanks to the hook.

## Requirements

- Claude Code
- `jq` (`brew install jq` on macOS)

## License

[MIT](LICENSE)

---

## 🇪🇸 Versión en español

Plugin de **statusline para Claude Code** con alertas de uso de contexto, tokens formateados, uso de límites de sesión/semana y un **panel de subagentes en vivo** con velocidad de tokens.

### Características

- **Status line principal** — modelo, contexto con alertas (`>50%` amarillo ⚠️, `>=70%` rojo 🔥), tokens con separador de miles, uso de sesión (5h) y semana.
- **Panel de subagentes** — una fila por subagente con estado, tokens, tiempo y velocidad (tok/s).

### Instalación

1. Agregar el marketplace e instalar el plugin (dentro de Claude Code):

   ```
   /plugin marketplace add squanchymnonm/ClaudeCodeStatusBar
   /plugin install statusline@claude-statusline
   ```

2. El panel de subagentes queda activo automáticamente.

3. Registrar el status line principal **una vez** en `~/.claude/settings.json` (un hook de `SessionStart` instala el script en `~/.claude/statusline-command.sh` en cada sesión; la instalación es **no destructiva**: si ya tenés un script propio ahí, el plugin nunca lo pisa):

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline-command.sh"
     }
   }
   ```

4. Reiniciar la sesión de Claude Code.

### Actualizaciones

Editar los scripts en `plugins/statusline/scripts/`, commitear y pushear. Las otras PCs reciben el cambio con `/plugin update statusline`.

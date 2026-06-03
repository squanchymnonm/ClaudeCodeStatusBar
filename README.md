# claude-config

Configuración personal de Claude Code para sincronizar entre PCs.

## Qué incluye

**Plugin `statusline`:**

- **Status line principal** — modelo, contexto con alertas (`>50%` amarillo ⚠️, `>=70%` rojo 🔥), tokens con separador de miles, uso de sesión (5h) y semana coloreados:

  ```
  Claude Opus 4.8 | ctx: 55% used ⚠️ | tokens: 1.323.579 | session: 55% | week: 78%
  ```

- **Panel de subagentes** — una fila por subagente con estado, tokens y velocidad:

  ```
  ⚡ Explore · buscando rutas de pago · 12.450 tok · 35s · 365 tok/s
  ✓ code-reviewer · revisando diff · 48.200 tok · 2m 10s
  ```

## Instalación en una PC nueva

1. Agregar el marketplace e instalar el plugin (dentro de Claude Code):

   ```
   /plugin marketplace add nicolasmonaldi/claude-config
   /plugin install statusline@nicolas-config
   ```

2. El panel de subagentes queda activo automáticamente (el plugin lo trae en su `settings.json`).

3. El status line principal no puede activarse desde un plugin, así que un hook de `SessionStart` copia el script a `~/.claude/statusline-command.sh` en cada sesión. Solo falta registrarlo **una vez** en `~/.claude/settings.json`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline-command.sh"
     }
   }
   ```

   O pedirle a Claude: *"agregá el statusLine apuntando a ~/.claude/statusline-command.sh en mi settings.json"*.

4. Reiniciar la sesión de Claude Code.

## Actualizaciones

Editar los scripts en `plugins/statusline/scripts/`, commitear y pushear. Las otras PCs reciben el cambio con `/plugin update statusline` (o automáticamente al refrescar el marketplace). El script principal se re-copia solo en cada inicio de sesión gracias al hook.

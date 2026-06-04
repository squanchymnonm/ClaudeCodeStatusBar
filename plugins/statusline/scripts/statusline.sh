#!/usr/bin/env bash
# managed-by-plugin: statusline@claude-statusline — no editar a mano, se actualiza en cada SessionStart
command -v jq >/dev/null 2>&1 || { printf 'statusline: falta jq (brew install jq)'; exit 0; }
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

total_tokens=$((total_input + total_output))
total_tokens_fmt=$(echo "$total_tokens" | rev | sed -E 's/([0-9]{3})/\1./g' | rev | sed 's/^\.//')

five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

RED=$'\033[31m'
YELLOW=$'\033[33m'
RESET=$'\033[0m'

# Colorea un porcentaje: >50% amarillo, >=70% rojo
colorize_pct() {
    local pct=$1
    if [ "$pct" -ge 70 ]; then
        printf '%s%s%%%s' "$RED" "$pct" "$RESET"
    elif [ "$pct" -gt 50 ]; then
        printf '%s%s%%%s' "$YELLOW" "$pct" "$RESET"
    else
        printf '%s%%' "$pct"
    fi
}

output="$model"

if [ -n "$used_pct" ]; then
    ctx_int=$(printf "%.0f" "$used_pct")
    if [ "$ctx_int" -ge 70 ]; then
        ctx_seg="ctx: ${RED}${ctx_int}% used${RESET} 🔥"
    elif [ "$ctx_int" -gt 50 ]; then
        ctx_seg="ctx: ${YELLOW}${ctx_int}% used${RESET} ⚠️"
    else
        ctx_seg="ctx: ${ctx_int}% used"
    fi
    output="$output | $ctx_seg"
fi

output="$output | tokens: $total_tokens_fmt"

if [ -n "$five_hour" ]; then
    session_int=$(printf "%.0f" "$five_hour")
    output="$output | session: $(colorize_pct "$session_int")"
fi

if [ -n "$seven_day" ]; then
    week_int=$(printf "%.0f" "$seven_day")
    output="$output | week: $(colorize_pct "$week_int")"
fi

printf "%s" "$output"

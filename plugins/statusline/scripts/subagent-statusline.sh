#!/usr/bin/env bash
input=$(cat)
now_ms=$(( $(date +%s) * 1000 ))
columns=$(echo "$input" | jq -r '.columns // 0')

fmt_tokens() {
    echo "$1" | rev | sed -E 's/([0-9]{3})/\1./g' | rev | sed 's/^\.//'
}

fmt_duration() {
    local s=$1
    if [ "$s" -lt 60 ]; then
        printf "%ds" "$s"
    else
        printf "%dm %02ds" $((s / 60)) $((s % 60))
    fi
}

echo "$input" | jq -c '.tasks[]?' | while IFS= read -r task; do
    id=$(jq -r '.id // empty' <<<"$task")
    [ -z "$id" ] && continue

    name=$(jq -r '.name // .type // "agent"' <<<"$task")
    desc=$(jq -r '.description // .label // ""' <<<"$task")
    status=$(jq -r '.status // ""' <<<"$task")
    tokens=$(jq -r '.tokenCount // 0' <<<"$task")

    # startTime puede venir como epoch ms, epoch s o string ISO 8601
    start_ms=$(jq -r '
        (.startTime // 0) as $st
        | if ($st | type) == "number" then
            (if $st > 100000000000 then $st else $st * 1000 end)
          elif ($st | type) == "string" then
            ((($st | sub("\\.[0-9]+"; "") | fromdateiso8601?) // 0) * 1000)
          else 0 end
        | floor
    ' <<<"$task")

    elapsed_s=0
    if [ "$start_ms" -gt 0 ] && [ "$now_ms" -gt "$start_ms" ]; then
        elapsed_s=$(( (now_ms - start_ms) / 1000 ))
    fi

    # tok/s: primero desde tokenSamples (primera vs ultima muestra), fallback a tokens/elapsed
    rate=$(jq -r '
        (.tokenSamples // []) as $s
        | if ($s | length) >= 2 and (($s[0] | type) == "object") then
            $s[0] as $a | $s[-1] as $b
            | ($a.timestamp // $a.time // $a.t // 0) as $t0
            | ($b.timestamp // $b.time // $b.t // 0) as $t1
            | ($a.tokenCount // $a.tokens // $a.count // 0) as $c0
            | ($b.tokenCount // $b.tokens // $b.count // 0) as $c1
            | (if $t1 > 100000000000 then ($t1 - $t0) / 1000 else ($t1 - $t0) end) as $dt
            | if $dt > 0 and $c1 >= $c0 then (($c1 - $c0) / $dt | floor) else empty end
          else empty end
    ' <<<"$task")
    if [ -z "$rate" ] && [ "$elapsed_s" -gt 0 ] && [ "$tokens" -gt 0 ] && [ "$status" = "running" ]; then
        rate=$(( tokens / elapsed_s ))
    fi

    case "$status" in
        running|in_progress) icon="⚡" ;;
        completed|success|done) icon="✓" ;;
        failed|error) icon="✗" ;;
        *) icon="•" ;;
    esac

    content="$icon $name"
    [ -n "$desc" ] && content="$content · $desc"
    content="$content · $(fmt_tokens "$tokens") tok"
    [ "$elapsed_s" -gt 0 ] && content="$content · $(fmt_duration "$elapsed_s")"
    [ -n "$rate" ] && [ "$rate" -gt 0 ] 2>/dev/null && content="$content · ${rate} tok/s"

    # Truncar al ancho disponible de la fila
    if [ "$columns" -gt 4 ] && [ "${#content}" -gt "$columns" ]; then
        content="${content:0:$((columns - 1))}…"
    fi

    jq -cn --arg id "$id" --arg content "$content" '{id: $id, content: $content}'
done

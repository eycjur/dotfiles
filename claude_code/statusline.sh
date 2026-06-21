#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
THINKING=$(echo "$input" | jq -r '.thinking.enabled // false')
AGENT=$(echo "$input" | jq -r '.agent.name // empty')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

if [ -n "$EFFORT" ]; then
    MODEL_STR="${MODEL} (${EFFORT})"
else
    MODEL_STR="${MODEL}"
fi
[ "$THINKING" = "true" ] && MODEL_STR="${MODEL_STR} 🧠"
[ -n "$AGENT" ] && MODEL_STR="[${AGENT}] ${MODEL_STR}"

CTX_STR="ctx: ${CTX_PCT}%"

format_remaining() {
    local remaining=$1
    if [ "$remaining" -le 0 ]; then
        echo "まもなく"
        return
    fi
    local days=$((remaining / 86400))
    local hours=$(( (remaining % 86400) / 3600 ))
    local mins=$(( (remaining % 3600) / 60 ))
    if [ "$days" -gt 0 ]; then
        echo "${days}d${hours}h"
    elif [ "$hours" -gt 0 ]; then
        echo "${hours}h${mins}m"
    else
        echo "${mins}m"
    fi
}

NOW=$(date +%s)
FIVE_H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_D_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
SEVEN_D_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

RATE_PARTS=()
if [ -n "$FIVE_H_PCT" ]; then
    FIVE_H_PCT_INT=$(printf '%.0f' "$FIVE_H_PCT")
    if [ -n "$FIVE_H_RESET" ]; then
        TIME_STR=$(format_remaining $((FIVE_H_RESET - NOW)))
        RATE_PARTS+=("5h: ${FIVE_H_PCT_INT}% (${TIME_STR})")
    else
        RATE_PARTS+=("5h: ${FIVE_H_PCT_INT}%")
    fi
fi
if [ -n "$SEVEN_D_PCT" ]; then
    SEVEN_D_PCT_INT=$(printf '%.0f' "$SEVEN_D_PCT")
    if [ -n "$SEVEN_D_RESET" ]; then
        TIME_STR=$(format_remaining $((SEVEN_D_RESET - NOW)))
        RATE_PARTS+=("7d: ${SEVEN_D_PCT_INT}% (${TIME_STR})")
    else
        RATE_PARTS+=("7d: ${SEVEN_D_PCT_INT}%")
    fi
fi

if [ ${#RATE_PARTS[@]} -gt 0 ]; then
    RATE_STR="${RATE_PARTS[0]}"
    [ ${#RATE_PARTS[@]} -gt 1 ] && RATE_STR="${RATE_STR}、${RATE_PARTS[1]}"
    echo "${MODEL_STR} | ${CTX_STR} | ${RATE_STR}"
else
    echo "${MODEL_STR} | ${CTX_STR}"
fi

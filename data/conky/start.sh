#!/bin/bash

# Start conky and ask Blur My Shell (via the mutter hint) to blur the window behind the panel.

pkill -x conky
conky -d "$@" >/dev/null 2>&1 </dev/null

for _ in $(seq 20); do
    id=$(xwininfo -root -tree | grep '"conky"' | head -1 | awk '{print $1}')
    if [ -n "$id" ]; then
        xprop -id "$id" -f _MUTTER_HINTS 8u -set _MUTTER_HINTS "blur-provider=sigma:10,brightness:1.0"
        break
    fi
    sleep 0.5
done

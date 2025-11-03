#!/usr/bin/env bash

set -euo pipefail

bat=$(dualsensectl battery | awk '{print $1}')
status=$(dualsensectl battery | awk '{print $2}')

if [[ $bat == '' ]]; then
    echo ""
fi

if [[ $status == 'charging' ]]; then
    symbol='󰨢'
else
    symbol='󰖺'
fi

echo "$bat% $symbol"

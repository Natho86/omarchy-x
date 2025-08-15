#!/bin/bash

omarchy_migrations_state_path=~/.local/state/omarchy/migrations
mkdir -p $omarchy_migrations_state_path

for file in "$SCRIPT_DIR/migrations"/*.sh; do
  [[ -f "$file" ]] && touch "$omarchy_migrations_state_path/$(basename "$file")"
done

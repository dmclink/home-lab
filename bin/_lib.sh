#!/bin/bash

declare -A SKELETON_MAP=(
    ["C++"]="_cpp"
    ["NodeJS"]="_node"
    ["Go"]="_go"
)

prompt_for_skeleton() {
    local options=("${!SKELETON_MAP[@]}")
    local choice

    PS3="Selection: "
    select choice in "${options[@]}"; do
        if [[ -n "$choice" ]]; then
            echo "${SKELETON_MAP[$choice]}"
            return 0
        else
            echo "Invalid selection. Please try again." >&2
        fi
    done
}

# replaces everything that isnt a letter or a number with a hyphen
# removes leading numbers Postgres
# force kebab case for Helm
# forces all lowercase
# intent is to create one name that will work with all infra services (Postgres, Nats, Helm) for simplified searching
sanitize_app_name() {
    local input="$1"
    local sanitized=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\{1,\}/-/g' | sed 's/^[^a-z]*//;s/-*$//')
    if [ -z "$sanitized" ]; then
        echo "Error: App name must contain at least one letter" >&2
        return 1
    fi

    if [ "$input" != "$sanitized" ]; then
        echo "Suggested sanitized app name: $sanitized" >&2
        read -p "Accept this name? (y/n): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Sanitization rejected. Exiting." >&2
            return 1
        fi
    fi

    echo "$sanitized"
}

list_apps() {
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    local APPS_DIR="$PROJECT_ROOT/apps"
    local APPS
    mapfile -t APPS < <(find "$APPS_DIR" -maxdepth 1 -mindepth 1 -type d -not -path '*/.*' -printf "%f\n")
    echo $APPS
}

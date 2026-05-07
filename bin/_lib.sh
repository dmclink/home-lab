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

# replaces everything that isnt a letter or a number with an underscore
# removes leading numbers and underscores for postgres
# forces all lowercase
sanitize_app_name() {
    local input="$1"
    local sanitized=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/^[0-9_]*//')
    if [ -z "$sanitized" ]; then
        echo "Error: App name must contain at least one letter." >&2
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

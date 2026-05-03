#!/bin/bash

declare -A SKELETON_MAP=(
    ["C++"]="_cpp"
    ["NodeJS"]="_node"
)

prompt_for_skeleton() {
    local options=("${!SKELETON_MAP[@]}")
    local choice

    PS3="Selection: "
    select choice in "${options[@]}"; do
        if [[  -n "$choice" ]]; then
            echo "${SKELETON_MAP[$choice]}"
            return 0
        else
            echo "Invalid selection. Please try again." >&2
        fi
    done
}

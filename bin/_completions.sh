PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

_app_completions() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # command
    if [ "$COMP_CWORD" -eq 1 ]; then
        local commands="deploy remove disable db new clone list"
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return 0
    fi

    # app names
    case "$prev" in
        deploy|remove|disable|db)
            local apps_dir="${PROJECT_ROOT}/apps"
            if [ -d "$apps_dir" ]; then
                local apps=$(ls -1F "$apps_dir" | grep '/$' | sed 's/\///')
                COMPREPLY=( $(compgen -W "$apps" -- "$cur") )
            fi
            ;;
    esac
}

complete -F _app_completions app

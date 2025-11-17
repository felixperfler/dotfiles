# ~/.zshrc
autoload -Uz vcs_info
setopt prompt_subst

eval "$(starship init zsh)"
. "$HOME/.local/bin/env"

# Python virtual environment handling
autoload -U add-zsh-hook
function activate_virtualenv() {
    if [ -d ".venv" ] && [ -f ".venv/bin/activate" ]; then
        # Check if it's not already activated
        if [[ "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
            source .venv/bin/activate
        fi
    fi
}
add-zsh-hook chpwd activate_virtualenv

export PATH="/Applications/MATLAB_R2024b.app/bin:$PATH"

# bun completions
[ -s "/Users/felixperfler/.bun/_bun" ] && source "/Users/felixperfler/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

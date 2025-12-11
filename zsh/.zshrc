# ~/.zshrc
autoload -Uz vcs_info
setopt prompt_subst

export STARSHIP_CONFIG="$HOME/.dotfiles/starship/starship.toml"
. "$HOME/.local/bin/env"
eval "$(starship init zsh)"

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

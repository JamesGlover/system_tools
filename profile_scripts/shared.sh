# Aliases
# Typing whoops removes the last history entry
alias whoops="history -d \`history 2 | head -n 1 | awk '{ print $1 }'\`; clear"
# Cleans up anything merged to master
alias git-clean='git branch --merged master | egrep  -v "^[* ]+(master|release|production|next_release)$" | xargs git branch -d'
# Short bundler alias
alias bx='bundle exec'

# Integrations
# Git Prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
else
  echo 'gitprompt is not installed.'
fi

# Ruby Env
if which -s rbenv; then
  eval "$(rbenv init -)"
else
  echo 'Rubyenv is not installed'
fi

# Settings
# Set the history to append mode, for better handlign of multiple tabs
shopt -s histappend

export HOMEBREW_NO_INSTALL_CLEANUP=1

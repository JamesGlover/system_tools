source $1/profile_scripts/shared.sh $1

# iTerm extensions
function title {
  echo -ne "\033]0;"$*"\007"
}

function iterm2_print_user_vars() {
  iterm2_set_user_var gitBranch $GIT_BRANCH
}

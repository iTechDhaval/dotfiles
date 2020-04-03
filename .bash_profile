#
# .bash_profile
#
# @author Dhaval Patel
# @see .inputrc
#

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

generate_password() {
  segments=$1
  if [ -z "$1" ]
    then
    segments=4
  fi
  let TOTAL_CHARACTERS=segments*3
  LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c $TOTAL_CHARACTERS | xargs | sed 's/.\{3\}/&-/g' | rev | cut -c2- | rev
}

txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

print_before_the_prompt () {
    printf "\n${txtgrn} %s: $bldylw%s $txtpur%s\n$txtrst" "$USER" "$PWD" "$(parse_git_branch)"
    # printf "\[\e[0;32m\]\]\[\] \[\e[1;32m\]\]\t:\[\033[33;1m\]\w\[\033[m\]\[\033[32m\]\$(parse_git_branch)\[\033[00m\]\[$\]"
}

PROMPT_COMMAND=print_before_the_prompt
PS1="$txtgrn\[\] $txtwht\[$\] "

# export PS1="\[\e[0;32m\]\]\[\] \[\e[1;32m\]\]\t:\[\033[33;1m\]\w\[\033[m\]\[\033[32m\]\$(parse_git_branch)\[\033[00m\]\[$\] "


# Nicer prompt.
# export PS1="\[\e[0;32m\]\]\[\] \[\e[1;32m\]\]\t \[\e[0;2m\]\]\w \[\e[0m\]\]\[$\] "

# Use colors.
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Custom $PATH with extra locations.
# export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:/usr/local/git/bin:$HOME/.composer/vendor/bin:$HOME/tools/flutter/bin:$PATH

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.bash_aliases ]
then
  source ~/.bash_aliases
fi

# Include bashrc file (if present).
if [ -f ~/.bashrc ]
then
  source ~/.bashrc
fi

# Route local traffic over ethernet when using certain WiFi networks w/o proxy.
function route_add() {
  sudo route add -net 10.0.0.0/8 -interface en0
}

# Delete the route added above.
function route_delete() {
  sudo route delete 10.0.0.0
}

# Route IRC traffic through one of my servers.
# Use SOCKS5 settings 'localhost' and 6667 for server/port.
function irc_proxy() {
  ssh -vD 6667 geerlingguy@atl1.servercheck.in
}

# Syntax-highlight code for copying and pasting.
# Requires highlight (`brew install highlight`).
function pretty() {
  pbpaste | highlight --syntax=$1 -O rtf | pbcopy
}

# Colorfull grep output
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;37;41'

# General command alias based on Ubuntu
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls -aFhlG'
alias search='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Special alias for productivity
alias ssearch='grep --color=auto --exclude-dir=".git" --exclude-dir=".svn"'

# Git aliases.
alias gs='git status'
alias gc='git commit'
alias gp='git pull --rebase'
alias gcam='git commit -am'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gsd='git svn dcommit'
alias gsfr='git svn fetch && git svn rebase'

# Git upstream branch syncer.
# Usage: gsync master (checks out master, pull upstream, push origin).
function gsync() {
  if [[ ! "$1" ]] ; then
      echo "You must supply a branch."
      return 0
  fi

  BRANCHES=$(git branch --list $1)
  if [ ! "$BRANCHES" ] ; then
     echo "Branch $1 does not exist."
     return 0
  fi

  git checkout "$1" && \
  git pull upstream "$1" && \
  git push origin "$1"
}

# Turn on Git autocomplete.
brew_prefix=`brew --prefix`
if [ -f $brew_prefix/etc/bash_completion ]; then
  . $brew_prefix/etc/bash_completion
fi

# Use brew-installed PHP binaries.
export PATH="$brew_prefix/opt/php56/bin:$PATH"

# Use nvm.
#export NVM_DIR="$HOME/.nvm"
#. "$brew_prefix/opt/nvm/nvm.sh"

# Use rbenv.
if [ -f /usr/local/bin/rbenv ]; then
  eval "$(rbenv init -)"
fi

# Python settings.
# export PYTHONPATH="/usr/local/lib/python2.7/site-packages"

# Super useful Docker container oneshots.
# Usage: dockrun, or dockrun [centos7|fedora24|debian8|ubuntu1404|etc.]
dockrun() {
  docker run -it geerlingguy/docker-"${1:-ubuntu1604}"-ansible /bin/bash
}

# Enter a running Docker container.
function denter() {
  if [[ ! "$1" ]] ; then
      echo "You must supply a container ID or name."
      return 0
  fi

  docker exec -it $1 bash
  return 0
}

# Delete a given line number in the known_hosts file.
knownrm() {
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
    echo "error: line number missing" >&2;
  else
    sed -i '' "$1d" ~/.ssh/known_hosts
  fi
}

# Ask for confirmation when 'prod' is in a command string.
prod_command_trap () {
  if [[ $BASH_COMMAND == *prod* ]]
  then
    read -p "Are you sure you want to run this command on prod [Y/n]? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      echo -e "\nRunning command \"$BASH_COMMAND\" \n"
    else
      echo -e "\nCommand was not run.\n"
      return 1
    fi
  fi
}
shopt -s extdebug
# trap prod_command_trap DEBUG

function blt() {
  if [ "`git rev-parse --show-cdup 2> /dev/null`" != "" ]; then
    GIT_ROOT=$(git rev-parse --show-cdup)
  else
    GIT_ROOT="."
  fi

  if [ -f "$GIT_ROOT/vendor/bin/blt" ]; then
    $GIT_ROOT/vendor/bin/blt "$@"
  else
    echo "You must run this command from within a BLT-generated project repository."
    return 1
  fi
}








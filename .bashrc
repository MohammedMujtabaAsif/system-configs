#
# ~/.bashrc
#

# ENV settings

# FVM: Flutter Version Management https://fvm.app
#export PATH="/home/mujtaba/fvm/bin:$PATH"

# Android SDK
#export ANDROID_HOME=$HOME/android-sdk
#export PATH=$PATH:$ANDROID_HOME/platform-tools
#export JAVA_HOME=/usr/lib/jvm/java-21-openjdk

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source /usr/share/nvm/init-nvm.sh
alias editbashrc='nano ~/.bashrc'
alias updatebashrc='source ~/.bashrc'
alias netspeed="sudo cat /sys/class/net/enp42s0/speed"
alias swapusage="swapon --show"
alias findfile="find . -type f -iname"
alias finddirectory="find . -type d -iname"

# git
alias gitmerged='git branch --merged | rg -v "master|staging|release/*"'
alias gitprune='gitmerged | xargs git branch -d'

# coding
alias cdvmm='cd ~/Git/vmm-laravel-server'
alias cdhs='cd ~/Homestead'

alias npmvmm='npm --prefix ~/Git/vmm-laravel-server run dev'
alias vagranths='cd ~/Homestead; vagrant'
alias hsup='vagranths up; cd -'
alias hsdown='vagranths halt; cd -'
alias sshhs='vagranths ssh; cd -'

# package manager
alias yayup='yay -Syu'
alias pacup='sudo pacman -Syu'
alias pacls='pacman -Qe'
alias pacrm='pacman -Rns'
#alias systemupdate='yay --noconfirm && flatpak uninstall --unused && flatpak update -y && notify'

# tmux
alias tmuxnew='tmux new -s'
alias tmuxa='tmux a -t'
alias tmuxls='tmux list-sessions'
alias tmuxkill='tmux kill-sessions -t'

# zellij
alias zel='zellij'
alias zelrename='zellij action rename-session'

alias notify='notification_for_command || notification_for_command' # use: <command> && <command> && notify or <command> && <command>; notify

trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

unlock_bitwarden() {
  # Ensure BW_SESSION is set
  if [ -z "$BW_SESSION" ]; then
    echo "Bitwarden is locked"
    export BW_SESSION=$(flatpak run --command=bw com.bitwarden.desktop unlock --raw)
  else
   echo "Bitwarden session found"
  fi
}

sideload() {
  unlock_bitwarden

  local ipa_path="${1:-/home/mujtaba/Downloads/YTLitePlus.ipa}"
  local apple_account_uuid="ce5ee805-11de-49ee-aba3-ad4100f9f8c7"
  local ipad_uuid="00008110-000C114C1103801E"
  local username=$(flatpak run --command=bw com.bitwarden.desktop get username "$apple_account_uuid" --raw)
  local password=$(flatpak run --command=bw com.bitwarden.desktop get password "$apple_account_uuid" --raw)

  echo "Using IPA file: $ipa_path to $ipad_uuid for using apple account $username"

  altserver -u "$ipad_uuid" -a "$username" -p "$password" "$ipa_path"
}

notification_for_command() {
  local exit_status=$?
  # prefer the recorded previous_command, fallback to history if empty
  local cmd="${previous_command:-$(history 2 | sed -n '1p' | sed 's/^ *[0-9]* *//')}"
  [ -z "$cmd" ] && cmd="(unknown)"

  local title
  if [ "$exit_status" -eq 0 ]; then
    title="Task Completed"
  else
    title="Task Failed"
  fi

  # include command and exit code in the notification body
  send_notification "Command: $cmd | Exit code: $exit_status" "$title" "commands"
}

send_notification() {
  local message="${1:-Complete}"
  local title="${2:-Notification}"
  local topic="${3:-misc}"

  # sanitize topic (lowercase, allow a-z0-9 . _ -); fallback to misc if empty
  topic=$(printf '%s' "$topic" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g' | sed 's/^-*//;s/-*$//')
  [ -z "$topic" ] && topic='misc'

  # build a JSON string payload using pure bash (no jq/python)
  local esc=${message//\\/\\\\}
  esc=${esc//\"/\\\"}
  esc=${esc//$'\r'/\\r}
  esc=${esc//$'\n'/\\n}
  local payload="${esc}"

  # sanitize title for header (strip newlines and double-quotes)
  local safe_title=${title//$'\n'/ }
  safe_title=${safe_title//\"/}

  curl -sS \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Title: ${safe_title}" \
    -X POST --data-raw "$payload" "https://ntfy.mujtabaasif.dedyn.io/${topic}"
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[[ $- != *i* ]] && return

[ -d ~/.bashrc.d ] && source ~/.bashrc.d/*.sh

export BASH_SILENCE_DEPRECATION_WARNING=1

export EDITOR='nvim'
export OLDTERM="$TERM"
export BASE16_SHELL="$HOME/.config/base16-shell/"

export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=1000
export HISTFILESIZE=2000

bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

shopt -s histappend
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && \
    eval "$(SHELL=/bin/sh lesspipe)"

alias grep='grep --color=auto'

alias vi='2>/dev/null nvr -cc split'
alias vim='2>/dev/null nvr -cc split'

git-du ()
{
    git rev-list --objects --all \
        | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
        | sed -n 's/^blob //p' \
        | sort --numeric-sort --key=2 \
        | cut -c 1-12,41- \
        | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}

git-purge ()
{
    [ -z "$1" ] && {
        echo "Usage: git-purge <filepath>"
        exit 1
    }

    set -e

    FILTER_BRANCH_SQUELCH_WARNING=1 \
        git filter-branch \
            --force \
            --index-filter "git rm -r --cached --ignore-unmatch $1" \
            --prune-empty \
            --tag-name-filter cat \
            -- --all

    git for-each-ref --format="delete %(refname)" refs/original | git update-ref --stdin
    git reflog expire --expire=now --all
    git gc --prune=now
}

vcd()
{
    cd "$@"
    nvr -cc "call g:Cd('$@')" 2>/dev/null
}


[[ "$(whoami)" == "root" ]] && {
    PS1='[\[\033[35m\]\u\[\033[00m\]\[\033[00m\] \[\033[00;34m\]\W\[\033[00m\]]#\[\033[00;00m\] '
} || {
    PS1='[\[\033[32m\]\u\[\033[00m\]\[\033[00m\] \[\033[00;34m\]\W\[\033[00m\]]\$\[\033[00;00m\] '
}

[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"


init()
{
    [[ "$OLDTERM" != "linux" && "$(whoami)" != "root" ]] && {
        [ -z "$TMUX" ] && (tmux attach -t main || tmux new-session -s main bash -i -c init) && exit
        [ -z "$NVIM_LISTEN_ADDRESS" ] && {
            read -p 'name] ' name
            [ -z "$name" ] && name='unnammed'

            # DIR="$(2>/dev/null find -L . -type d | fzf)"
            # cd "$DIR"
            nvim -c "call g:TmuxSetName('$name')" -c FzDirectories && exit
        }
    }
}
# Aliases
alias ls='ls -G'
alias gs="git status"
alias gc="git checkout"
alias gd="git diff"
alias gl="git log"
alias gp="git push"
alias gpu="git pull"
alias ga="git add"
alias gm="git merge"

alias watch='watch -n 0.5 '

alias kgp="kubectl get pods"
alias kdp="kubectl delete pod"
alias kgd="kubectl get deployments"
alias kd="kubectl describe"
alias kgs="kubectl get services"
alias kgi="kubectl get ingress"
alias kl="kubectl logs --follow"
function kubessh1() {
    kubectl exec -it $1 -- /bin/bash
}
alias kubessh=kubessh1
alias azkvl="echo 'az keyvault secret list --vault-name efp01-vault-dev |jq .[].id';az keyvault secret list --vault-name efp01-vault-dev |jq .[].id"

alias task="python3 ~/git/misc/task/task.py"
alias had00p="~/git/scripts/had00pFileImport/had00pFileImport.sh"

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_181.jdk/Contents/Home/

function kubesecretHelper() {
    kubectl get secret $1 -o json | jq -r '.data.data' | base64 --decode
    echo ""
}
alias kubesecret=kubesecretHelper $1

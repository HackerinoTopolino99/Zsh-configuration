#-----------------------------
# Source some stuff
#-----------------------------
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
  source /usr/share/doc/pkgfile/command-not-found.zsh
fi

if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

#------------------------------
# History stuff
#------------------------------
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

#------------------------------
# Keybindings
#------------------------------
bindkey -e

#------------------------------
# Aliases
#------------------------------
alias autoremove="pacman -Qdtq | pacman -Rns - && paccache -ruk0 && paccache -rk1"
alias chmod="chmod -c"
alias chown="chown -c"
alias cp='cp -iv --reflink=auto'
alias df='duf'
alias dmesg='dmesg --color=auto'
alias free='free --si -h'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias ip='ip -color=auto'
alias ln='ln -v'
alias ls='ls --color=auto -h -F --group-directories-first -1'
alias mv='mv -iv'
alias ncdu='ncdu --color dark'
alias pacman='pacman --color=auto'
alias paru='paru --color=auto --removemake'
alias rm='rm -iv'
alias sudo='sudo '
alias sync-status='watch -d grep -e Dirty: -e Writeback: /proc/meminfo'

#------------------------------
# Kitty fix for ssh
#------------------------------
[ "$TERM" = "xterm-kitty" ] && alias ssh='kitty +kitten ssh'

#------------------------------
# ShellFuncs
#------------------------------
# -- coloured manuals
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;40;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

#------------------------------
# Comp stuff
#------------------------------
zmodload zsh/complist 
autoload -Uz compinit
compinit
zstyle :compinstall filename '${HOME}/.zshrc'

#- buggy
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
#-/buggy

zstyle ':completion:*:pacman:*' force-list always
zstyle ':completion:*:*:pacman:*' menu yes select

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always
zstyle ':completion:*' rehash true

#------------------------------
# Prompt
#------------------------------
autoload -U colors zsh/terminfo
colors

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git*' formats "%{${fg[cyan]}%}[%{${fg[green]}%}%s%{${fg[cyan]}%}][%{${fg[blue]}%}%r/%S%%{${fg[cyan]}%}][%{${fg[blue]}%}%b%{${fg[yellow]}%}%m%u%c%{${fg[cyan]}%}]%{$reset_color%}"

prompt_hackerinotopolino_setup () {
  setopt prompt_subst

  if [[ $TERM = "linux" ]]; then
    if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then 
      p_host='%F{yellow}%M%f'
    else
      p_host='%F{green}%M%f'
    fi

    fortune | cowsay | lolcat --spread 1.0

    if [[ "$UID" = 0 ]]; then
      PS1="%F{blue}[%f%F{red}%n%f%F{blue}@%f${p_host} %F{red}%c%f%F{blue}]#%f "
    else
      PS1="%F{blue}[%n@%f${p_host} %F{red}%c%f%F{blue}]$%f "
    fi

    RPS1="[%F{yellow}%?%f]"

  else
    SEP_RIGHT=''
    if [[ "$UID" = 0 ]]; then
       parse_git_branch() {
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [[ -n "$branch" ]]; then
          echo "%K{#5a0a0a}%F{#500000}${SEP_RIGHT}%K{#5a0a0a}%F{white} $branch  %K{default}%F{#5a0a0a}${SEP_RIGHT}%k"
        else
          echo "%k%F{#500000}${SEP_RIGHT}"
        fi
      }
    
      # Definizione del prompt su una riga con separatori
      PS1='%K{#3a0606}%F{white} %n@%m %K{#500000}%F{#3a0606}'$SEP_RIGHT   # user@host → separatore
      PS1+="%K{#500000}%F{white} %c "   # working dir → separatore
      PS1+='$(parse_git_branch)'                                   # git branch + sep (solo se c'è)
    
      # Se c'è il branch, aggiunge il separatore finale
    
      PS1+='%f '  # newline e $
      RPS1="[%F{yellow}%?%f]"

    else
      # Funzione per ottenere il branch Git se presente
      parse_git_branch() {
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [[ -n "$branch" ]]; then
          echo "%K{#246424}%F{#175616}${SEP_RIGHT}%K{#246424}%F{white} $branch  %K{default}%F{#246424}${SEP_RIGHT}%k"
        else
          echo "%k%F{#175616}${SEP_RIGHT}"
        fi
      }
    
      # Definizione del prompt su una riga con separatori
      PS1='%K{#174017}%F{white} %n@%m %K{#175616}%F{#174017}'$SEP_RIGHT   # user@host → separatore
      PS1+="%K{#175616}%F{white} %c "   # working dir → separatore
      PS1+='$(parse_git_branch)'                                   # git branch + sep (solo se c'è)
    
      # Se c'è il branch, aggiunge il separatore finale
    
      PS1+='%f '  # newline e $
      RPS1="[%F{yellow}%?%f]"
    fi
  fi
}

prompt_hackerinotopolino_setup

# vim: set ts=2 sw=2 et:

# shellcheck disable=SC2034

# Enable Git branch display in prompt
git_prompt_script_exists=0
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
    git_prompt_script_exists=1
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    . /usr/share/git-core/contrib/completion/git-prompt.sh
    git_prompt_script_exists=1
fi

if [ $git_prompt_script_exists -eq 1 ]; then
    GIT_PS1_SHOWDIRTYSTATE=true
    GIT_PS1_SHOWUNTRACKEDFILES=true
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWCONFLICTSTATE="yes"
    GIT_PS1_SHOWCOLORHINTS=true

    PS1+='$(__git_ps1 "[%s] ")'

    # USERNAME_BG="\[\e[1;37;40m\]"   # negrito, texto branco, fundo escuro
    # CWD_BG="\[\e[1;37;44m\]"        # negrito, texto branco, fundo azul
    # RESET_BG="\[\e[0m\]"            # reseta cor/fundo

    # Template para colorir cursor do bash => user@hostname directory [git branch] $ )
    # PS1_BASE="${USERNAME_BG} \u@\h ${RESET_BG}${CWD_BG} \w ${RESET_BG}"
    # PS1="$PS1_BASE"
    # PS1+='$(__git_ps1 "[%s]")\$ '
    # PS1="${COLOR_GREEN}\u${COLOR_RESET}@${COLOR_BLUE}\h ${COLOR_PURPLE}\w${COLOR_YELLOW}\$(__git_ps1 ' (%s)')${COLOR_RESET}\n\$ "

    # unset PS1_BASE USERNAME_BG CWD_BG RESET_BG
fi

# # original no arquivo ~/.bashrc
# # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# original fedora 42
# ${PROMPT_START@P}\[\e[${PROMPT_COLOR}${PROMPT_HIGHLIGHT:+;$PROMPT_HIGHLIGHT}m\]${PROMPT_USERHOST@P}\[\e[0m\]${PROMPT_SEPARATOR@P}\[\e[${PROMPT_DIR_COLOR-${PROMPT_COLOR}}${PROMPT_HIGHLIGHT:+;$PROMPT_HIGHLIGHT}m\]${PROMPT_DIRECTORY@P}\[\e[0m\]${PROMPT_END@P}\$\[\e[0m\]
# "${PROMPT_START@P}\[\e[${PROMPT_COLOR}${PROMPT_HIGHLIGHT:+;$PROMPT_HIGHLIGHT}m\]${PROMPT_USERHOST@P}\[\e[0m\]${PROMPT_SEPARATOR@P}\[\e[${PROMPT_DIR_COLOR-${PROMPT_COLOR}}${PROMPT_HIGHLIGHT:+;$PROMPT_HIGHLIGHT}m\]\w\[\e[0m\]${PROMPT_END@P}\$\[\e[0m\] "

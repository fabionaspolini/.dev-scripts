alias dev-scripts-update="git -C ~/.dev-scripts pull"
alias bashrc-scripts-update="git -C ~/.bashrc.d pull"
alias zshrc-scripts-update="git -C ~/.zshrc.d pull"
alias all-scripts-update="\
    echo 'Running dev-scripts-update...' && \
    dev-scripts-update &&
    echo 'Running bashrc-scripts-update...' && \
    bashrc-scripts-update && \
    echo 'Running zshrc-scripts-update...' && \
    zshrc-scripts-update"

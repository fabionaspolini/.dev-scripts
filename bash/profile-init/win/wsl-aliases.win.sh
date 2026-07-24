alias stop-wsl="wsl --shutdown Ubuntu-20.04"

# docker
alias start-docker="wsl -d Ubuntu-20.04 -- sudo service docker start"
alias docker="wsl.exe -d Ubuntu-20.04 docker $*"

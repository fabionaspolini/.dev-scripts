alias dotnet-clear-nuget-cache="dotnet nuget locals --clear all"

# Path
if [ -d ~/.dotnet ]; then
    export PATH="$PATH:~/.dotnet"
fi

if [ -d ~/.dotnet/tools ]; then
    export PATH="$PATH:~/.dotnet/tools"
fi

# .net
export DOTNET_CLI_UI_LANGUAGE=en

if [ -d /lib64/dotnet ]; then
    export DOTNET_ROOT=/lib64/dotnet
else
    export DOTNET_ROOT=~/.dotnet
fi

# Android workload build
export AcceptAndroidSDKLicenses=True
export AndroidSdkDirectory=/home/fabio/Android/Sdk/
export JavaSdkDirectory=/lib/jvm/jdk-21.0.8+9/

# bash parameter completion for the dotnet CLI
function _dotnet_bash_complete()
{
  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n' # On Windows you may need to use use IFS=$'\r\n'
  local candidates

  read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

  read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
}

complete -f -F _dotnet_bash_complete dotnet

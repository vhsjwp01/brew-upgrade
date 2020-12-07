#!/bin/bash
#set -x

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"
TERM="vt100"
export TERM PATH

SUCCESS=0
ERROR=1

let exit_code=${SUCCESS}

this_USER=$(id -un)

if [ ! -z "${1}" ]; then
    this_USER="${1}"
fi

if [ ! -z "${this_USER}" ]; then
    this_HOME="/Users/${this_USER}"
    this_LOG="${this_HOME}/brew.log"

    date > "${this_LOG}" && \
    
    export SUDO_ASKPASS="${this_HOME}/bin/askpass.sh"
    
    let count=0

    echo 
    echo "Running 'brew cleanup'" >> "${this_LOG}"
    brew cleanup 2>&1             >> "${this_LOG}"
    
    while [ ${count} -lt 3 ]; do
        echo                                              >> "${this_LOG}"
        echo "==> Running brew proceses - round ${count}" >> "${this_LOG}"
        echo "Starting 'brew update'"                     >> "${this_LOG}"
        brew update   2>&1                                >> "${this_LOG}"
        let exit_code+=${?}
        echo                                              >> "${this_LOG}"
        echo "Starting 'brew outdated'"                   >> "${this_LOG}"
        brew outdated 2>&1                                >> "${this_LOG}"
        let exit_code+=${?}
        echo                                              >> "${this_LOG}"
        echo "Starting 'brew upgrade'"                    >> "${this_LOG}"
        brew upgrade --force 2>&1                         >> "${this_LOG}"
        let exit_code+=${?}
        echo                                              >> "${this_LOG}"
        echo "Starting 'brew outdated --cask'"            >> "${this_LOG}"
        brew outdated --cask 2>&1                         >> "${this_LOG}"
        let exit_code+=${?}
        echo                                              >> "${this_LOG}"
        echo "Starting 'brew upgrade --cask'"             >> "${this_LOG}"
        brew upgrade --cask --force  2>&1                 >> "${this_LOG}"
        let exit_code+=${?}
    
        if [ ${exit_code} -ne ${SUCCESS} ]; then
            let count+=1
            let exit_code=${SUCCESS}
        else
            break
        fi
    
    done
    
    echo "==> Brew upgrade processes completed" >> "${this_LOG}"
else
    echo "==> Argument must be a valid user name" >&2
fi

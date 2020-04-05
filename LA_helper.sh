#!/bin/bash
#set -x

SUCCESS=0
ERROR=1

let exit_code=${SUCCESS}

this_hour=""
this_minute=""
this_weekday=""

brew_upgrade_launchagent="${HOME}/Library/LaunchAgents/LaunchAgent_brew-upgrade.plist"

# Establish ~/bin/askpass.sh if it doesn't exist
if [ ! -e "${HOME}/bin/askpass.sh" ]; then
    local_password=""

    while [ -z "${local_password}" ]; do
        echo -ne "Please enter your password for this computer: "
        stty -echo
        read local_password
        stty echo
    done

    local_password_base64=$(echo "${local_password}" | base64)

    cp askpass.sh "${HOME}/bin"
    chmod 700 "${HOME}/bin/askpass.sh"
    sed -i -e "s|^b64_pass=.*$|b64_pass=\"${local_password_base64}\"|g" "${HOME}/bin/askpass.sh"
    echo
fi

# Create the LaunchAgent if it doesn't exist
if [ ! -e "${brew_upgrade_launchagent}" ]; then

    while [ "${this_hour}" = "" ]; do
        clear
        echo "Creating LaunchAgent '${brew_upgrade_launchagent}'"
        echo "Valid hours of the day are 0 (midnight) to 23 (eleven PM)"
        read -p "Enter the hour of the day you would like to run 'brew_upgrade.sh' " this_hour
        this_hour=$(echo "${this_hour}" | sed -e 's|[^0-9]||g')
    
        let status_code=$(echo "0<=${this_hour}" | bc 2> /dev/null)
        let status_code+=$(echo "${this_hour}<=23" | bc 2> /dev/null)
    
        if [ ${status_code} -lt 2 ]; then
            this_hour=""
            echo "Invalid hour of the day"
            sleep 3
        else
            let hour=${this_hour}
        fi
    
    done
    
    while [ "${this_minute}" = "" ]; do
        clear
        echo "Creating LaunchAgent '${brew_upgrade_launchagent}'"
        echo "Valid minutes of the day are 0 (on the hour) to 59 minutes past the hour"
        read -p "Enter the minute of the day you would like to run 'brew_upgrade.sh' " this_minute
        this_minute=$(echo "${this_minute}" | sed -e 's|[^0-9]||g')
    
        let status_code=$(echo "0<=${this_minute}" | bc 2> /dev/null)
        let status_code+=$(echo "${this_minute}<=59" | bc 2> /dev/null)
    
        if [ ${status_code} -lt 2 ]; then
            this_minute=""
            echo "Invalid minute of the day"
            sleep 3
        else
            let minute=${this_minute}
        fi
    
    done
    
    while [ "${this_weekday}" = "" ]; do
        clear
        echo "Creating LaunchAgent '${brew_upgrade_launchagent}'"
        echo "Valid values for weekday are 0 (Sunday) through 6 (Saturday).  You can also use 7 for Sunday"
        read -p "Enter the day of the week you would like to run 'brew_upgrade.sh' " this_weekday
        this_weekday=$(echo "${this_weekday}" | sed -e 's|[^0-9]||g')
    
        let status_code=$(echo "0<=${this_weekday}" | bc 2> /dev/null)
        let status_code+=$(echo "${this_weekday}<=7" | bc 2> /dev/null)
    
        if [ ${status_code} -lt 2 ]; then
            this_weekday=""
            echo "Invalid weekday value"
            sleep 3
        else
            let weekday=${this_weekday}
        fi
    
    done

    sed -e "s|{{HOME}}|${HOME}|g" -e "s|{{USER}}|${USER}|g" -e "s|{{HOUR}}|${hour}|g" -e "s|{{MINUTE}}|${minute}|g" -e "s|{{WEEKDAY}}|${weekday}|g" ./launchagent.template > "${brew_upgrade_launchagent}"
    let exit_code=${?}

    if [ ${exit_code} -ne ${SUCCESS} ]; then
        echo "  Failed to create LaunchAgent '${brew_upgrade_launchagent}'"
    fi

else
    echo "  LaunchAgent '${brew_upgrade_launchagent}' already exists.  Remove it then run 'make launchagent' again."
    let exit_code=${ERROR}
fi

# Load the LaunchAgent if it is unloaded
if [ ${exit_code} -eq ${SUCCESS} ]; then
    launchagent_label=$(egrep -A1 "Label" ./launchagent.template | sed -e 's|</string>|<string>|g' | awk -F'<string>' '/\<string\>/ {print $(NF-1)}')
    let launchagent_exists=$(launchctl list | egrep -c "\b${launchagent_label}\b")
    
    if [ ${launchagent_exists} -eq 0 ]; then
        echo "  Loading LaunchAgent '${brew_upgrade_launchagent}' with label '${launchagent_label}'"
        launchctl load "${brew_upgrade_launchagent}"
        let launchagent_exists=$(launchctl list | egrep -c "\b${launchagent_label}\b")
    
        if [ ${launchagent_exists} -gt 0 ]; then
            echo "SUCCESS"
        else
            echo "  Failed to load LaunchAgent '${brew_upgrade_launchagent}'"
            let exit_code=${ERROR}
        fi
    
    else
        echo "  Launchctl job '${launchagent_label}' already exists"
        echo "  Run 'launchctl unload ${brew_upgrade_launchagent}' then run 'make launchagent' agein."
        let exit_code=${ERROR}
    fi

fi

exit ${exit_code}

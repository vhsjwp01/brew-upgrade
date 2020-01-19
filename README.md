# brew-upgrade
A simple shell script to keep `brew` based Formulae and Cask installations up to date

### Prerequisites
* A working MacOS with brew

### Installation
```
prompt$> make install
```

Installs as `~/bin/brew_upgrade.sh`

### Usage
* The most effective way to leverage this script is through a LaunchAgent
  * You can interactively create a LaunchAgent from within this repo with:
```
prompt$> make launchagent
```
* However, it can also be invoked from the command line:
```
prompt$> ~/bin/brew_upgrade.sh
```
* A log of it's operations will be created here: `~/brew.log`
  * the log file is over written each time the script is executed

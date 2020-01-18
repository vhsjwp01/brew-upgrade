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
* You can create a LaunchAgent with:
```
prompt$> make launchagent
```

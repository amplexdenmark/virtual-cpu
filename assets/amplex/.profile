# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

PATH="$HOME/bin:$PATH"
#source <(/amplex/virtcpu/install/root/usr/bin/virtcpu env | \
#         awk '/^[A-Z_]+=/ {split($0,X,"="); print "export " X[1] "=\047" substr($0, length(X[1])+2) "\047"}')

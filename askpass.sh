#!/bin/bash
PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"
TERM="vt100"
export TERM PATH

stty_orig=$(stty -g)
stty -echo

b64_pass=
echo "${b64_pass}" | base64 -D

stty ${stty_orig}

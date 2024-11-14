#!/bin/bash


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


readonly OPTION_START="start"
readonly OPTION_STOP="stop"
readonly OPTION_SSH="ssh"
readonly OPTION_SSH_TUNNEL="ssh-tunnel"
readonly OPTION_DELETE="remove"


select o in "$OPTION_START" "$OPTION_SSH" "$OPTION_SSH_TUNNEL" "$OPTION_STOP" "$OPTION_DELETE"; do
    case "$o" in
        "$OPTION_START" )
            vagrant validate
            vagrant up
            break;;
        "$OPTION_SSH" )
            vagrant ssh
            break;;
        "$OPTION_SSH_TUNNEL" )
            vagrant ssh -- -L 7999:localhost:7999
            break;;
        "$OPTION_STOP" )
            vagrant halt
            break;;
        "$OPTION_DELETE" )
            vagrant destroy -f
            break;;
    esac
done

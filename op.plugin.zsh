# For `op signin`, override the command to set the profile variable in the
# shell.
#
# For `op get totp <item>`, override the command to copy the token to the
# clipboard, so it can be pasted with <Shift>-<Insert> to another command.

op() {
    local totp
    local rv

    if [[ $1 == signin ]]; then
        eval $(command op "$@")
        return $?
    fi

    if [[ $1 == get && $2 == totp ]]; then
        totp="$(command op "$@")"
        rv=$?

        if [[ $rv -gt 0 ]]; then
            return $rv
        fi

        printf '%s' "$totp" | xclip
        printf '%s\n' "$totp"
        return 0
    fi

    command op "$@"
}

# 1Password Sign In
#
# This function will run `op signin` with any supplied arguments and eval the
# command into the current shell.
function 1ps() {
    eval $(command op signin "$@")
    return $?
}

# 1Password Token Copy
#
# This function will run `op get topt` with the supplied arguments and copy
# the returned Time-based One-Time Password (TOTP) to the paste buffer using
# the `xclip` command.
function 1pt() {
    local totp ret
    totp="$(command op get totp "$@")"
    ret=$?

    if [[ $ret -gt 0 ]]; then
        return $ret
    fi

    printf '%s' "$totp" | xclip
    return 0
}



}

function _op_vaults() {
    local -a vaults=($(op list vaults 2>/dev/null | jq -r '.[] | .name'))
    _wanted 'vaults' expl 'vaults' compadd -a vaults
}

_op_global_flags=(
    '--account+[account to use when multiple sessions are active]:string'
    '--session+[raw session token obtained via '"'"'op signin --raw'"'"']:string'
)

local -a _op_commands=(
    'add:Add access for users or groups to groups or vaults'
    'confirm:Confirm a user'
    'create:Create an object'
    'delete:Remove an object'
    'edit:Edit an object'
    'encode:Encode the JSON needed to create an item'
    'forget:Remove a 1Password account from this device'
    'get:Get details about an object'
    'help:Help about any command'
    'list:List objects and events'
    'reactivate:Reactivate a suspended user'
    'remove:Revoke access for users or groups to groups or vaults'
    'signin:Sign in to your 1Password account'
    'signout:Sign out of your 1Password account'
    'suspend:Suspend a user'
    'update:Check for updates'
)

local -a _op_add_commands=(
    'group:Grant a group access to a vault'
    'user:Grant a user access to a vault or group'
)

local -a _op_create_commands=(
    'document:Create a document'
    'group:Create a group'
    'item:Create a new item'
    'user:Create a new user'
    'vault:Create a new vault'
)

local -a _op_delete_commands=(
    'document:Move a document to the Trash'
    'group:Remove a group'
    'item:Move an item to the Trash'
    'trash:Empties the trash for a given vault'
    'user:Completely remove a user'
    'vault:Remove a vault'
)

local -a _op_edit_commands=(
    'group:Edit a group in your 1Password account'
    'user:Edit the name or travel mode state of a user'
)

local -a _op_get_commands=(
    'account:Get details about your account'
    'document:Download a document'
    'group:Get details about a group'
    'item:Get item details'
    'template:Get an item template'
    'totp:Get the one-time password for an item'
    'user:Get details about a user'
    'vault:Get details about a vault'
)

local -a _op_list_commands=(
    'documents:Get a list of documents'
    'events:Get a list of events from the Activity Log'
    'groups:Get the list of groups'
    'items:Get a list of items'
    'templates:Get the list of templates'
    'users:Get the list of users'
    'vaults:Get the list of vaults'
)

local -a _op_remove_commands=(
    'group:Revoke a group'"'"'s access to a vault'
    'user:Revoke a user'"'"'s access to a vault or group'
)

function _op_add() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for add]' \
        ': :->command' \
        '*:: :->args' \
        && ret=0

    case $state in
        (command)
            _describe -t commands command _op_add_commands && ret=0
            ;;
        (args)
            curcontext=${curcontext%:*}-$line[1]:

            case $line[1] in
                (group)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for group]' \
                        ':<group>:' \
                        ':<vault>:_op_vaults' \
                        && ret=0
                    ;;
                (user)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for user]' \
                        '--role+[Sets the <role> of the user in the group]:<role>' \
                        ':<user>:' \
                        '::<vault> | <group>:' \
                        && ret=0
                    ;;
            esac
            ;;
    esac

    return ret
}

function _op_confirm() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for confirm]' \
        '(--all)::<user>:' \
        '--all[Confirm all outstanding invited users]' \
        && ret=0

    return ret
}

function _op_create() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for create]' \
        ': :->command' \
        '*:: :->args' \
        && ret=0

    case $state in
        (command)
            _describe -t commands command _op_create_commands && ret=0
            ;;
        (args)
            curcontext=${curcontext%:*}-$line[1]:

            case $line[1] in
                (document)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for document]' \
                        '--tags+[<tags> is a comma-separated list of tags to be added to the document]:<tags>' \
                        '--title+[The <title> of corresponding item]:<title>' \
                        '--vault+[The <vault> to save the document into]:<vault>:_op_vaults' \
                        ':<file_name>:_files' \
                        && ret=0
                    ;;
                (group)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for group]' \
                        '--description+[Set the new group'"'"'s description]:string' \
                        ':<name>:' \
                        && ret=0
                    ;;
                (item)
                    local -a items=(
                        'Login'        'Bank\ Account'   'Membership'       'Server'
                        'Secure\ Note' 'Database'        'Outdoor\ License' 'Social\ Security\ Number'
                        'Credit\ Card' 'Driver\ License' 'Passport'         'Software\ License'
                        'Identity'     'Email\ Account'  'Reward\ Program'  'Wireless\ Router'
                    )
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for item]' \
                        '--tags+[<tags> is a comma separated list of tags to be added to the item]:<tags>' \
                        '--title+[The <title> of corresponding item]:<title>' \
                        '--url+[The <url> that should be associated with this item]:<url>' \
                        '--vault+[The <vault> to save the item into]:<vault>:_op_vaults' \
                        ":<category>:(($^^items))" \
                        ':<encoded_item>:' \
                        && ret=0
                    ;;
                (user)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for user]' \
                        '--language+[Set the user'"'"'s account <language> (default "en")]:<language>' \
                        ':<email_address>:' \
                        ':<name>:' \
                        && ret=0
                    ;;
                (vault)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for vault]' \
                        '--allow-admins-to-manage+[Allows or disallows admins to manage this vault]:<true|false>:((true false))' \
                        '--description+[A description for the vault]:string' \
                        ':<name>:' \
                        && ret=0
                    ;;
            esac
            ;;
    esac

    return ret
}

function _op_delete() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for delete]' \
        ': :->command' \
        '*:: :->args' \
        && ret=0

    case $state in
        (command)
            _describe -t commands command _op_delete_commands && ret=0
            ;;
        (args)
            curcontext=${curcontext%:*}-$line[1]:

            case $line[1] in
                (document)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for document]' \
                        '--vault+[Specify the <vault> to delete the document from]:<vault>:_op_vaults' \
                        ':document:' \
                        && ret=0
                    ;;
                (group)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for group]' \
                        ':group:' \
                        && ret=0
                    ;;
                (item)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for item]' \
                        '--vault+[Specify the <vault> to delete the item from]:<vault>:_op_vaults' \
                        ':<item>:' \
                        && ret=0
                    ;;
                (trash)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for trash]' \
                        ':<vault>:_op_vaults' \
                        && ret=0
                    ;;
                (user)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for user]' \
                        ':<user>:' \
                        && ret=0
                    ;;
                (vault)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for vault]' \
                        '1:<vault>:_op_vaults' \
                        && ret=0
                    ;;
            esac
            ;;
    esac

    return ret
}

function _op_edit() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for edit]' \
        ': :->command' \
        '*:: :->args' \
        && ret=0

    case $state in
        (command)
            _describe -t commands command _op_edit_commands && ret=0
            ;;
        (args)
            curcontext=${curcontext%:*}-$line[1]:

            case $line[1] in
                (group)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for group]' \
                        '--description+[The new description of the group]:string' \
                        '--name+[The new <name> of the group]:<name>' \
                        ':<group>:' \
                        && ret=0
                    ;;
                (user)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for user]' \
                        '--name+[Set the name of the user to to <name>]:<name>' \
                        '--travelmode+[Enable or disable travel mode]:<on|off>:((on off))' \
                        ':<user>:' \
                        && ret=0
                    ;;
            esac
            ;;
    esac

    return ret
}

function _op_encode() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for encode]' \
        && ret=0

    return ret
}

function _op_forget() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for forget]' \
        ':<account>:' \
        && ret=0

    return ret
}

function _op_get() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for get]' \
        ': :->command' \
        '*:: :->args' \
        && ret=0

    case $state in
        (command)
            _describe -t commands command _op_get_commands && ret=0
            ;;
        (args)
            curcontext=${curcontext%:*}-$line[1]:

            case $line[1] in
                (account)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for account]' \
                        && ret=0
                    ;;
                (document)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for document]' \
                        '--include-trash[Include deleted documents]' \
                        '--output+[Save the document to <file path> instead of printing it to stdout]:<file path>:_files' \
                        '--vault+[Look for the document in this <vault>]:<vault>:_op_vaults' \
                        ':<document>:' \
                        && ret=0
                    ;;
                (group)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for group]' \
                        ':<group>:' \
                        && ret=0
                    ;;
                (item)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for item]' \
                        '--include-trash[Include items in the Trash]' \
                        '--share-link[Return a shareable link for the item]' \
                        '--vault+[Look for the item in <vault>]:<vault>:_op_vaults' \
                        ':<item>:' \
                        && ret=0
                    ;;
                (template)
                    local -a categories=(
                        'Login'        'Bank\ Account'   'Membership'       'Server'
                        'Secure\ Note' 'Database'        'Outdoor\ License' 'Social\ Security\ Number'
                        'Credit\ Card' 'Driver\ License' 'Passport'         'Software\ License'
                        'Identity'     'Email\ Account'  'Reward\ Program'  'Wireless\ Router'
                    )
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for template]' \
                        ":<category>:(($^^categories))" \
                        && ret=0
                    ;;
                (totp)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for totp]' \
                        '--vault+[Look for the item in <vault>]:<vault>:_op_vaults' \
                        ':<item>:' \
                        && ret=0
                    ;;
                (user)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for user]' \
                        '--fingerprint[If set, returns the user'"'"'s public key fingerprint]' \
                        '--publickey[If set, returns the user'"'"'s public key]' \
                        ':<user>:' \
                        && ret=0
                    ;;
                (vault)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for vault]' \
                        ':<vault>:_op_vaults' \
                        && ret=0
                    ;;
            esac
            ;;
    esac

    return ret
}

function _op_help() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for help]' \
        ': :->command' \
        '*:: :->args' \
        && ret=0

    case $state in
        (command)
            _describe -t commands command _op_commands && ret=0
            ;;
        (args)
            curcontext=${curcontext%:*}-$line[1]:

            case $line[1] in
                (add) _describe -t commands command _op_add_commands && ret=0 ;;
                (create) _describe -t commands command _op_create_commands && ret=0 ;;
                (delete) _describe -t commands command _op_delete_commands && ret=0 ;;
                (edit) _describe -t commands command _op_edit_commands && ret=0 ;;
                (get) _describe -t commands command _op_get_commands && ret=0 ;;
                (list) _describe -t commands command _op_list_commands && ret=0 ;;
                (remove) _describe -t commands command _op_remove_commands && ret=0 ;;
            esac
            ;;
    esac

    return ret
}

function _op_list() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for list]' \
        ': :->command' \
        '*:: :->args' \
        && ret=0

    case $state in
        (command)
            _describe -t commands command _op_list_commands && ret=0
            ;;
        (args)
            curcontext=${curcontext%:*}-$line[1]:

            case $line[1] in
                (documents)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for documents]' \
                        '--include-trash[Include documents in the Trash]' \
                        '--vault+[List documents in <vault>]:<vault>:_op_vaults' \
                        && ret=0
                    ;;
                (events)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for events]' \
                        '--eventid+[Return the events after the event with ID <event_ID>]:<event_ID>' \
                        '--older[Return the events *before* the event with ID <event_ID>]' \
                        && ret=0
                    ;;
                (groups)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for groups]' \
                        '--vault+[List groups who have direct access to <vault>]:<vault>:_op_vaults' \
                        && ret=0
                    ;;
                (items)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for items]' \
                        '--include-trash[Include items in the Trash]' \
                        '--vault+[List items in <vault>]:<vault>:_op_vaults' \
                        && ret=0
                    ;;
                (templates)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for templates]' \
                        && ret=0
                    ;;
                (users)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for users]' \
                        '--group+[List users who belong to <group>]:<group>' \
                        '--vault+[List users who have direct access to <vault>]:<vault>:_op_vaults' \
                        && ret=0
                    ;;
                (vaults)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for vaults]' \
                        '--group+[List vaults <group> has access to]:<group>' \
                        && ret=0
                    ;;
            esac
            ;;
    esac

    return ret
}

function _op_reactivate() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for reactivate]' \
        ':<user>:' \
        && ret=0

    return ret
}

function _op_remove() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for remove]' \
        ': :->command' \
        '*:: :->args' \
        && ret=0

    case $state in
        (command)
            _describe -t commands command _op_remove_commands && ret=0
            ;;
        (args)
            curcontext=${curcontext%:*}-$line[1]:

            case $line[1] in
                (group)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for group]' \
                        ':<group>:' \
                        ':<vault>:_op_vaults' \
                        && ret=0
                    ;;
                (user)
                    _arguments -S \
                        $_op_global_flags[@] \
                        '(- *)'{-h,--help}'[help for user]' \
                        ':<user>:' \
                        '::<vault> | <group>:' \
                        && ret=0
                    ;;
            esac
            ;;
    esac

    return ret
}

function _op_signin() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for signin]' \
        '(-r --raw)'{-r,--raw}'[output the raw session token]' \
        '--shorthand+[use <name> as short account name for new account]:<name>' \
        '::<sign_in_address>:' \
        '::<email_address>:' \
        '::<secret_key>:' \
        && ret=0

    return ret
}

function _op_signout() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for signout]' \
        '--forget[removes the account from the local configuration file]' \
        && ret=0

    return ret
}

function _op_suspend() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for suspend]' \
        ':user:' \
        && ret=0

    return ret
}

function _op_update() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -S \
        $_op_global_flags[@] \
        '(- *)'{-h,--help}'[help for update]' \
        && ret=0

    return ret
}

function _op() {
    local context state state_descr line ret=1
    typeset -A opt_args

    if [[ $service == op ]]; then
        _arguments -C \
            $_op_global_flags[@] \
            '(- *)'{-h,--help}'[help for command]' \
            '(-): :->command' \
            '(-)*:: :->args' && return

        case $state in
            (command)
                _describe -t commands command _op_commands && ret=0
                ;;
            (args)
                curcontext=${curcontext%:*:*}:op_$words[1]:
                if ! _call_function ret _op_$words[1]; then
                    _message "unknown sub-command: $words[1]"
                fi
                ;;
        esac
    fi

    return ret
}
compdef _op op

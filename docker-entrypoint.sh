#!/bin/bash
set -e
test ! -z "$DEBUG" && set -x

dc_ip_address() {
    _domain="$1"
    dig A +short $(dig -t SRV _ldap._tcp.dc._msdcs."$_domain" +short | cut -d' ' -f4) | \
        head -n 1
}

main() {
    _username="$1"
    [[ -z "$_username" ]] && echo "Username is required" && exit 100

    _domain="$2"
    [[ -z "$_domain" ]] && echo "Domain is required. Try office.share.org" && exit 100

    _ip_address=$(dc_ip_address "$_domain")
    echo "Please enter password"
    printf ">"
    read -s ORIGINAL_PASSWORD
    printf "\n"

    if [[ -z "$ORIGINAL_PASSWORD" ]]
    then
        echo "Blank password is invalid"
        exit 1
    fi

    for i in {5..30}
    do
        # dynamically create variables, with dynamic values
        # This is probably stupidly "clever", but it works for now.
        declare "PASSWORD${i}=${i}${ORIGINAL_PASSWORD}${i}"
        CURRENT_VARIABLE="PASSWORD${i}"
        LAST_VARIABLE_INDEX="$((i-1))"
        LAST_VARIABLE="PASSWORD${LAST_VARIABLE_INDEX}"
        CURRENT_VARIABLE_VALUE="${!CURRENT_VARIABLE}"
        LAST_VARIABLE_VALUE="${!LAST_VARIABLE}"

        if [[ -z  $LAST_VARIABLE_VALUE  ]]; then
            echo "Changing password from ORIGINAL_PASSWORD to ${i} + ORIGINAL_PASSWORD + ${i}"
           (echo "${ORIGINAL_PASSWORD}"; echo "${CURRENT_VARIABLE_VALUE}"; echo "${CURRENT_VARIABLE_VALUE}") | /usr/bin/smbpasswd -U scoffman -r "$_ip_address"
        else
            echo "Changing password from last password to ${i} + ORIGINAL_PASSWORD + ${i}"
           (echo "${LAST_VARIABLE_VALUE}"; echo "${CURRENT_VARIABLE_VALUE}"; echo "${CURRENT_VARIABLE_VALUE}") | /usr/bin/smbpasswd -U scoffman -r "$_ip_address"
        fi

    done
    echo "Setting it back to ORIGINAL_PASSWORD from ${i} + ORIGINAL_PASSWORD + ${i}"
   (echo "${CURRENT_VARIABLE_VALUE}"; echo "${ORIGINAL_PASSWORD}"; echo "${ORIG_PASSWORD}") | /usr/bin/smbpasswd -U scoffman -r "$_ip_address"

}

main "$@"

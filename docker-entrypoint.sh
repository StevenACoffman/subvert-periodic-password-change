#!/bin/bash
set -e
test ! -z "$DEBUG" && set -x

dcDOMAIN_IP_ADDRESS() {
    DOMAIN="$1"
    dig A +short $(dig -t SRV _ldap._tcp.dc._msdcs."$DOMAIN" +short | cut -d' ' -f4) | \
        head -n 1
}

main() {
    USERNAME="$1"
    [[ -z "${USERNAME}" ]] && echo "Username is required" && exit 100

    DOMAIN="$2"
    [[ -z "${DOMAIN}" ]] && echo "Domain is required. Try office.share.org" && exit 100

    DOMAIN_IP_ADDRESS=$(dcDOMAIN_IP_ADDRESS "${DOMAIN}")
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
           (echo "${ORIGINAL_PASSWORD}"; echo "${CURRENT_VARIABLE_VALUE}"; echo "${CURRENT_VARIABLE_VALUE}") | /usr/bin/smbpasswd -U "${USERNAME}" -r "${DOMAIN_IP_ADDRESS}"
        else
            echo "Changing password from last password to ${i} + ORIGINAL_PASSWORD + ${i}"
           (echo "${LAST_VARIABLE_VALUE}"; echo "${CURRENT_VARIABLE_VALUE}"; echo "${CURRENT_VARIABLE_VALUE}") | /usr/bin/smbpasswd -U "${USERNAME}" -r "${DOMAIN_IP_ADDRESS}"
        fi

    done
    echo "Setting it back to ORIGINAL_PASSWORD from ${i} + ORIGINAL_PASSWORD + ${i}"
   (echo "${CURRENT_VARIABLE_VALUE}"; echo "${ORIGINAL_PASSWORD}"; echo "${ORIG_PASSWORD}") | /usr/bin/smbpasswd -U "${USERNAME}" -r "${DOMAIN_IP_ADDRESS}"

}

main "$@"

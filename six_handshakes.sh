#!/usr/bin/env bash

set -e
[[ "${TRACE:-}" ]] && set -x

readonly token="$(cat .token)"

get_id() {

    # $1 - URL to get id
    local url="${1}"
    curl -s "https://api.vk.com/method/users.get?user_ids=${url}&access_token=${token}&v=5.80" | jq .response[0].id
}

main() {
    # $1 - First user url
    # $2 - Second user url
    local first_url="${1}" second_url="${2}"
    
    first_id="$(get_id "${first_url}")"
    second_id="$(get_id "${second_url}")"

    dir="${first_id}"
    [[ ! -d "${dir}" ]] && mkdir -p "${dir}"
    cd "${dir}"

    for i in {0..5}; do
        for current_raw_id in $(seq 1 "${i}" | xargs | sed 's|^|./|;s|[0-9]\+|*|g;s| |/|g;'); do
            current_raw_id="$(readlink -f "${current_raw_id}")"
            current_id="$(basename "${current_raw_id}")"
            array=($(curl -s "https://api.vk.com/method/friends.get?user_id=${current_id}&access_token=${token}&v=5.80" | jq -r '.response.items | .[]' || continue))
            if [[ "${array}" ]]; then
                cd "${current_raw_id}"
                mkdir "${array[@]}"
                cd - &>/dev/null
            fi

                if find . -type d -name "${second_id}" | grep '.*'; then
                    return
                fi
                
        done
     done
        
}

main "$@"

#! /bin/bash

set -eux

router_name="main-vpc-router"
zone="is1b"

get_ips() {
    local domain="$1"
    dig +short "$domain" A | while read -r line; do
        if [[ "$line" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
            # ipv4
            echo "$line"
        else
            # cname
            get_ips "$line"
        fi
    done

: <<'COMMENT_OUT'
    # vpc-router (standard) doesn't support ipv6
    dig +short "$domain" AAAA | while read -r line; do
        if [[ "$line" =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]; then
            # ipv6
            echo "$line"
        else
            # cname
            get_ips "$line"
        fi
    done
COMMENT_OUT
}

make_parameters() {
    local json='{ "RouterSetting": { "FireWall": [ { "Send": [] } ] } }'
    for domain in "$@"; do
        ips="$(get_ips "$domain" | uniq)"
        for ip in $ips; do
            json="$(echo "$json" | jq '.RouterSetting.FireWall[0].Send += [{ "Action": "deny", "Logging": false, "Description": "'"$domain"'", "Protocol": "ip", "DestinationNetwork": "'"$ip"'" }]')";
        done
    done
    echo "$json"
}

usacloud vpc-router update-standard "$router_name" -y --zone "$zone" --parameters "$(make_parameters "$@")"


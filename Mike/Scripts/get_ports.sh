#!/bin/bash

if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "\nUsage: $0 [nmap file] [output directory]"
    exit 1
fi

nmap_scan="$1"
output_dir="$2"

awk '!/#/ && /open/ {split($0, arr, "/"); printf "%s,", arr[1]}' "$nmap_scan" | sed 's/,$//' >"${output_dir}/ports"

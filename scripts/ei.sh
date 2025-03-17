#!/bin/bash

# Better way to configure network interfaces

networkctl --no-legend | awk '{print $2}' | fzf \
    --preview 'file=$(ls /etc/systemd/network/[0-9][0-9]-{}.network 2>/dev/null); [ -n "$file" ] && cat "$file" || echo "No config file exists"' \
    --bind 'enter:execute(
        file=$(ls /etc/systemd/network/[0-9][0-9]-{}.network 2>/dev/null);
        if [ -n "$file" ]; then
            nvim "$file";
        else
            echo "The file does not exist, would you like to create it? (y/n)";
            read -r answer;
            if [ "$answer" = "y" ]; then
                num=$(ls /etc/systemd/network/*.network 2>/dev/null | grep -o "^[0-9]\+" | sort -n | tail -n1);
                [ -z "$num" ] && num=19 || num=$((num + 1));
                new_file="/etc/systemd/network/$(printf "%02d" $num)-{}.network";
                nvim "$new_file";
            fi;
        fi)+abort'

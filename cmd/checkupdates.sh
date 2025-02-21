#!/bin/bash


echo -e "\nChecking available updates\n"

yay -Qqu | while read pkg; do
    repo=$(pacman -Si "$pkg" 2>/dev/null | awk -F ': ' '/^Repository/ {print $2}')
    version=$(pacman -Qi "$pkg" 2>/dev/null | awk -F ': ' '/^Version/ {print $2}')
    new_version=$(yay -Si "$pkg" 2>/dev/null | awk -F ': ' '/^Version/ {print $2}')
    printf "%-20s %-16s -> %s\n" "$repo/$pkg" "$version" "$new_version"
done | sort -k1,1 -t/ -s -k1,1b | awk '
    /^core\// { print "1 " $0; next }
    /^extra\// { print "2 " $0; next }
    { print "3 " $0 }
' | sort -k1,1n | cut -d' ' -f2-


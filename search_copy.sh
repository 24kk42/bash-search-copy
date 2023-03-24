#!/bin/bash
function search_files() {
    local dir=$1
    local keyword=$2
    local found_folder=$3
    
    for file in "$dir"/*;do
        if [ -f "$file" ] && [ "$(basename "$(dirname "$file")")" != "Found" ]; then
            if grep -q "$keyword" "$file"; then
                if [ ! -d "$found_folder" ]; then
                    mkdir "$found_folder"
                fi
                found_file="${found_folder}/found_$(basename $file)"
                cp "$file" "$found_file"
            fi
        elif [ -d "$file" ]; then
            search_files "$file" "$keyword" "$found_folder"
        fi
    done
}

function show_modification_details() {
    local found_dir=$1
    local modification_file="${found_dir}/modification_details.txt"
    touch "$modification_file"
    for file in "${found_dir}"/found_*;do
        if [ -f "$file" ]; then
            file_num=$(basename "$file" | cut -d'_' -f2 | cut -d'.' -f1)
            modification=$(stat -c "$(basename "$file") was modified by %U on %x at %X." "$file")
            echo "${file_num^}: ${modification}" | sed -e 's/^/ /' >> "$modification_file"
            echo "${file_num^}: ${modification}" | sed -e 's/^/ /'
        fi
    done
}

read -p "Enter the name of the directory: " dir_name
read -p "Enter the keyword: " keyword

found_folder="${dir_name}/Found"
search_files "$dir_name" "$keyword" "$found_folder"
if [ -d "$found_folder" ]; then
    echo "Files were copied to the Found directory!"
    ls -1 "$found_folder"
    echo ""
    show_modification_details "$found_folder"
else
    echo "Keyword not found in files!"
fi
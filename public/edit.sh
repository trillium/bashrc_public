BASHPROFILE_DIR=${BASHPROFILE_DIR}

function edit() {
    file_array=("${(@s/ /)loaded_files}")
    # Split the array into two arrays for the two columns
    file_array1=("${file_array[@]##*/Users/trilliumsmith/bashrc_dir}")
    file_array2=("${file_array[@]##*/Users/trilliumsmith/bashrc_dir}")
    half=$(((${#file_array[@]}+1)/2))
    file_array1=("${file_array1[@]:0:$half}")
    file_array2=("${file_array2[@]:$half}")

    # Use a while loop to create a custom selection menu
    while true; do
        for ((i=1; i<=${#file_array1[@]}; i++)); do
            printf "%2d) %-30s" $i "${file_array1[i]}"
            if [[ $i -le ${#file_array2[@]} ]]; then
                printf "%2d) %-30s" $((i+half)) "${file_array2[i]}"
            fi
            echo
        done
        # printf " %1s) Quit" "q"
printf " %-1s) %-30s" "q" "Quit"
printf " %-1s) %-30s\n" "w" "Open Workspace"q
        echo "Please select a file:"

        echo -n "Enter your selection: "
        read selection

        if [[ $selection == "q" ]]; then
            echo "Exiting..."
            break
        elif [[ $selection == "w" ]]; then
            echo "Opening .bashrc workspace at $BASHPROFILE_DIR"
            code "$BASHPROFILE_DIR"
            break
        elif [[ $selection -ge 1 ]] && [[ $selection -le ${#file_array[@]} ]]; then
            file=${file_array[$selection]##*/Users/trilliumsmith/bashrc_dir}
            echo "Editing $file"
            code /Users/trilliumsmith/bashrc_dir$file
            break
        else
            echo "Invalid selection"
        fi
    done
}
function edit() {
    file_array=("${(@s/ /)loaded_files}")
    # Use the select command to create a selection list
    echo "Please select a file:"
    select file in "${file_array[@]##*/Users/trilliumsmith/bashrc_dir}"; do
    if [[ -n $file ]]; then
        echo "Editing $file"
        code /Users/trilliumsmith/bashrc_dir$file
        break
    else
        echo "Invalid selection"
    fi
    done
}
# test bash rename git command
function do_find() {
  for file in *.js                                                 
  do
          if [[ "${file}" == *"test"* ]]
          then
            echo ❌ "${file}" "${file%.js}.jsx"
            continue
          fi
          # git mv "$file" "${file%.js}.jsx"
          echo ✅ "${file}" ' --> ' "${file%.js}.jsx"

  done
  # echo "did a rename from .js to .jsx"
}

function do_replace() {
  for file in *.js                                                 
  do
          if [[ "${file}" == *"test"* ]]
          then
            echo ❌ "${file}" "${file%.js}.jsx"
            continue
          fi
          git mv "$file" "${file%.js}.jsx"
          echo ✅ "${file}" ' --> ' "${file%.js}.jsx"

  done
  # echo "did a rename from .js to .jsx"
}

# export -f not needed in zsh —do_replace
# export -f not needed in zsh —do_find
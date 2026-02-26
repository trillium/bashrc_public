TALON_REPL_PATH=${TALON_REPL_PATH}

function num_to_word() {
    if [ -z "$1" ]; then
        echo
    fi

    declare -a units=("one" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten")
    declare -a teens=("ten" "eleven" "twelve" "thirteen" "fourteen" "fifteen" "sixteen" "seventeen" "eighteen" "nineteen")
    declare -a tens=("twenty" "thirty" "forty" "fifty" "sixty" "seventy" "eighty" "ninety")

    if (( $1 <= 10 )); then
        echo ${units[$1]}
    elif (( $1 < 20 )); then
        echo ${teens[$1-10+1]}
    else
        if (( $1 % 10 == 0 )); then
            echo ${tens[$1/10-1]}
        else
            echo ${tens[$1/10-1]} ${units[$1%10]}
        fi
    fi
}
alias n=num_to_word

function has_numeric_values() {
    if [[ $1 =~ [0-9] ]]; then
        return 0 # true
    else
        return 1 # false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  222,,n                                             2222   3
    fi
}

# export -f not needed in zsh —has_numeric_values
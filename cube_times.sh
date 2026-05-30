#!/bin/bash
set -euo pipefail
separator() {
    printf '%0.s-' {1..80}
    echo
}

greet() {
    separator
    echo -e "\e[31mWELCOME\e[0m"
    separator
}

std_error() {
echo "Invalid input" >&2
}

ordinal() {
    local n=$1
    if (( n % 100 >= 11 && n % 100 <= 13 )); then
        echo "${n}th"
    else
        case $((n % 10)) in
            1) echo "${n}st" ;;
            2) echo "${n}nd" ;;
            3) echo "${n}rd" ;;
            *) echo "${n}th" ;;
        esac
    fi
}

greet
dir="$HOME/cube_timers_dir"
mkdir -p "$dir"
cd "$dir" || exit 1

read_number() {
    local prompt=$1
    local value

    while true; do
        read -rp "$prompt" value

        [[ $value =~ ^[0-9]+$ ]] && {
            printf '%s\n' "$value"
            return
        }

        std_error
    done
}

display() {
    shopt -s nullglob
    local sessions=(session_*)
    shopt -u nullglob

    if (( ${#sessions[@]} )); then
        separator
        echo "Available sessions:"
        separator
        printf '%s\n' "${sessions[@]}"
        separator
    else
        echo "No sessions found"
    fi
}

comment_time() {
local solve_time=$1
local com
local file=$2

read -rp "Any comments? (n for none): " com
[[ $com == "n" ]] && com=""

printf '%s | %s\n' "$solve_time" "$com" >> "$file"
}

timer_mode() {
echo "Press any key to start" >&2
read -rsn1

local start
start=$(date +%s.%N)

echo "Timing... press any key to stop" >&2
read -rsn1

local end
end=$(date +%s.%N)

local elapsed
elapsed=$(echo "$end - $start" | bc -l)

printf "%.2f\n" "$elapsed"
}


manual_mode() {
local i=$1
local time
while true; do
	read -rp "$(ordinal "$i") solve time: " time
        if [[ "$time" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            echo "$time"
            return
        fi
        std_error
    done
}

scrambles() {
	local moves=(U D L R F B)
        local movers=("" "'" "2")
	local i
        for ((i=0;i<20;i++)); do
		printf "%s%s " \
            	"${moves[RANDOM % ${#moves[@]}]}" \
 	        "${movers[RANDOM % ${#movers[@]}]}"
    	done

        echo
}

session() {
local file=$1
sol_num=$(read_number "How many solves: ")
(( sol_num == 0 )) && return
for ((i=1; i<=sol_num; i++)); do
        while true; do
		scrambles
		read -rp "manual or timer mode or quit (m|t|q): " mode
		case "$mode" in
		m|M)   time=$(manual_mode "$i")
                        comment_time "$time" "$file"
                        break ;;
		t|T)   time=$(timer_mode)
                        echo "$(ordinal "$i") solve time: $time"
                        comment_time "$time" "$file"
                        break ;;
		q|Q) return ;;
		*) std_error && echo "usage (m|t|q)" ;;
		esac
        done
done
}

file_check() {
while true; do
	num=$(read_number "Which session: ")
	local file="session_$num"
	[[ -f "$file" ]]  && { echo "$file"; return; }
        echo "File does not exist"
done
}

old_session() {
local file
file=$(file_check)
session "$file"
}

stats() {
file=$(file_check)
total=0
count=0
best=""

while IFS="|" read -r time comment || [[ -n $time ]]; do
	time=${time//[[:space:]]/}
	[[ -z "$time" ]] && continue
	[[ "$time" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
        echo "Time: $time | Comment: $comment"
        total=$(bc <<< "$total + $time")
        ((count++))
        if [[ -z "$best" ]] || (( $(echo "$time < $best" | bc -l) )); then
        	best=$time
		echo "New PB!!!"
        fi
done < "$file"

separator
echo "Solves: $count"
echo "Best: $best"

if (( count == 0 )); then
	std_error
else
	echo "Average: $(echo "scale=2; $total / $count" | bc -l)"
fi
}

new_session() {
local num=$(read_number "Which session num: ")
local file="session_$num"

if [[ -f "$file" ]]; then
	std_error
        echo "This file already exists, use old session"
        return
fi

touch "$file"
session "$file"
}

main() {
    case "${1:-}" in
        new) new_session ;;
        old) old_session ;;
        stats) stats ;;
        list|display) display ;;
        "")
            echo "Usage: cube {new|old|stats|list}"
            ;;
        *)
            std_error
            echo "Unknown command: $1"
            ;;
    esac
}

main "$@"


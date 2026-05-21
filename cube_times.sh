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

    read -rp "Any comments? (n for none): " com

    [[ $com == "n" ]] && com=""

    printf '%s | %s\n' "$solve_time" "$com" >> "$file"
}
timer_mode() {
    local start
    local end
    local elapsed

    echo "Press any key to start"
    read -rsn1

    start=$(date +%s.%N)

    echo "Timing... press any key to stop"
    read -rsn1

    end=$(date +%s.%N)

    elapsed=$(echo "$end - $start" | bc -l)

    printf '%.2f\n' "$elapsed"
}
manual_mode() {
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
session() {
sol_num=$(read_number "How many solves: ")
for ((i=1; i<=sol_num; i++)); do
        while true; do
		read -p "manual or timer mode (m|t)" mode
		if [[ "$mode" == "t" ]]; then
			time=$(timer_mode)
			echo "$(ordinal "$i") solve time: $time"
			comment_time "$time"
			break
		elif [[ "$mode" == "m" ]]; then
                	time=$(manual_mode)
			comment_time "$time"
			break
		else
			std_error
		fi
        done
done
}
file_check() {
while true; do
	num=$(read_number "which session")
	file="session_$num"
	[[ -f "$file" ]] && return
        echo "File does not exist"

done
}
old_session() {
file_check
session
}

stats() {

file_check
total=0
count=0
best=999999
while IFS="|" read -r time comment; do
	time=$(echo "$time" | xargs)
        echo "Time: $time | Comment: $comment"
        total=$(echo "$total + $time" | bc)
        ((count++))
        if (( $(echo "$time < $best" | bc -l) )); then
            best=$time
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
num=$(read_number "which session num")
file="session_$num"
if [[ -f "$file" ]]; then
	std_error
        echo "This file already exists"
        return
    fi
touch "$file"
session
}

while true; do
	separator
	read -p "1- New, 2- Old, 3- Stats, 4- Exit, 5- display: " choice
	separator
	case "$choice" in
	1) new_session ;;
        2) old_session ;;
        3) stats ;;
       	4) echo "Happy cubing!" && exit 0 ;;
	5) display ;;
	*)std_error ;;
   	 esac
done

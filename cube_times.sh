#!/bin/bash
set -euo pipefail

greet() {
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "-------------------------------------------------------------------------\e[31mWELCOME\e[0m------------------------------------------------------------------------"
}

std_error() {
echo "Invalid input"
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
#wip
old_session() {
mkdir -p cube_times_dir && cd cube_times_dir
    while true; do
        read -p "How many new solves? " sol_num_new
        if [[ "$sol_num_new" =~ ^[0-9]+$ ]]; then
            for ((i=1; i<=sol_num_new; i++)); do
                while true; do
                    read -p "$(ordinal $i) solve time: " time
                    if [[ "$time" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                        read -p "Any comments? " com
                        if [[ "$com" != n ]]; then
                            echo "$time | $com" >> session_"$sol_num_new"
                        else
                            echo "$time | " >> session_"$sol_num_new"
                        fi
                        break
                    else
                        std_error
                    fi
                done
            done
            break
        else
            std_error
        fi
    done
}
#wip
stats() {
mkdir -p cube_times_dir && cd cube_times_dir
while true; do
	read -p "which session stats? " d_num
	if [[ -f session_"$d_num" ]]; then
		while IFS="|" read -r time comment; do
		echo "Time: $time"
		done < session_"$d_num"
		break
	else
		std_error
		echo "The file doesnt exist"
		exit 1
	fi
done
}
new_session ()  {

mkdir -p cube_times_dir && cd cube_times_dir

while true; do
	read -p "Session number: " num
        [[ "$num" =~ ^[0-9]+$ ]] && break || std_error
done
file="session_$num"
if [[ -f "session_$num" ]]; then
		std_error
                echo "This file already exist, use old option"
		return
else
	touch "$file"
fi
while true; do

	read -p "how many solves? " sol_num
	if [[ "$sol_num" =~ ^[0-9]+$ ]]; then
		break
	else
		std_error
	fi
done
for ((i=1; i<=sol_num; i++)); do
	while true; do
		read -p "$(ordinal $i) solve time: " time
		if [[ "$time" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
			read -p "Any comments? " com
			if [[ "$com" != n ]]; then
				echo "$time | $com"  >> session_"$num"
			else
				echo "$time | "  >> session_"$num"
			fi
			break
		else
			std_error
		fi
	done
done
}


#menu
read -p "1- New, 2- Old, 3- Stats, 4- Exit: " choice
    case "$choice" in
	 1) new_session ;;
         2) old_session ;;
         3) stats ;;
       	 4) echo "Happy cubing!"
            exit 0
            ;;
         *)
            std_error
            ;;
    esac

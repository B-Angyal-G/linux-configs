#!/bin/bash

today=$(date +"%m%d")

printed=0

while read -r name month day year
do
	act_birthday="${month}${day}"	

	# Összehasonlítás: pl.: "0320" "0102" stringek, ami automatikusan jól kezeli a dátumokat
	# Kell-e kiíni, hogy TODAY
	if [[ printed -eq 0 && "$act_birthday" > "$today" ]]; then
		echo -e "\n--- TODAY: $(date +"%m.%d.") --- \n"
		printed=1
	fi

	# Aktuális sor a file-ból	
	echo -n "$name"
	if [[ "${#name}" -le 7 ]];then
		echo -ne "\t"
	fi
	echo -e "\t"${month}"."${day}"."
done < "$(dirname "$0")/birthdates"

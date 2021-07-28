#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
	echo "Need exaclty two arguments, input and output!" >&2
	exit 1
fi

IN="$1"
OUT="$2"

touch "${OUT}"
truncate -s0 "${OUT}"

while read -r line
do
	larray=($line)
	X=${larray[2]}
	Y=${larray[3]}
	R=$(echo "$X / $Y" | bc -l)
	printf "%5.8f\n" $R >> "${OUT}"

done < "${IN}"

#!/bin/bash
# shell script to exctract all custom defined AMS theorem environments from
# a tex file, check for labels in these environments and then output 
# relations between these based on \refs not preceded by a % in the same
# line in the proof \subenvironments, while ignoring undefined labels/
# labels that have not been assigned to theorem environments
# The output will then be exported in Graph Modelling Language
#
# pi-bie - 10/Jan/2021

function usage {
    cat <<EOM
Usage: `basename $0` infile outfile
  Parameters:
   - infile:		specify tex input file here
   - outfile:		specify gml output file here

EOM
}

[ -z "$1" ] && { usage; exit 0;}

thmenvs=$(sed -E 's/\\newtheorem[*]{0,1}\{([a-z]+)\}.*$/\1/p;d' < $1)

declare -a relations
declare -A keyLabels

echo 'graph [ 
	comment "A graph showing the implications between theorems of '$1$'"
	directed 1' > $2
no=1

while IFS= read -r line; do
	splitter=$(echo '\\begin\{'"$line"'\}[ \n]*(\\cite(\[[a-z0-9 ~,.]+\])?\{[a-z0-9]+\})?[ \n]*(\\label\{([a-z:0-9]+)\})(.*?)')
	blocks=$(awk '/\\begin{'$line'}/{flag=1}/\\end{'$line'}/{print "\r";flag=0}flag' $1)
	IFS=$'\r' read -r -d '' -a entries <<< "$blocks"
	for block in "${entries[@]}"; do
		label=$(echo $block | tr "\n" " " | sed -En 's!.*'"$splitter"'!\4!pi')
		if [[ -n $label ]]; then
			proof=$(echo "$block" | awk '/\\begin{proof}/{y=1;next}y')
			foo=$(echo "$proof" | cut -d"%" -f1 | grep -Eo "\\\\ref{([a-Z:0-9]+)}" | cut -d"{" -f2 | cut -d"}" -f1)
			echo '	node [
		id '$no'
		label "'$label'"
		type "'$line'"
	]' >> $2
			relations[$no]=$foo
			keyLabels[$label]=$no
			((no++))
		fi
	done
done <<< "$thmenvs"

for i in `seq 1 $no`
do
	readarray -t refs <<< "${relations[i]}"
	for ref in ${refs[@]}
	do
		if [[ -n ${keyLabels[$ref]} ]]; then
			echo "	edge [
		source ${keyLabels[$ref]}
		target $i
	]" >> $2
		fi
	done
done
echo "]" >> $2

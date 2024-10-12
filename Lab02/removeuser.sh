#!/bin/bash

printhelp()
{
	echo "
Usage: $0 -i files ...

-i: Input files.
"
}

files=[]
onfile=false

while [ "$1" != "" ]
do
    case "$1" in
        -h)
            onfile=false
            printhelp
            exit 0
            ;;
        -i)
            onfile=true
            ;;
        *)
            if $onfile
            then
                files=$(echo "$files" | jq -c ". + [\"$1\"]")
            fi
            ;;
    esac
    shift
done

for ((i=0;i<$(echo "$files" | jq -c "length");i++))
do
    filename=$(echo "$files" | jq -cr ".[$i]")
    case "$(file -b $filename)" in
        "JSON data")
            for ((k=0; k<$(jq 'length' $filename); k++))
            do
                if [ "$(id $(jq -r ".[$k].username" $filename))" == "" ] || [ "$(jq -r ".[$k].username" $filename)" == "root" ]
                then
                    echo "Warning: user $(jq -r ".[$k].username" $filename) not exists."
                else
                    for ((j=0; j<$(jq ".[$k].groups | length" $filename); j++))
                    do
                        pw groupdel "$(jq -r ".[$k].groups[$j]" $filename)"
                    done
                    pw userdel -n "$(jq -r ".[$k].username" $filename)" -r
                fi
            done
            ;;
        "CSV text")
            while read line
            do
                if [ "$(id $(echo "$line" | awk -F, '{print $1}'))" == "" ] || [ "$(echo "$line" | awk -F, '{print $1}')" == "root" ]
                then
                    echo "Warning: user $(echo "$line" | awk -F, '{print $1}') not exists."
                else
                    for nowgroup in $(echo "$line" | awk -F, '{print $4}')
                    do
                        pw groupdel "$nowgroup"
                    done
                    pw userdel "$(echo "$line" | awk -F, '{print $1}')" -r
                fi
            done < <(sed '1d' $filename)
            ;;
        *)
            echo "Error: Invalid file format." 1>&2
            ;;
    esac
done

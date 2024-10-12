#!/bin/bash

a=$(printf "%d" 0x$(xxd -l 2 -ps /dev/urandom))
b=$(printf "%d" 0x$(xxd -l 2 -ps /dev/urandom))

echo "a = $a"
echo "b = $b"

ans=$(echo "$a
$b" | ./hw)

echo "your ans = $ans"

[ $(($a + $b)) -eq $ans ]


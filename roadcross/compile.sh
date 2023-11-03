#/bin/bash

clear
fbc roadcross.bas

if [ $? -eq 0 ] 
then
	#clear
	
	# xterm -e "./8; read"
	./roadcross
else
	exit 1
fi


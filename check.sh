#!/bin/bash
# Slackerc0de Family Present
# PayPal Validator v6
# By Malhadi Jr
# 2 February 2k17
#set -x
cat <<EOF
Recoded By:

          Sikampret - Apple Validator V1 2017
--------------------------------------------------------
Original By:
              - https://malhadijr.com -
           [+] malhadijr@slackerc0de.us [+]
--------------------------------------------------------

EOF

usage() {
  echo "Usage: ./myscript.sh COMMANDS: [-i <list.txt>] [-r <folder/>] [-l {1-1000}] [-t {1-10}] OPTIONS: [-d] [-c]

Command:
-i (20k-US.txt)     File input that contain email to check
-r (result/)        Folder to store the result live.txt and die.txt
-l (60|90|110)      How many list you want to send per delayTime
-t (3|5|8)          Sleep for -t when check is reach -l fold

Options:
-d                  Delete the list from input file per check
-c                  Compress result to compressed/ folder and
                    move result folder to haschecked/
-h                  Show this manual to screen

Report any bugs to: <Malhadi Jr> contact@malhadi.slackerc0de.us
"
  exit 1
}

# Assign the arguments for each
# parameter to global variable
while getopts ":i:r:l:t:g:dch" o; do
    case "${o}" in
        i)
            inputFile=${OPTARG}
            ;;
        r)
            targetFolder=${OPTARG}
            ;;
        l)
            sendList=${OPTARG}
            ;;
        t)
            perSec=${OPTARG}
            ;;
        d)
            isDel='y'
            ;;
        c)
            isCompress='y'
            ;;
        h)
            usage
            ;;
    esac
done

# Assign false value boolean
# to both options when it's null
if [ -z "${isDel}" ]; then
  isDel='n'
fi

if [ -z "${isCompress}" ]; then
  isCompress='n'
fi

SECONDS=0

# Asking user whenever the
# parameter is blank or null
if [[ $inputFile == '' ]]; then
  # Print available file on
  # current folder
  # clear
  # tree
  read -p "Enter mailist file: " inputFile
fi

if [[ $targetFolder == '' ]]; then
  read -p "Enter target folder: " targetFolder
  # Check if result folder exists
  # then create if it didn't
  if [[ ! -d "$targetFolder" ]]; then
    echo "[+] Creating $targetFolder/ folder"
    mkdir $targetFolder
  else
    read -p "$targetFolder/ folder are exists, append to them ? [y/n]: " isAppend
    if [[ $isAppend == 'n' ]]; then
      exit
    fi
  fi
else
  if [[ ! -d "$targetFolder" ]]; then
    echo "[+] Creating $targetFolder/ folder"
    mkdir $targetFolder
  fi
fi

if [[ $isDel == '' ]]; then
  read -p "Delete list per check ? [y/n]: " isDel
fi

if [[ $isCompress == '' ]]; then
  read -p "Compress the result ? [y/n]: " isCompress
fi

if [[ $sendList == '' ]]; then
  read -p "How many list send: " sendList
fi

if [[ $perSec == '' ]]; then
  read -p "Delay time: " perSec
fi


# Define curl function
malhadi_ppvalid () {
  RED='\033[0;31m'
  CYAN='\033[0;36m'
  YELLOW='\033[1;33m'
  ORANGE='\033[0;33m'
  BLUE='\033[0;34m'
  PURPLE='\033[0;35m'
  NC='\033[0m'
  GREEN='\033[0;32m'

 header="`date +%H:%M:%S` from $inputFile to $targetFolder"
 footer="[MANTAP]\n"

SECONDS=0
curl --silent 'http://server.69checker.com/api.php?email='$1 > /tmp/apple1

 if cat /tmp/apple1 | grep "LIVE" > /tmp/nothing; then
 printf "$2/$3. ${GREEN}LIVE => $1 ${NC}$footer"
    echo "[LIVE] $1" >> $4/live.txt
 else
 printf "$2/$3. ${RED}DIE => $1 ${NC}$footer"
    echo "$1" >> $4/die.txt
fi

  printf "\r"
}


# Preparing file list
# by using email pattern
# every line in $inputFile
echo "[+] Cleaning your mailist file"
grep -Eiorh '([[:alnum:]_.-]+@[[:alnum:]_.-]+?\.[[:alpha:].]{2,6})' $inputFile | sort | uniq > temp_list && mv temp_list $inputFile

# Finding match mail provider
echo "########################################"
# Print total line of mailist
totalLines=`grep -c "@" $inputFile`
echo "There are $totalLines of list."
echo " "
echo "Hotmail: `grep -c "@hotmail" $inputFile`"
echo "Yahoo: `grep -c "@yahoo" $inputFile`"
echo "Gmail: `grep -c "@gmail" $inputFile`"
echo "########################################"

# Extract email per line
# from both input file
listRemain=`wc -l $inputFile | cut -f1 -d' '`
while [[ $listRemain > 1 ]]; do
  IFS=$'\r\n' GLOBIGNORE='*' command eval  'mailist=($(cat $inputFile))'
  con=1
  echo "[+] Sending $sendList email per $perSec seconds"

  for (( i = 0; i < "${#mailist[@]}"; i++ )); do
    username="${mailist[$i]}"
    indexer=$((con++))
    tot=$((totalLines--))

    fold=`expr $i % $sendList`
    if [[ $fold == 0 && $i > 0 ]]; then
      header="`date +%H:%M:%S`"
      duration=$SECONDS
      printf "Waiting $perSec seconds. $(($duration / 3600)) hours $(($duration / 60 % 60)) minutes and $(($duration % 60)) seconds elapsed, ratio ${YELLOW}$sendList email${NC} / ${CYAN}$perSec seconds${NC}\n"
      sleep $perSec
    fi

    malhadi_ppvalid "$username" "$indexer" "$tot" "$targetFolder" &

    if [[ $isDel == 'y' ]]; then
      grep -v -- "$username" $inputFile > temp && mv temp $inputFile
    fi
  done

  if [[ $isDel == 'y' ]]; then
    listRemain=`wc -l $inputFile | cut -f1 -d' '`
  else
    listRemain=0
  fi

done

# waiting the background process to be done
# then checking list from garbage collector
# located on $targetFolder/unknown.txt
echo "[+] Waiting background process to be done"
wait
wc -l $targetFolder/*

if [[ $isCompress == 'y' ]]; then
  tgl=`date`
  tgl=${tgl// /-}
  zipped="$targetFolder-$tgl.zip"

  echo "[+] Compressing result"
  zip -r "compressed/$zipped" "$targetFolder/die.txt" "$targetFolder/live.txt"
  echo "[+] Saved to compressed/$zipped"
  mv $targetFolder haschecked
  echo "[+] $targetFolder has been moved to haschecked/"
fi
duration=$SECONDS
echo "Checking done in $(($duration / 3600)) hours $(($duration / 60 % 60)) minutes and $(($duration % 60)) seconds."
echo "+==========+ SiKampret +==========+"

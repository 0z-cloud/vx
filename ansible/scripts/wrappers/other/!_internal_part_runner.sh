#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;93m'
NC='\033[0m' # No Color

inventory=$1
product=$2
username=$3
password=$4
part_to_run=$5

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$username" ] || [ -z "$password" ] || [ -z "$part_to_run" ]; then

  echo "............................................................................................................................................................................."
  echo -e "            ${GREEN}Usage${NC}: ./!\_internal_part_runner.sh ${RED}inventory product username password playbook_to_run${NC}"
  echo "............................................................................................................................................................................."
  echo -e "         ${YELLOW}Examples${NC}:
                                ./\!_internal_part_runner.sh ${RED}develop vortex vortex 1235 percona${NC}
                                ./\!_internal_part_runner.sh ${RED}develop vortex vortex 1235 glusterfs${NC}"

  echo "............................................................................................................................................................................."

  exit

else 

  echo "............................................................................................................................................................................."
  echo -e "            ${GREEN}Passed to run${NC}: ./!\_internal_part_runner.sh $inventory $product $username PASSWORD $playbook_to_run"
  echo "............................................................................................................................................................................."

fi

list=`./\!_internal-services-recreate.sh ${inventory} ${product} ${username} ${password} true run_from_wrapper | grep ${part_to_run}`
escaped_list=`echo $list |sed 's/[!]/\\\!/g'`

test=`echo "${escaped_list}" | grep -E "\\!\_"  && echo 1 || echo 0`
echo "....."
echo "test $test"
echo "....."
echo "escaped $escaped_list"
echo "....."
echo "grepped $list"
echo "....."

if [[ "$test" == 1 ]]; then
    IFS='"\!_' in=($escaped_list)
    for item in "${in[@]}"; do
        eval $item
    done
else
    IFS='"\' in=($list)
    for item in "${in[@]}"; do
        eval $item
    done
fi
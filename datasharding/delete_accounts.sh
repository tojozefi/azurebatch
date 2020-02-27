#!/bin/bash
#Author: Tomasz Jozefiak (tojozefi@microsoft.com)
#Usage: ./delete_accounts.sh <saprefix> <n>

ENDDATE=$(date -u -d "1 month" '+%Y-%m-%dT%H:%M:%SZ')

function show_help {
	echo "Usage: ./delete_accounts.sh OPTIONS"
	echo "OPTIONS:"
	echo "-n, amount of storage accounts to delete" 
	echo "-g, resource group for storage accounts" 
	echo "--saprefix, blob storage account name prefix"
}


while [[ $# -gt 0 ]]
do
	i=$1
	case $i in
		-h) show_help; exit 0 ;;
		-n) N=$2 ; shift ;;
		-g) RG=$2 ; shift ;;
		--saprefix) SAPREFIX=$2; shift ;;
		*) echo "Unknown option $i"; show_help; exit 1;;
	esac
	shift
done

if [ -z ${N} ] || [ -z ${RG} ] || [ -z ${SAPREFIX} ]
then
	echo "Missing required option"; 
	show_help; 
	exit 1
fi

echo "Deleting ${N} storage accounts ${SAPREFIX}0-$((N-1)) in resource group [${RG}]..."
for ((i=0; i<${N}; i++))
do 
	echo "deleting storage account [${SAPREFIX}${i}]..."
	az storage account delete -n ${SAPREFIX}${i} -g ${RG} -y -o none
done

echo "done."


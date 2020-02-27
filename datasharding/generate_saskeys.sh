#!/bin/bash
#Author: Tomasz Jozefiak (tojozefi@microsoft.com)

ENDDATE=$(date -u -d "1 month" '+%Y-%m-%dT%H:%M:%SZ')

function show_help {
	echo "Usage: ./generate_saskeys.sh OPTIONS"
	echo "OPTIONS:"
	echo "-n, amount of storage accounts" 
	echo "-g, resource group with storage accounts" 
	echo "--saprefix, blob storage account name prefix"
	echo "--saskeyfile, SAS key file to generate"
}


while [[ $# -gt 0 ]]
do
	i=$1
	case $i in
		-h) show_help; exit 0 ;;
		-n) N=$2 ; shift ;;
		-g) RG=$2 ; shift ;;
		--saprefix) SAPREFIX=$2; shift ;;
		--saskeyfile) SASKEYFILE=$2; shift ;;
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

if [ -f ${SASKEYFILE} ]
then 
	rm ${SASKEYFILE}
fi

echo "Generating SAS key file [${SASKEYFILE}] for storage accounts ${SAPREFIX}0-$((N-1))..."
for ((i=0; i<${N}; i++))
do 
    SAKEY=$(az storage account keys list -n ${SAPREFIX}${i} -g ${RG} -o table | grep key1 | awk '{ print $3 }')
	echo "generating SAS key for account [${SAPREFIX}${i}]..."
	SAS=$(az storage account generate-sas --permissions rlw --services b --resource-types sco --expiry $ENDDATE -o tsv --account-name ${SAPREFIX}${i} --account-key $SAKEY)
	echo SASKEY[${i}]=\"?${SAS}\" >> ${SASKEYFILE}
done

echo "done."


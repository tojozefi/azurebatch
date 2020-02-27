#!/bin/bash

ENDDATE=$(date -u -d "1 month" '+%Y-%m-%dT%H:%M:%SZ')

function show_help {
	echo "Usage: ./create_accounts.sh OPTIONS"
	echo "OPTIONS:"
	echo "-n, amount of storage accounts to create" 
	echo "-g, resource group for storage accounts" 
	echo "--saprefix, blob storage account name prefix"
	echo "--saskeyfile, SAS key file to generate (optional)"
	echo "--container, blob storage container to create (optional)"
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
		--container) CONTAINER=$2; shift ;;
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

echo "Creating ${N} storage accounts ${SAPREFIX}0-$((N-1)) in resource group [${RG}]..."
for ((i=0; i<${N}; i++))
do 
	echo "creating storage account [${SAPREFIX}${i}]..."
	az storage account create -n ${SAPREFIX}${i} -g ${RG} --sku Standard_LRS --kind StorageV2 -o none
    SAKEY=$(az storage account keys list -n ${SAPREFIX}${i} -g ${RG} -o table | grep key1 | awk '{ print $3 }')
	if [ ! -z ${CONTAINER} ]; then 
		echo "creating container [${CONTAINER}] in account [${SAPREFIX}${i}]..."
		az storage container create -n ${CONTAINER} --account-name ${SAPREFIX}${i} --account-key ${SAKEY} -o none
	fi
	if [ ! -z ${SASKEYFILE} ]; then
		echo "generating SAS key for account [${SAPREFIX}${i}]..."
		SAS=$(az storage account generate-sas --permissions rlw --services b --resource-types sco --expiry $ENDDATE -o tsv --account-name ${SAPREFIX}${i} --account-key $SAKEY)
		echo SASKEY[${i}]=\"?${SAS}\" >> ${SASKEYFILE}
	fi
done

echo "done."


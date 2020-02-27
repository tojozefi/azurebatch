#!/bin/bash
# Data sharding run script
# Author: Tomasz Jozefiak (tojozefi@microsoft.com)
# Usage: ./datasharding-runscript.sh <datasample> <saprefix> <container> <nrofaccounts> <saskeyfile> <startindex> <endindex>

datasample=$1
saprefix=$2
container=$3
nrofaccounts=$4
saskeyfile=$5
startidx=$6
endidx=$7

sharedfolder=$AZ_BATCH_NODE_SHARED_DIR

source $saskeyfile
saidx=$(( startidx % nrofaccounts ))
saskey=${SASKEY[$saidx]}
for (( i=startidx; i <= endidx ; i+= nrofaccounts )); do
 suffix=$(printf %0${#endidx}d ${i})
 echo "azcopy cp $sharedfolder/$datasample \"https://${saprefix}${saidx}.blob.core.windows.net/${container}/${datasample}_${suffix}${saskey}\""
 azcopy cp $sharedfolder/$datasample "https://${saprefix}${saidx}.blob.core.windows.net/${container}/${datasample}_${suffix}${saskey}" --log-level NONE
done
echo "Finished."
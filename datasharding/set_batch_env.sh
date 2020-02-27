#/bin/bash
# Usage: source set_batch_env.sourceme <resourcegroup> <batchaccount>

if [ $# != 2 ]; then
 echo "Usage: source set_batch_env.sourceme <resourcegroup> <batchaccount>"
else 
 rg=$1
 ba=$2
 export AZURE_BATCH_ACCOUNT=$ba
 export AZURE_BATCH_ENDPOINT=$(az batch account show -n $ba -g $rg | grep accountEndpoint | cut -d':' -f2 | tr -d [:space:] | tr -d [,])
 export AZURE_BATCH_KEY=$(az batch account keys list -n $ba -g $rg | grep primary | cut -d':' -f2 | tr -d [:space:] | tr -d [,])
fi

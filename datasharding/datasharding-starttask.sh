#!/bin/bash

datasamplesize=$1

chmod +x azcopy
mv -v azcopy /usr/local/bin/

echo "fallocate -l $datasamplesize $AZ_BATCH_NODE_SHARED_DIR/datasample${datasamplesize}"
fallocate -l $datasamplesize $AZ_BATCH_NODE_SHARED_DIR/datasample${datasamplesize} 

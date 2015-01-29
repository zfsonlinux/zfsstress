#!/bin/bash

# Run more instances to increase stress level.
(./randcreate.sh < /dev/null > randcreate.log 2>&1 & )
(./randcreate.sh < /dev/null > /dev/null 2>&1 & )

(./randwrite.sh < /dev/null > randwrite.log 2>&1 & )
(./randwrite.sh < /dev/null > /dev/null 2>&1 & )

(./randrm.sh < /dev/null > randrm.log 2>&1 & )
(./randrm.sh < /dev/null > /dev/null 2>&1 & )

(./randxattr.sh < /dev/null > randxattr.log 2>&1 & )
(./randxattr.sh < /dev/null > /dev/null 2>&1 & )

# Pool operations.
(./randimportexport.sh < /dev/null > randimportexport.log 2>&1 & )
(./randscrub.sh < /dev/null > randscrub.log 2>&1 & )

# Dataset operations.
(./randsnapshot.sh < /dev/null > randsnapshot.log 2>&1 & )
(./randdataset.sh < /dev/null > randdataset.log 2>&1 & )

# Randomly change dataset properties.
#(./randproprecordsize.sh < /dev/null > randproprecordsize.log 2>&1 & )
(./randpropdnodesize.sh < /dev/null > randpropdnodesize.log 2>&1 & )
(./randpropxattr.sh < /dev/null > randpropxattr.log 2>&1 & )

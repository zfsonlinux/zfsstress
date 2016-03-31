#!/bin/bash

basedir="$(dirname $0)"
SCRIPT_COMMON=common.sh
if [ -f "${basedir}/${SCRIPT_COMMON}" ]; then
	. "${basedir}/${SCRIPT_COMMON}"
else
	echo "Missing helper script ${SCRIPT_COMMON}" && exit 1
fi

pushd $basedir > /dev/null

# Run more instances to increase stress level.

# User operations
runmany 2 ./randcreate.sh
runmany 2 ./randwrite.sh
runmany 2 ./randrm.sh
runmany 2 ./randxattr.sh
runmany 2 ./randsymlink.sh
runmany 2 ./randmkdir.sh

## Pool operations.
runmany 1 ./randimportexport.sh
runmany 1 ./randscrub.sh

# Dataset operations.
runmany 1 ./randsnapshot.sh
runmany 1 ./randdataset.sh
runmany 1 ./randsendrecv.sh

# Randomly change dataset properties.
runmany 1 ./randproprecordsize.sh
runmany 1 ./randpropdnodesize.sh
runmany 1 ./randpropxattr.sh
runmany 1 ./randpropcompression.sh

popd > /dev/null

killjobs()
{
	jobs -p | xargs kill
}

trap killjobs SIGINT

if [ -n "$1" ] ; then
	sleep $1
	killjobs
else
	wait
fi

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
./randcreate.sh < /dev/null > randcreate.log 2>&1 &
./randcreate.sh < /dev/null > randcreate2.log 2>&1 &

./randwrite.sh < /dev/null > randwrite.log 2>&1 &
./randwrite.sh < /dev/null > randwrite2.log 2>&1 &

./randrm.sh < /dev/null > randrm.log 2>&1 &
./randrm.sh < /dev/null > randrm2.log 2>&1 &

./randxattr.sh < /dev/null > randxattr.log 2>&1 &
./randxattr.sh < /dev/null > randxattr2.log 2>&1 &

./randsymlink.sh < /dev/null > randsymlink.log 2>&1 &
./randsymlink.sh < /dev/null > randsymlink2.log 2>&1 &

./randmkdir.sh < /dev/null > randmkdir.log 2>&1 &
./randmkdir.sh < /dev/null > randmkdir2.log 2>&1 &

# Pool operations.
./randimportexport.sh < /dev/null > randimportexport.log 2>&1 &
./randscrub.sh < /dev/null > randscrub.log 2>&1 &

# Dataset operations.
./randsnapshot.sh < /dev/null > randsnapshot.log 2>&1 &
./randdataset.sh < /dev/null > randdataset.log 2>&1 &

# Randomly change dataset properties.
./randproprecordsize.sh < /dev/null > randproprecordsize.log 2>&1 &
./randpropdnodesize.sh < /dev/null > randpropdnodesize.log 2>&1 &
./randpropxattr.sh < /dev/null > randpropxattr.log 2>&1 &
./randpropcompression.sh < /dev/null > randpropcompression.log 2>&1 &

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

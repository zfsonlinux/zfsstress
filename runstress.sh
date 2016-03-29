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
./randcreate.sh < /dev/null > ${LOGDIR}/randcreate.log 2>&1 &
./randcreate.sh < /dev/null > ${LOGDIR}/randcreate2.log 2>&1 &

./randwrite.sh < /dev/null > ${LOGDIR}/randwrite.log 2>&1 &
./randwrite.sh < /dev/null > ${LOGDIR}/randwrite2.log 2>&1 &

./randrm.sh < /dev/null > ${LOGDIR}/randrm.log 2>&1 &
./randrm.sh < /dev/null > ${LOGDIR}/randrm2.log 2>&1 &

./randxattr.sh < /dev/null > ${LOGDIR}/randxattr.log 2>&1 &
./randxattr.sh < /dev/null > ${LOGDIR}/randxattr2.log 2>&1 &

./randsymlink.sh < /dev/null > ${LOGDIR}/randsymlink.log 2>&1 &
./randsymlink.sh < /dev/null > ${LOGDIR}/randsymlink2.log 2>&1 &

./randmkdir.sh < /dev/null > ${LOGDIR}/randmkdir.log 2>&1 &
./randmkdir.sh < /dev/null > ${LOGDIR}/randmkdir2.log 2>&1 &

# Pool operations.
./randimportexport.sh < /dev/null > ${LOGDIR}/randimportexport.log 2>&1 &
./randscrub.sh < /dev/null > ${LOGDIR}/randscrub.log 2>&1 &

# Dataset operations.
./randsnapshot.sh < /dev/null > ${LOGDIR}/randsnapshot.log 2>&1 &
./randdataset.sh < /dev/null > ${LOGDIR}/randdataset.log 2>&1 &
./randsendrecv.sh < /dev/null > ${LOGDIR}/randsendrecv.log 2>&1 &

# Randomly change dataset properties.
./randproprecordsize.sh < /dev/null > ${LOGDIR}/randproprecordsize.log 2>&1 &
./randpropdnodesize.sh < /dev/null > ${LOGDIR}/randpropdnodesize.log 2>&1 &
./randpropxattr.sh < /dev/null > ${LOGDIR}/randpropxattr.log 2>&1 &
./randpropcompression.sh < /dev/null > ${LOGDIR}/randpropcompression.log 2>&1 &

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

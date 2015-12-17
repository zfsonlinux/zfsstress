#!/bin/bash

basedir="$(dirname $0)"
SCRIPT_COMMON=common.sh
if [ -f "${basedir}/${SCRIPT_COMMON}" ]; then
	. "${basedir}/${SCRIPT_COMMON}"
else
	echo "Missing helper script ${SCRIPT_COMMON}" && exit 1
fi

set -x

while :; do
	randsleep 60

	# Pick a random snapshot and send/recv it to a new
	# dataset in the pool. This relies on snapshots being
	# created by the randsnapshot.sh script.
	snap=`rand_snapshot`
	[ -z "$snap" ] && continue
	recvds=$(mktemp -u `perl -e 'print "X" x int rand 16 + 1'`)
	$SUDO $ZFS send $snap | $SUDO $ZFS recv $DATASET/RECV_$recvds
done

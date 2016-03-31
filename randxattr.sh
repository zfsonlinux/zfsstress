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
	randsleep

	wait_for_export
	find $MOUNTPOINT | while read f ; do
		if coinflip 50 ; then
			v=`randbase64`
			n=$(mktemp -u `perl -e 'print "X" x int rand 247 + 1'`)
			$SUDO setfattr -h -n trusted.$n -v 0s$v "$f"
		else
			$SUDO getfattr -h -m. -d "$f"| grep '^[^#]'|
				cut -d= -f1 |
			while read xattr ; do
				if coinflip 80 ; then
					$SUDO setfattr -h -x $xattr "$f"
				fi
			done
		fi
	done
done

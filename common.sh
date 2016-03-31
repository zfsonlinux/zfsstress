export POOL="tank"
export DATASET="$POOL/fish"
export MOUNTPOINT="/$DATASET"
export MAX_FILENAME_LEN=255
export ZFS=${ZFS:-"/sbin/zfs"}
export ZPOOL=${ZPOOL:-"/sbin/zpool"}
export EXPORT_COOKIE=${EXPORT_COOKIE:-`mktemp -t XXXXXXXX`}

# Write up to MAX_WRITE_SIZE bytes to randomly selected files
# in the root of $DATASET.
export MAX_WRITE_SIZE=$(( 4 * 1024 * 1024 ))

# Randomly select values for these properties when creating
# datasets.
#export ZFS_CREATE_RAND_DNODESIZE=1
export ZFS_CREATE_RAND_RECORDSIZE=1
export ZFS_CREATE_RAND_COMPRESSION=1

export ZPOOL_IMPORT_OPT=${ZPOOL_IMPORT_OPT:-"-d /tmp"}
## comment SUDO if running scripts as root
export SUDO="sudo"

#
# Randomly return 0 or 1, biased toward 0 with
# the percent probability specified as an argument,
# or with no bias if no argument is given.
#
coinflip()
{
	local PERCENT_TRUE=${1:-'50'}
	local RAND=$(( $RANDOM % 100 ))
	if [ $PERCENT_TRUE -gt $RAND ] ; then
		return 0
	else
		return 1
	fi
}

#
# Sleep for a random number of seconds.
#
randsleep()
{
	local MAXSLEEP=${1:-'60'}
	sleep $(( $RANDOM % $MAXSLEEP ))
}

#
# Generate a random alphanumeric string.
#
randstring()
{
	echo $( perl -e '
		@a = ("a".."z","A".."Z",0..9,"_");
		print map {$a[rand scalar @a]} 1..$ARGV[0]||8;
	' $1 )
}

#
# Generate a base64-encoded sequence of random bytes.  The number of
# bytes may be specified as an argument, and the default is 4096.
#
randbase64()
{
	local MAXBYTES=${1:-'65536'}
	dd if=/dev/urandom bs=1 count=$(( $RANDOM % $MAXBYTES )) 2>/dev/null |
		openssl enc -a -A
}

#
# Sleep in 5 second intervals while the specified mountpoint is
# not found in the system mount table.
#
wait_for_mount()
{
	while ! mount | awk '{print $3}' | grep -q "^$1$"; do
		sleep 5
	done
}

#
# Set a flag indicating jobs should pause so the pool can be exported.
#
set_export_flag()
{
	echo exporting > $EXPORT_COOKIE
}

#
# Clear the exporting flag so waiting jobs can resume.
#
clear_export_flag()
{
	> $EXPORT_COOKIE
}

#
# Sleep in 5 second intervals while the pool is being exported.
#
wait_for_export()
{
	while grep -q '^exporting$' $EXPORT_COOKIE ; do
		sleep 5
	done
}

#
# Randomly select a ZFS dnode size
#
_MIN_DNODE_SIZE=512
_DNODES_PER_BLOCK=32
_MAX_DNODE_SIZE=$(( $_MIN_DNODE_SIZE * $_DNODES_PER_BLOCK ))
for ((i=1; $(( $i * $_MIN_DNODE_SIZE )) <= $_MAX_DNODE_SIZE ; i++)) ; do
	_DNSIZES+=( $(( $_MIN_DNODE_SIZE * $i )) )
done

rand_dnodesize()
{
	echo ${_DNSIZES[$(( $RANDOM % ${#_DNSIZES[@]}))]}
}

#
# Randomly select a ZFS record size.
#
_MIN_RECORDSIZE=512
_MAX_RECORDSIZE=$(( 128 * 1024 ))
for ((i=$_MIN_RECORDSIZE; i <= $_MAX_RECORDSIZE; i*=2 )) ; do
	_RECSIZES+=( $i )
done

rand_recordsize()
{
	echo ${_RECSIZES[$(( $RANDOM % ${#_RECSIZES[@]}))]}
}

#
# Randomly select a ZFS compression algorithm.
#
rand_compression()
{
	local ALG=(
		on
		off
		lzjb
		gzip-1
		gzip-2
		gzip-3
		gzip-4
		gzip-5
		gzip-6
		gzip-7
		gzip-8
		gzip-9
		zle
		lz4
	)
	echo ${ALG[$(( $RANDOM % ${#ALG[@]}))]}
}

rand_file()
{
	local local_root=$(rand_directory)
	FILES=(`$SUDO find $local_root -type f`)
	if [[ ${#FILES[@]} -gt 0 ]]; then
		echo ${FILES[$(( $RANDOM % ${#FILES[@]}))]}
	fi
}

rand_directory()
{
	local TOP=${1:-$MOUNTPOINT}
	DIRS=(`$SUDO find $TOP -type d`)
	echo ${DIRS[$(( $RANDOM % ${#DIRS[@]}))]}
}

rand_dataset()
{
	local TOP=${1:-$DATASET}
	DS=(`$SUDO $ZFS list -H -o name -t filesystem| grep "^$TOP"`)
	if [ ${#DS[@]} -ne 0 ] ; then
		echo ${DS[$(( $RANDOM % ${#DS[@]}))]}
	fi
}

rand_snapshot()
{
	local TOP=${1:-$DATASET}
	SNAP=(`$SUDO $ZFS list -H -o name -t snap| grep "^$TOP"`)
	if [ ${#SNAP[@]} -ne 0 ] ; then
		echo ${SNAP[$(( $RANDOM % ${#SNAP[@]}))]}
	fi
}

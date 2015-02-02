export POOL="tank"
export DATASET="$POOL/fish"
export MOUNTPOINT="/$DATASET"
MOUNTPOINT_LEN=`echo -n $MOUNTPOINT | wc -c`
export MAX_FILENAME_LEN=$(( 255 - $MOUNTPOINT_LEN ))
export ZFS=${ZFS:-"/sbin/zfs"}
export ZPOOL=${ZPOOL:-"/sbin/zpool"}

# Write up to MAX_WRITE_SIZE bytes to randomly selected files
# in the root of $DATASET.
export MAX_WRITE_SIZE=$(( 4 * 1024 * 1024 ))

# Randomly select values for these properties when creating
# datasets.
#export ZFS_CREATE_RAND_DNODESIZE=1
export ZFS_CREATE_RAND_RECORDSIZE=1
export ZFS_CREATE_RAND_COMPRESSION=1

export ZPOOL_IMPORT_OPT="-d /tmp"
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
# Generate a random character string. Exclude exclamation point (ASCII
# 33) double quote (ASCII 34) single quote (ASCII 39) and forward slash
# (ASCII 47) for easier quoting.
#
randstring()
{
	echo $( perl -e '
		@a = map {chr} 35..38,40..46,48..126;
		print map {$a[rand scalar @a]} 1..$ARGV[0]||8;
	' $1 )
}

#
# Generate a base64-encoded sequence of random bytes.  The number of
# bytes may be specified as an argument, and the default is 4096.
#
randbase64()
{
	local MAXBYTES=${1:-'4096'}
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

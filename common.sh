export POOL="tank"
export DATASET="$POOL/fish"
export MOUNTPOINT="/$DATASET"
export ZFS="./cmd/zfs/zfs"
export ZPOOL="./cmd/zpool/zpool"
export MAX_WRITE_SIZE=$(( 4 * 1024 * 1024 ))
#export ZPOOL_DEVDIR_OPT="-d /tmp"
## comment SUDO if running scripts as root
export SUDO="sudo"

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

randsleep()
{
	local MAXSLEEP=${1:-'60'}
	sleep $(( $RANDOM % $MAXSLEEP ))
}


randstring()
{
	# exclude double quote (ASCII 34) for easier quoting
	echo $( perl -e '
		@a = map {chr} 33,35..126;
		print map {$a[rand scalar @a]} 1..$ARGV[0]||8;
	' $1 )
}

randbase64()
{
	local MAXBYTES=${1:-'4096'}
	dd if=/dev/urandom bs=1 count=$(( $RANDOM % $MAXBYTES )) |
		openssl enc -a -A
}

wait_for_mount()
{
	while ! mount | awk '{print $3}' | grep -q "^$1$"; do
		sleep 5
	done
}

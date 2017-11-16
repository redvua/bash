LAN="192.168.1."
log="/root/ip.log" # cache file name
if [ -f $log ]
then
 let tlc="`date +%s` - `stat -c%Y $log`" # time life cache file in sec
 [ 180 -le $tlc ] && invalidate=true
 old=( $(cat $log) )
else
 eval "old=(`echo [{0..254}]=2`)"
fi

for i in {114..118}
do

if [ ${old[$i]} = 2 -o "$invalidate" = true ]
then
 res[$i]=${old[$i]}
 ping -c 1 ${LAN}${i} >> /dev/null
 old[$i]=$?
 [ ${res[$i]} = ${old[$i]} ] && unset res[$i]
fi
done
#echo ${old[@]}

if [ ${#res[@]} -gt 0 ]
then
 for i in ${!res[@]} ; do
  echo "${LAN}${i} ${res[$i]} -> ${old[$i]}"
 done 
 invalidate=true
fi
[ "$invalidate" = true ] && echo ${old[@]} > $log

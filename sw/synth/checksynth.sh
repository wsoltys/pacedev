#!/bin/sh

# -l list projects
# -e elaborate
# -s synthesize
# -t target pattern
# -p platform pattern

op="list"
ppat='*'
tpat='*'
fpat='*.qpf'
ts=`date +"_%Y%m%d_%H%M%S"`
logfile="build$ts.log"

while getopts elsp:t: opt; do
	case "$opt" in
	e)	op="elab";;
	l)	op="list";;
	s)	op="synt";;
	p)	ppat="$OPTARG";;
	t)	tpat="$OPTARG";;
	esac
done

rm -f $logfile detail.log
(
echo -n "Start " 
date 

for f in `find platform -path "*/$ppat/$tpat/$fpat"`; do 
	case "$op" in
	"list")	echo $f;;
	"elab")	echo -n "Elaborating $f: " 
		quartus_map $f --analysis_and_elaboration >> detail.log
		rc="$?"
		if [ "$rc" -eq "0" ]; then
			echo "OK";
		else
			echo "*** FAILED ($rc) ***"
		fi ;;
	"synt")	echo -n "Synthesizing $f: " 
		#quartus_map $f --analysis_and_elaboration >> detail.log
		rc="$?"
		if [ "$rc" -eq "0" ]; then
			echo "OK";
		else
			echo "*** FAILED ($rc) ***"
		fi ;;
	esac
done

echo -n "End "
date
) | tee $logfile

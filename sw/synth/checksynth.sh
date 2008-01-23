rm build.log detail.log
(
echo -n "Start " 
date 

for f in `find . -name \*.qpf`; do 
	echo -n "Checking $f: " 
	quartus_map $f --analysis_and_elaboration >> detail.log
	echo returned $?
done

echo -n "End "
date
) | tee build.log

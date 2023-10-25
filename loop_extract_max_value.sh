rm *time_amp_stage*txt
for csta in 149 204 214 202
#for csta in 202
do
	for freq in 1-5 10-20
	do
		for stage in `awk '{print $1}' stage_list_all.txt`
		do
			python src/extract_max_value.py $csta $stage $freq
		done
	done		
done

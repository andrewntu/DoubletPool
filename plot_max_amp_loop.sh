#rm *time_amp_stage*txt
for csta in 149 204 214 202
#for csta in 202
do
	for freq in 1-5 10-20
	do
		sh src/PLOTS/plot_max_amp_stack.sh $csta $freq
	done
done

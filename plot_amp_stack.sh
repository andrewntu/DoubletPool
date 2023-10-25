for sta in 204 214 149
do
	for freq in 1-5 10-20
	do
		sh src/PLOTS/plot_amp_stack_event.sh $sta ${freq}
	done
done

#!/bin/bash

if [ $# != 2 ];
then
  echo "USAGE: csta freq"
  exit 
fi

ND=`pwd`
csta=$1
freq=$2

in_path=./
infold=${in_path}


if [ ! -d "Fig_max_amp" ];then
	mkdir Fig_max_amp/
fi
if [ ! -d "Fig_max_amp/${csta}" ];then
	mkdir Fig_max_amp/${csta}
fi
if [ ! -d "Fig_max_amp/${csta}/${freq}hz" ];then
	mkdir Fig_max_amp/${csta}/${freq}hz
fi
ofold=Fig_max_amp/${csta}/${freq}hz

for stage in $(seq -20 1 10)
#for stage in 5
do
	#rm ${ofold}/*_stage_${stage}_*_${freq}hz.ps.png
	#<<'COMMENT'
	infile=${infold}/${csta}_time_amp_stage.${stage}.1-5hz.txt
	nn=0
	rm plot.list ppm.list
	if [ "$nn" -lt "10" ];then
	nn=`echo 00${nn}`
	elif [ "$nn" -ge "10" ] && [ "$nn" -lt "100" ];then
	nn=`echo 0${nn}`
	fi
	output_ps_file=${ofold}/${nn}_stage_${stage}_${freq}hz.ps
	line=`cat $infile | wc -l`
	for ((i=1;i<=$line;i++))
#	for pair in `ls -d CCF/${csta}/${csta}-??? | awk -F/ '{print$3}'`
	do
		amp_ZZ=`awk 'NR==i{print $4}' i=${i} ${infile}`
		#if [ ${amp_ZZ%.*} -le 0.5 ] || [ ${amp_ZZ%.*} -ge -0.5 ]; then
		#if [ $(echo " ${amp_ZZ} > -0.5" | bc -l ) ] || [ $(echo " ${amp_ZZ} < 0.5" | bc -l ) ]; then
		if (( $(echo "$amp_ZZ > -0.2" | bc -l) )) && (( $(echo "$amp_ZZ < 0.2" | bc -l) )); then
			pair=`awk 'NR==i{print$1}' i=${i} $infile `
			rec=`echo $pair | awk -F- '{print$2}'`
			stlo=`awk '$1==rec{print $4}' rec=${rec} UGB21_FALL-Locs_${csta}.txt`
			stla=`awk '$1==rec{print $3}' rec=${rec} UGB21_FALL-Locs_${csta}.txt`
		#	amp_ZZ=`awk 'NR==i{print $2}' i=${i} ${infile}`
			echo $stlo $stla $amp_ZZ >> plot.list
		fi
	done
#	exit

	gmtset ANOT_FONT_SIZE 12
	gmtset BASEMAP_TYPE plain
	gmtset PAPER_MEDIA A3
	gmtset MEASURE_UNIT cm


	cptfile=incend.cpt
	#makecpt -Cpolar -T-1.1/1.1/0.001 -Z -Ic > $cptfile
	makecpt -Cpolar -T-0.2/0.2/0.01 -Z -Ic > $cptfile
	SCA=-JM8i
	REG=-R-110.8301/-110.8292/44.4641/44.4646

	psbasemap $REG $SCA -Gwhite -Ba0.0002f0.0001/a0.0002f0.0001WseN -Xc -Yc -P -K > $output_ps_file
	pscoast $REG $SCA -Df -N2 -K -O -P >> $output_ps_file

	#station amplitude
	awk '{print$1,$2,$3}' plot.list | psxy $SCA $REG -St.7  -W0.05 -C$cptfile -O -K >> $output_ps_file
	#Doublet Pool location
	echo -110.829643 44.464347 | psxy $SCA $REG -Sc.8 -W3 -G0/0/0 -O -K >> $output_ps_file

	psscale  -C$cptfile -P -D4i/-0.5/4i/0.5h -B0.2:'Arrival Time (sec)': -K -O  >> $output_ps_file

	pstext -R0/10/0/10 -JX10c -K -O -N -G0 -Y3c -X-1.7c << END >>  $output_ps_file
	5 -1.75 20 0.0 8 CB Minute $stage
END
	convert -trim -density 300 $output_ps_file $output_ps_file.png
	nn=`echo $nn | awk '{print$1+1}'`
	rm $output_ps_file
	#exit
done #end line
#convert -trim -page A4+1+1 -quality 100  -loop 0 -delay 20 ${ofold}/*_stage_${stage}_*_${freq}hz.ps.png ${ofold}/SNAP_stage_${stage}_${freq}hz.gif
#rm ${ofold}/*_stage_${stage}_*_${freq}hz.ps.png

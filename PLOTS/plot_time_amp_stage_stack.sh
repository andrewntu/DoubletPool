#!/bin/bash

ND=`pwd`
#csta=204
ofold=Fig_time_amp_stack
stafile=UGB21_FALL-Locs_202.txt
if [ ! -d "${ofold}" ];then
        mkdir ${ofold}
fi
for csta in 204 214 149
do
	oofold=${ofold}/${csta}
	if [ ! -d "${oofold}" ];then
		mkdir ${oofold}
	fi
	for freq in 1-5hz 10-20hz
	do
		ooofold=${oofold}/${freq}
		if [ ! -d "${ooofold}" ];then
			mkdir ${ooofold}
		fi
		infold=./
		#for stage in `cat stage_list_all.txt | head -n 1`
		#<<"COMMENT"
		nn=0
		for stage in `cat stage_list_all.txt`
		do
		#echo "stage " $stage
		if [ "$nn" -lt "10" ];then
		nn=`echo 0${nn}`
		fi

		pfile=`ls ${infold}/${csta}_time_amp_stage.${stage}.${freq}.txt`
		output_ps_file=${ooofold}/${nn}_${csta}_stage.${stage}_time_amp_${freq}.ps

		cat $pfile | awk '{print $2,$3,$4}' > vector.tmp

		gmtset ANOT_FONT_SIZE 10
		gmtset BASEMAP_TYPE plain
		gmtset PAPER_MEDIA A3
		gmtset MEASURE_UNIT cm

		makecpt -Cpanoply -T-0.2/0.2/0.001 -Z -Ic > incend.cpt
		#makecpt -Cpolar -T-0.2/0.2/0.001 -Z -Ic > incend.cpt

		cptfile=incend.cpt
		SCA=-JM8i
		REG=-R-110.8303/-110.8292/44.4640/44.46466

		psbasemap $REG $SCA -Gwhite -B0.0002/0.0002WseN -Xc -Yc -P -K > $output_ps_file

		psxy -R -J vector.tmp -C$cptfile -St0.8 -W0.05p -K -O >> $output_ps_file

		#Old Faithful location
		echo -110.829643 44.464347 | psxy $SCA $REG -Sa.8 -W3 -G0/0/0 -O -K >> $output_ps_file


		psscale  -C$cptfile -P -D10/-0.5/12/0.5h -B0.05:'Max Amp Arrival Time (sec)': -K -O  >> $output_ps_file

		pstext -R0/10/0/10 -JX10c -K -O -N -G0  << END >>  $output_ps_file
		3.45 5 16 0.0 7 CB  Minute $stage
END

		convert -trim -density 300 $output_ps_file $output_ps_file.png
		rm $output_ps_file
		nn=`echo $nn | awk '{print$1+1}'`
		#exit
		done # stage
	convert -trim -page A4+1+1 -quality 100  -loop 0 -delay 20 ${ooofold}/*_${csta}_stage.*_${freq}.ps.png ${ooofold}/${csta}_baz_${freq}.gif
	done # freq
done # csta
#COMMENT

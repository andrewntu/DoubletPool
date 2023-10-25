#!/bin/bash

ND=`pwd`
#csta=204
for csta in 204 214 149
do
	for freq in 1-5hz 10-20hz
	do
#		freq=1-5hz
		infold=Polarization_out_stack
		ofold=Fig_Polarization_stack
		#for stage in `cat stage_list_all.txt | head -n 1`
		#<<"COMMENT"
		nn=0
		for stage in `cat stage_list_all.txt`
		do
		#echo "stage " $stage
		if [ ! -d "$ofold" ];then
			mkdir $ofold
		fi
		if [ "$nn" -lt "10" ];then
		nn=`echo 0${nn}`
		fi

		pfile=`ls ${infold}/${csta}_polarization_all_4project_stage.${stage}_baz_${freq}.txt`
		output_ps_file=${ofold}/${nn}_${csta}_stage.${stage}_baz_${freq}.ps

		cat $pfile | awk '{print $2,$3,$6,$4*2/3}' > vector.tmp
		cat $pfile | awk '{print $2,$3,$6+180,$4*2/3}' > vector2.tmp
		cat $pfile | awk '{print $2,$3,$9}' > incend.tmp

		gmtset ANOT_FONT_SIZE 10
		gmtset BASEMAP_TYPE plain
		gmtset PAPER_MEDIA A3
		gmtset MEASURE_UNIT cm

		makecpt -Cpanoply -T0/90/1 -Z -Ic > incend.cpt

		cptfile=incend.cpt
		SCA=-JM8i
		REG=-R-110.8303/-110.8292/44.4640/44.46466

		psbasemap $REG $SCA -Gwhite -B0.0002/0.0002WseN -Xc -Yc -P -K > $output_ps_file
		cat vector.tmp | psxy  $SCA $REG -Sv0.05 -G0 -W0p -K -O >> $output_ps_file
		cat vector2.tmp | psxy  $SCA $REG -Sv0.05 -G0 -W0p -K -O >> $output_ps_file


		#vertical
		cat incend.tmp | psxy $SCA $REG -Sc.35  -C$cptfile -O -K >> $output_ps_file


		#Old Faithful location
		echo -110.829643 44.464347 | psxy $SCA $REG -Sa.8 -W3 -G0/0/0 -O -K >> $output_ps_file


		psscale  -C$cptfile -P -D10/-0.5/12/0.5h -B10:'Incident angle (degree)': -K -O  >> $output_ps_file

		pstext -R0/10/0/10 -JX10c -K -O -N -G0  << END >>  $output_ps_file
		3.45 5 16 0.0 7 CB  Minute $stage
END

		convert -trim -density 300 $output_ps_file $output_ps_file.png
		rm $output_ps_file
		nn=`echo $nn | awk '{print$1+1}'`
		done # stage
	convert -trim -page A4+1+1 -quality 100  -loop 0 -delay 20 ${ofold}/*_${csta}_stage.*_${freq}.ps.png ${ofold}/${csta}_baz_${freq}.gif
	done # freq
done # csta
#COMMENT

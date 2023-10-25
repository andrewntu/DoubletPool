#!/bin/bash

ND=`pwd`
csta=914
freq=1-5hz


#for erup in `ls ERUPTION_v2/${csta}/${freq}/ | grep "eruption"`
for erup in `ls Polarization_out_single/ | grep "eruption_1" | head -n 1`
do
echo $erup
#foreach stage ( `cat stage_list_all.txt` )#-10 )
#foreach stage ( `cat stage_list_all.txt | head -n 1` )
for stage in `cat stage_list_1min.txt`
do
#echo "stage " $stage
if [ ! -d "Fig_Polarization_single" ];then
	mkdir Fig_Polarization_single/
fi
if [ ! -d "Fig_Polarization_single/${erup}" ];then
        mkdir Fig_Polarization_single/${erup}
fi
pfile=`ls Polarization_out_single/$erup/${csta}_polarization_all_4project_stage.${stage}.txt` 
output_ps_file=Fig_Polarization_single/${erup}/${csta}_stage.$stage.ps
#echo $pfile
#exit

cat $pfile | awk '{print $2,$3,$6,$4*2/3}' > vector.tmp
cat $pfile | awk '{print $2,$3,$6+180,$4*2/3}' > vector2.tmp
cat $pfile | awk '{print $2,$3,$9}' > incend.tmp

gmtset ANOT_FONT_SIZE 10
gmtset BASEMAP_TYPE plain
gmtset PAPER_MEDIA A4
gmtset MEASURE_UNIT cm

makecpt -Cpanoply -T0/90/1 -Z -Ic > incend.cpt

cptfile=incend.cpt
SCA=-JM7i
REG=-R-110.831/-110.8264/44.4593/44.462

psbasemap $REG $SCA -Gwhite -B0.001/0.001WsNe -X2.2 -Y5.0 -P -K > $output_ps_file
#exit
#horizontal
#cat vector.tmp | psvelo  $SCA $REG -Se1/0.95/0 -G0 -A0.03/0.12/0.05 -K -O -V >> $output_ps_file
cat vector.tmp | psxy  $SCA $REG -Sv0.05 -G0 -W0p -K -O >> $output_ps_file
cat vector2.tmp | psxy  $SCA $REG -Sv0.05 -G0 -W0p -K -O >> $output_ps_file
#cat legend.tmp | psxy  $SCA $REG -Sv0.05i+t -G0 -K -O >> $output_ps_file

#center station
#psxy station.txt $SCA $REG -St.8 -W4 -O -K >> $output_ps_file

#vertical
cat incend.tmp | psxy $SCA $REG -Sc.35  -C$cptfile -O -K >> $output_ps_file
#cat legend.tmp | psxy $SCA $REG -Sc.35  -W1p,black -Gwhite -O -K >> $output_ps_file


#Old Faithful location
echo -110.828211897200987 44.460437153479248 | psxy $SCA $REG -Sa.8 -W3 -G0/0/0 -O -K >> $output_ps_file

#-110.830520 44.45968 180.0 0.66667
#psxy -R -J -W4/0/0/0 -O -K << ! >> $output_ps_file
#-110.830750 44.45948
#-110.830100 44.45948
#-110.830100 44.45977
#-110.830750 44.45977
#-110.830750 44.45948
#!

psscale  -C$cptfile -P -D8/-0.5/15/0.5h -B10:'Incident angle (degree)': -K -O  >> $output_ps_file

pstext -R0/10/0/10 -JX10c -K -O -N -G0 -Y3c -X-1.7c << END >>  $output_ps_file
3.45 -1.75 12 0.0 7 CB  Minute $stage
END


convert -trim -density 300 $output_ps_file $output_ps_file.png
rm $output_ps_file
done
done #stage

#!/bin/csh

set ND = `pwd`

#@ ind = 0
foreach stage ( `cat stage_list_all.txt` )#-10 )
#foreach stage ( `cat stage_list_all.txt | head -n 1` )
echo "stage " $stage
#set uind = `echo $ind | awk '{printf"%.3d\n", $1}'`
#echo $uind
# stap stlo stla LIN PLAN AZ NAZ EAZ INA
set pfile = `ls Polarization_out_correct/914_polarization_all_4project_stage.${stage}.txt` 
#set pfile = `ls Polarization_out_phase_SNR_5/914_polarization_all_4project_stage.${stage}_polar.txt` 
set output_ps_file = Fig_Polarization/914_stage.$stage.ps
#set output_ps_file = Fig_Ploarization_phase_SNR_5/914_stage.$stage.ps
#goto here

#cat $pfile | awk '{print $2,$3,$8,$7,"0","0","0"}' > vector.tmp
cat $pfile | awk '{print $2,$3,$6,$4*2/3}' > vector.tmp
cat $pfile | awk '{print $2,$3,$6+180,$4*2/3}' > vector2.tmp
cat $pfile | awk '{print $2,$3,$9}' > incend.tmp

gmtset ANOT_FONT_SIZE 10
gmtset BASEMAP_TYPE plain
gmtset PAPER_MEDIA A4
gmtset MEASURE_UNIT cm
#gmtset ANNOT_FONT_SIZE_PRIMARY 10
#gmtset FONT_ANNOT_PRIMARY= 12p,Helvetica
#gmtset FONT_LABEL 2

makecpt -Cpanoply -T0/90/1 -Z -Ic > incend.cpt

#set cptfile = cpt.file #incend.cpt
set cptfile = incend.cpt
set SCA = -JM7i
set REG = -R-110.831/-110.8264/44.4593/44.462

psbasemap $REG $SCA -Gwhite -Ba0.001f0.001/a0.001f0.001WsNe -X2.2 -Y5.0 -P -V -K >! $output_ps_file

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

pstext -R0/10/0/10 -JX10c  -V -O -N -G0 -Y3c -X-1.7c << END >>  $output_ps_file
3.45 -1.75 12 0.0 7 CB  Minute $stage
END


convert -trim -density 300 $output_ps_file $output_ps_file.png
rm $output_ps_file

end #stage

#!/bin/csh

set ND = `pwd`
set outdir = Data_CCF/
#foreach csta ( 149 214 )
foreach csta ( 201 )
foreach bp ( 1-5 10-20 )
#set bp = ( 10-20 )
if (! -d $outdir )mkdir $outdir
set outdir = Data_CCF/${csta}/
if (! -d $outdir )mkdir $outdir
set outdir = Data_CCF/${csta}/${bp}hz/ 
if (! -d $outdir )mkdir $outdir

foreach pair ( `ls CCF/${csta} | grep "${csta}"` )
set sta = `echo $pair | awk -F - '{print $1}'`
@ nsta = -20
while ( $nsta <= 10 )
set ofile_ZZ = tmp.ZZ.$nsta.select
set ofile_ZN = tmp.ZN.$nsta.select
set ofile_ZE = tmp.ZE.$nsta.select

foreach eruption ( `ls -d ERUPTION/${csta}/${bp}hz/eruption_* | grep -v ".txt" | sort -n -k1.29` )
set in_erup = `echo ${eruption}.txt`
#echo $in_erup
#exit

cat ${in_erup} | awk '$2==nsta{print$1}' nsta=${nsta} | awk '{printf("ls %s/cor_%s_%.13d.ZN.sac.'$bp'.norm_wha\n","'$eruption'","'$pair'",$1)}' >> $ofile_ZN

cat ${in_erup} | awk '$2==nsta{print$1}' nsta=${nsta} | awk '{printf("ls %s/cor_%s_%.13d.ZZ.sac.'$bp'.norm_wha\n","'$eruption'","'$pair'",$1)}' >> $ofile_ZZ

cat ${in_erup} | awk '$2==nsta{print$1}' nsta=${nsta} | awk '{printf("ls %s/cor_%s_%.13d.ZE.sac.'$bp'.norm_wha\n","'$eruption'","'$pair'",$1)}' >> $ofile_ZE
end #eruption

csh $ofile_ZZ > $ofile_ZZ.final
csh $ofile_ZE > $ofile_ZE.final
csh $ofile_ZN > $ofile_ZN.final

if ( `cat $ofile_ZZ.final | wc -l` >= 5 )then

cat $ofile_ZN.final | awk '{if (NR==1) print "r "$1;else print "addf "$ 1}END {print "div "NR"\nw "dir"/"pair".ZN.stage."tt".sac.norm\nq"}' dir=${outdir} pair=${pair} tt=${nsta} | sac
cat $ofile_ZZ.final | awk '{if (NR==1) print "r "$1;else print "addf "$ 1}END {print "div "NR"\nw "dir"/"pair".ZZ.stage."tt".sac.norm\nq"}' dir=${outdir} pair=${pair} tt=${nsta} | sac
cat $ofile_ZE.final | awk '{if (NR==1) print "r "$1;else print "addf "$ 1}END {print "div "NR"\nw "dir"/"pair".ZE.stage."tt".sac.norm\nq"}' dir=${outdir} pair=${pair} tt=${nsta} | sac

endif
@ nsta = $nsta + 1
rm -rf ${ofile_ZZ}* ${ofile_ZE}* ${ofile_ZN}*
end #while

end #pair
end #freq
end #csta

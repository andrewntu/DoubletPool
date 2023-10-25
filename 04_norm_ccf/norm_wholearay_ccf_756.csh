#!/bin/csh

set ND = `pwd`
if ($#argv != 1) then
  echo
  echo "Usage format.csh: [date]"
  echo
  exit 1
endif

foreach csta ( 756 )
cd $ND/CCF/${csta}
set perc = ( 0.9 )
#set bp = ( 1-5 )
foreach bp (1-5 10-20)
#foreach date ( 20180510 )
set date = $1
foreach tlag ( `ls ${csta}-${csta}/ZZ/cor_${csta}-${csta}_${date}?????.ZZ.sac.$bp | awk -F/ '{print $3}' | awk -F_ '{print $3}' | awk -F. '{print $1}'`  )
set whf = whole_$date.tmp
rm -rf $whf $whf.sort

foreach array (`ls -d ${csta}-???` )
saclst depmax depmin f $array/ZZ/cor_${array}_$tlag.ZZ.sac.$bp | awk '{print ($2+($3*-1))/2}' >> $whf
end #array

cat $whf | sort -k1 -g -r > $whf.sort 
set length = `cat $whf.sort | wc -l`
#cat $whf.sort
set per = `echo $length $perc | awk '{print int($1-($1*$2))+1}'`
#echo $length $per
#set ref = `saclst depmax depmin f 029-001/ZZ/cor_029-001_$tlag.ZZ.sac.1-5 | awk '{print ($2+($3*-1))/2}'`
set ref = `sed -n ${per}p $whf.sort` 
echo $tlag $length $per $ref 


foreach pair (`ls -d ${csta}-???` )

foreach comp ( ZZ ZN ZE )

set uccf = `ls $pair/$comp/cor_${pair}_$tlag.$comp.sac.$bp`

if ($#uccf == 0 )then
echo "no ${pair} $tlag"
continue
endif

set nccf = $uccf.norm_wha
ls $uccf > norm_$date.tmp
#cat norm_$date.tmp

#/uufs/chpc.utah.edu/common/home/flin-group3/icemax/useful_tool/widget/stack_norm_byref/stack4CCF/stack norm_$date.tmp $nccf $ref >>! /dev/null 
${ND}/src/04_norm_ccf/stack4CCF/stack norm_$date.tmp $nccf $ref >>! /dev/null 

end #comp

end #pair

end #tlag

end #csta

end #date


#!/bin/csh

set ND = `pwd`
set ofile = $ND/run_bp_ccf.txt 
#set tfile = timelist_all.txt 
set tfile = timelist_2021_FALL.txt 
rm $ofile
@ a = 0
#foreach cstap ( `cat UGB21-Locs_use.txt | awk '{print $1}' `)
#foreach cstap ( 531 200 )# `cat UGB21-Locs_test.txt | awk '{print $1}' `)
#foreach cstap ( `cat UGB21-Locs_dense_one.txt | awk '{print $1}' `)
#foreach cstap ( `cat UGB21-Locs_dense_one_north_source.txt | awk '{print $1}' `)
#foreach cstap ( `cat UGB21-Locs_sinmei.txt | awk '$1==547{print $1}'`)
#foreach cstap ( 149 204 214 )
foreach cstap ( 201 )
#foreach cstap ( `cat UGB21-Locs_sinmei.txt | awk '{print $1}' | head -n 1`)

cd $ND/CCF/$cstap

foreach stap ( `ls -d $cstap-???` ) 

@ a++
echo "./src/03_bp_ccf/bp_ccf.csh " $stap "ZZ" $tfile >> $ofile
echo "./src/03_bp_ccf/bp_ccf.csh " $stap "ZN" $tfile >> $ofile
echo "./src/03_bp_ccf/bp_ccf.csh " $stap "ZE" $tfile >> $ofile
#echo "./bp_ccf.csh " $stap "ZZ &" >> $ofile
#echo "./bp_ccf.csh " $stap "ZN &" >> $ofile
#echo "./bp_ccf.csh " $stap "ZE &" >> $ofile

#if ( ( $a % 4 ) == 0 ) then
	#echo "wait " >> $ofile
	#echo "clear " >> $ofile
	#endif

end #stap

end #cstap

#ls $ofile

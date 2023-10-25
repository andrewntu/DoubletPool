#!/bin/csh

set ND = `pwd`
#set staf = $ND/UGB21-Locs_dense.txt 
#set staf = $ND/UGB23_SPRING-Locs.txt
#set staf = $ND/UGB22_FALL-Locs.txt
set staf = $ND/UGB21_FALL-Locs_149.txt
#set staf = $ND/UGB21-Locs_029_final.txt 

#foreach csta ( `cat $staf | awk '{print $1}'` )
foreach csta ( 201 ) 
#foreach csta ( 149 204 214 )

set cdir = $ND/CCF/
if ( ! -d $cdir )mkdir $cdir
set cdir = $ND/CCF/$csta
if ( ! -d $cdir )mkdir $cdir

foreach rsta ( `cat $staf | awk '{print $1}'` )

set pair = $csta-$rsta
echo $pair

set rdir = $cdir/$pair
if ( ! -d $rdir )mkdir $rdir

cd $rdir 
mkdir EE EN EZ NE NN NZ ZE ZN ZZ 

cd ..
end #rsta

end #csta


cd $ND


#./cor_whiten_whole_array_30s/cor_whiten_nor_all_array_stack timelist_test.txt 0 5 UGB21-Locs_test.txt 10000 ./

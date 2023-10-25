#!/bin/bash
fold=`pwd`
#<<'COMMENT'
cd src/02_do_ccf/cor_whiten_whole_array_60s_v2
make clean
make
cd $fold
#COMMENT
#./src/02_do_ccf/cor_whiten_whole_array_60s_v2/cor_whiten_nor_all_array_stack timelist_2022_SPRING.txt 0 1 UGB22_SPRING-Locs.txt 10000 .
#./src/02_do_ccf/cor_whiten_whole_array_60s_v2/cor_whiten_nor_all_array_stack timelist_2021_FALL.txt 0 1 UGB21_FALL-Locs_149.txt 10000 .
#./src/02_do_ccf/cor_whiten_whole_array_60s_v2/cor_whiten_nor_all_array_stack timelist_2021_FALL.txt 0 1 UGB21_FALL-Locs_214.txt 10000 .
#./src/02_do_ccf/cor_whiten_whole_array_60s_v2/cor_whiten_nor_all_array_stack timelist_2021_FALL.txt 0 1 UGB21_FALL-Locs_204.txt 10000 .
./src/02_do_ccf/cor_whiten_whole_array_60s_v2/cor_whiten_nor_all_array_stack timelist_2021_FALL.txt 0 1 UGB21_FALL-Locs_201.txt 10000 .

#./src/02_do_ccf/cor_whiten_whole_array_60s_v2/cor_whiten_nor_all_array_stack timelist_2022_FALL.txt 0 1 UGB22_FALL-Locs.txt 10000 .

#./src/02_do_ccf/cor_whiten_whole_array_60s_v2/cor_whiten_nor_all_array_stack timelist_2022_SPRING.txt 0 1 UGB23_SPRING-Locs.txt 10000 .

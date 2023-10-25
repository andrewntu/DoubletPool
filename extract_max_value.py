import numpy as np
import obspy
from obspy.core import read
import sys
import os
import glob

#'''
if len(sys.argv[:]) != 4:
    print('proper usage: python src/extract_max_value.py csta stage freq')
    sys.exit()
#'''


csta = str(sys.argv[1])
stage = str(sys.argv[2])
freq = str(sys.argv[3])

f = open(csta+'_time_amp_stage.'+stage+'.'+freq+'hz.txt','w+')
for wave in glob.glob('Data_CCF/'+csta+'/'+freq+'hz/'+csta+'-*.ZZ.stage.'+stage+'.sac.norm'):
    pair = wave.split('/')[3].split('.')[0]
    st = read(wave)
    tr = st[0]
    sample = round(1/tr.stats.sampling_rate,2)
    t = np.arange(-1*sample*int(len(tr.data)/2), sample*int(len(tr.data)/2) + sample, sample)
    #print(sample, t.shape, t, tr.stats.sac)
    #sys.exit()
    min_arg = np.argmin(tr.data)
    max_arg = np.argmax(tr.data)
    min_val = np.min(tr.data)
    max_val = np.max(tr.data)
    if abs(min_val) > max_val:
        final_arg = min_arg
        final_amp = min_val
    else:
        final_arg = max_arg
        final_amp = max_val

    f.writelines(pair+' '+str(tr.stats.sac.stlo)+' '+str(tr.stats.sac.stla)+' '+str(round(t[final_arg],2))+' '+str(final_amp)+'\n')
        


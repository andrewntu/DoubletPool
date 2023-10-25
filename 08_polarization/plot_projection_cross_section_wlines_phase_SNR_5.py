#############
# Better visualization of the cross-section  for Old Faithful's tremor 
# Sin-Mei Wu, University of Utah 
# December, 2019
#####
# Note use the exact parameters used in MATLAB
############
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
#from matplotlib import cm
from numpy import ndarray
import scipy.io as sio
import sys


sta='914'
sns.set_style('white')
stage_list = np.loadtxt('stage_list_all.txt')
crossids = [ 53.0923,  21.6594]
crosside = [-39.2567, -24.1387]
pang = np.arctan((crosside[1]-crossids[1])/(crosside[0]-crossids[0])) #ang of the cross-section
'''
##############################################
### project stations
sfile = 'Projection_mat_select_SNR_5/staloc_select.mat' #load station location
tmp = sio.loadmat(sfile)
staloc = tmp['sta'][:,:]
dd = np.zeros((np.size(staloc[:,0]),1))  
for ll in range(0,np.size(staloc[:,0])):
    p3 = staloc[ll,0:2]
    m = -1/(np.tan(pang))
    dd[ll] = (p3[1]-p3[0]*m)*np.sin(pang)
'''
##############################################
##### read the 2D cross-section grid for all times
test = sio.loadmat('Projection_mat_select_SNR_5/cross-Z.mat')
a = test['crossall']
gst = -1*np.sqrt((-200*-200)+np.square(-200*np.tan(pang)))
ged = np.sqrt((150*150)+np.square(150*np.tan(pang)))
gx = np.linspace(gst,ged,num=100) #starting and ending point of the cross-section
gz = np.linspace(-100,-5,num=20)
allavg=np.zeros((len(stage_list),3))

#for s in range(0,1):  #loop through times, here I only have one for example
for s in range(0,len(stage_list)):  #loop through times, here I only have one for example
    ss = int(stage_list[s])  #just organize the time to stage
    stage = str(ss)
    zz = a[s][:][:]
    zzt = np.transpose(zz)
    '''
    if ss >= 0:
        nss = str(ss).zfill(2)
    else:
        nss = str(ss).zfill(3)
    '''
    fig = plt.figure(figsize=(6.4, 4.7))
    
    SMALL_SIZE = 8
    MEDIUM_SIZE = 10
    BIGGER_SIZE = 12

    plt.rc('font', size=SMALL_SIZE)          # controls default text sizes
    plt.rc('axes', titlesize=SMALL_SIZE)     # fontsize of the axes title
    plt.rc('axes', labelsize=SMALL_SIZE)    # fontsize of the x and y labels
    plt.rc('xtick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
    plt.rc('ytick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
    plt.rc('legend', fontsize=SMALL_SIZE)    # legend fontsize
    
##############################################
#### project lines (visualization)
    X, Y = np.meshgrid(gx, gz)
    pnor = [np.tan(pang), -1, 0]
    #lfilep = ('Polarization_out/polarization_4projection_stage.'+ nss +'.txt')914_polarization_all_4project_stage.-30.txt
    lfilep = ('Polarization_out_phase_SNR_5/'+sta+'_polarization_all_4project_stage.'+ str(ss) +'_select.txt')
#    print(lfilep, np.size(staloc[:,0])-1)
    vz, vn, ve = np.loadtxt(lfilep, usecols=(4, 5, 6), unpack=True)
    sfile = 'Projection_mat_select_SNR_5/staloc_select_'+stage+'.mat' #load station location
    tmp = sio.loadmat(sfile)
#    print(tmp, sfile)
    staloc = tmp['staa'][:,:]
    dd = np.zeros((np.size(staloc[:,0]),1))  
    for ll in range(0,np.size(staloc[:,0])):
        p3 = staloc[ll,0:2]
        m = -1/(np.tan(pang))
        dd[ll] = (p3[1]-p3[0]*m)*np.sin(pang)
    for test in range(0,np.size(staloc[:,0])-1): 
        V = [ve[test], vn[test], vz[test]]   
        S = staloc[test,:]
        plx = np.zeros((500,1))
        ply = np.zeros((500,1))
        plz = np.zeros((500,1))
        plc = np.zeros((500,1))
        ttx = np.linspace(-1500,1500,num=500)
        tty = np.linspace(-1500,1500,num=500)
        ttz = np.linspace(-1500,1500,num=500)
        
        for pp in range(0,500): #500 determine the length of the line, just for visualization
            lx=S[0]+V[0]*ttx[pp]
            ly=S[1]+V[1]*tty[pp]
            lz=S[2]+V[2]*ttz[pp]
            ddd = lx*pnor[0]+ly*pnor[1]+ lz*pnor[2]
            plx[pp] = lx - ddd*pnor[0]
            ply[pp] = ly - ddd*pnor[1]
            plz[pp] = lz - ddd*pnor[2]
            pp3 = [plx[pp],ply[pp]]
            plc[pp] = (pp3[1]-pp3[0]*m)*np.sin(pang)
            if plz[pp]>=S[2]:
                plz[pp]=S[2]
                plc[pp]=dd[test]    
       
        plt.plot(plc,plz,"-",color='gray',markersize=0.002,linewidth=1, alpha=0.3)  

##############################################
### plot station location and the hit count map

    plt.plot(dd,staloc[:,2],"^",markersize=12)  
    plt.plot(0, 0,"*",color='cadetblue',markersize=15)         
   
    ct = plt.contourf(X, Y, zzt, [4,5,6,7,8,9,10], cmap='hot_r')
#    ct = plt.contourf(X, Y, zzt, [5,10,15,20,25,30], cmap='hot_r')
    ct1 = plt.contourf(X, Y, zzt, [10,21], colors=[(155/255,0,0)])
    plt.colorbar(ct,shrink=1,label='Count')
    
##############################################
#### plot means, setting   
#### use your threshold to determine the precise location

    # numerically, I account for every grids with hit count over 6 (out of 21)  
    # choose the threshold suitable for your array
    thur = 6
    avid = np.argwhere(zz>=thur)
    avval = zz[np.where(zz>=thur)]
    xrang = gx[avid[:,0]]
    zrang = gz[avid[:,1]]
    
    plt.plot(np.mean(xrang),np.mean(zrang),'wx',markeredgewidth=1.5,markersize=8)
    allavg[s][0]=np.mean(xrang)          
    allavg[s][1]=np.mean(zrang)   
    allavg[s][2]=np.std(zrang) 
    
    tstage = 'Minute '+stage
    plt.text(35, -90, tstage, fontsize=12, style='italic')   
    plt.tick_params(axis='y', direction='in')
    plt.xlim(-75,75)
    plt.ylim(-110,5)
    plt.xlabel('Distance from Old Faithful (meter)')
    plt.ylabel('Depth (meter)')
    ofig2 = "Fig_crossZ_contour_line_avg_phase_SNR_5/stage_" + stage + "_cross_contour_line.png"
    plt.savefig(ofig2,format='png', dpi=300)
#    plt.show() 


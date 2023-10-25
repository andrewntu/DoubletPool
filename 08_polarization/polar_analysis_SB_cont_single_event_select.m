clear all;clc;
%read and write sac files
%polarization analysis
% sta = input('Enter center station ...> ','s');
% freq = input('Enter frequency ...> ','s');
sta = ( '914' );
freq = ( '1-5' );
inall = zeros(101,80);
azmall = zeros(101,80);

for y = 11:11 %eruption
ee = int2str(y);
workdir= strcat('../../ERUPTION/',sta,'/',freq,'hz/eruption_',ee,'/');
slist= strcat('../../ERUPTION/',sta,'/',freq,'hz/eruption_',ee,'.txt');
[abs_time, stage_all] = textread(slist,'%s %s','headerlines',0);
outdir=strcat('../../Polarization_out_single_select/');
if not(isfolder(outdir))
    mkdir(outdir)
end
outdir=strcat('../../Polarization_out_single_select/eruption_',ee);
if not(isfolder(outdir))
    mkdir(outdir)
end

for s = 1:length(stage_all)
stage = char(stage_all(s))
time = char(abs_time(s))
ofile = strcat(outdir,'/',sta,'_polarization_all_4project_stage.',stage,'_select.txt')

fid = fopen(ofile,'w');
phfile = strcat('../../Phase_shift_single/eruption_',ee,'/',sta,'_phase_shift_stage.',time,'.',freq,'hz.txt');
[stap2, stlo, stla, poss, negs, avgs] = textread(phfile,'%s %f %f %f %f %f\n','headerlines',0);
for i = 1:length(stap2)
% for i = 1:2
if (poss(i) == 0) && (negs(i) == 0) && (avgs(i) == 0)
    continue
end
stap = char(stap2(i));

a = poss(i);
b = negs(i);
c = avgs(i);

% The best shift is 90 degree

thur = 22.5;
lower_thres = 90 - thur;
higher_thres = 90 + thur;

shift = avgs(i)./0.0825*90;
sprintf('%s %f', stap, shift);
%if shift<=thur
if (shift>=lower_thres) && (shift <= higher_thres)
tarN= strcat('cor_',stap,'_',time,'.ZN.sac.',freq,'.norm_wha');
tarE= strcat('cor_',stap,'_',time,'.ZE.sac.',freq,'.norm_wha');
tarZ= strcat('cor_',stap,'_',time,'.ZZ.sac.',freq,'.norm_wha');

z=rsac([workdir tarZ]);
r=rsac([workdir tarN]);
t=rsac([workdir tarE]);
stla = lh(z,'STLA');stlo = lh(z,'STLO');stel =  lh(z,'STEL');
tt=z(:,1);

%figure(1);clf;hold on
%plot(tt,z(:,2),tt,r(:,2)*-1,tt,t(:,2)*-1);xlim([-1.5 1.5]);legend('ZZ','ZN','ZE');

ts = 1001;
te = 1001 + 50;
X=[z(ts:te,2) r(ts:te,2)*-1 t(ts:te,2)*-1];
S=X'*X/length(X); 
[V,D] = eig(S);

tmp = diag(D);
[lam, lamid] = sort(tmp,'descend');

LIN = 1 - ((lam(2)+lam(3))/(2*lam(1))); %Polarization
PLAN = 1 - ((2*lam(3))/(lam(1)+lam(2))); %planarity
HR = lam(2)/lam(1); %ratio between fitst and second lamda 
sign=1;
%if (V(1,lamid(1))<0);sign=-1;end
AZ = rad2deg(atan(V(2,lamid(1))/V(3,lamid(1)))); %azimuth

EAZ = V(3,lamid(1))*sign; %east-component value
NAZ = V(2,lamid(1))*sign; %north component value
if (AZ<0);AZ=AZ+180;end
INA = rad2deg(acos(abs(V(1,lamid(1))))); %incident angle
inall(s,i)= INA;
azmall(s,i) = AZ;
%fprintf(fid, '%7s %11.6f %11.6f %10.5f %10.5f %10.5f %10.5f %10.5f %10.5f \n',stap, [stlo stla LIN HR AZ NAZ EAZ INA]');
fprintf(fid, '%7s %11.6f %11.6f %8.3f %10.5f %10.5f %10.5f\n',stap, [stlo stla stel V(1,lamid(1)) V(2,lamid(1)) V(3,lamid(1))]');
end

end

fclose(fid);

end

end % eruption
%save('All_incident_angle.mat','inall')
%save('All_azimuth_angle.mat','azmall')

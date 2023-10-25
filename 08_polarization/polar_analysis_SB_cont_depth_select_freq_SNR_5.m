clear all;clc;
%read and write sac files
%polarization analysis
%sta = ( '1030' );
% sta = input('Enter center station ...> ','s');
% freq = input('Enter frequency ...> ','s');
sta = ( '914' );
freq = ( '1-5' );
%erup = ( '0520' );
slist= '../../stage_list_all.txt'
[stage_all] = textread(slist,'%s','headerlines',0);
%stage = '-10';
%flist= strcat('sta_list_',sta,'_v2.txt');
%[stap_all] = textread(flist,'%s','headerlines',0);
inall = zeros(101,80);
azmall = zeros(101,80);

for s = 1:length(stage_all)
% for s = 1:1
stage = char(stage_all(s))
%ofile = strcat('Ploarization_out/',sta,'_polarization_all_stage.',stage,'.txt')
ofile = strcat('../../Polarization_out_phase_SNR_5/',sta,'_polarization_all_4project_stage.',stage,'_polar.txt')

fid = fopen(ofile,'w');
%phfile = strcat('../Phase_shift/',sta,'_phase_shift_stage.',stage,'.txt');
phfile = strcat('../../Phase_shift/',sta,'_phase_shift_stage.',stage,'.',freq,'hz.txt');
snrfile = strcat('../../SNR/',sta,'_SNR_stage.',stage,'.',freq,'hz.txt');%914_SNR_stage.0.1-5hz.txt
[stap2, stlo, stla, poss, negs, avgs] = textread(phfile,'%s %f %f %f %f %f\n','headerlines',0);
[stap3, stlo3, stla3, possnr, negsnr, avgsnr] = textread(snrfile,'%s %f %f %f %f %f\n','headerlines',0);
for i = 1:length(stap2)
% for i = 1:2
%if (i==30);continue;end
if (poss(i) == 0) && (negs(i) == 0) && (avgs(i) == 0)
    continue
end
stap = char(stap2(i));

a = poss(i);
b = negs(i);
c = avgs(i);

% The best shift is 90 degree

thur = 15;
lower_thres = 90 - thur;
higher_thres = 90 + thur;

shift = avgs(i)./0.0825*90;
sprintf('%s %f', stap, shift);
%if shift<=thur
if (shift>=lower_thres) && (avgsnr(i) >= 5.0)
workdir= strcat('../../Data_CCF/',sta,'/',freq,'hz/');
tarN= strcat(stap,'.ZN.stage.',stage,'.sac.norm');
tarE= strcat(stap,'.ZE.stage.',stage,'.sac.norm');
tarZ= strcat(stap,'.ZZ.stage.',stage,'.sac.norm');

z=rsac([workdir tarZ]);
r=rsac([workdir tarN]);
t=rsac([workdir tarE]);
stla = lh(z,'STLA');stlo = lh(z,'STLO');stel =  lh(z,'STEL');
tt=z(:,1);

%figure(1);clf;hold on
%plot(tt,z(:,2),tt,r(:,2)*-1,tt,t(:,2)*-1);xlim([-1.5 1.5]);legend('ZZ','ZN','ZE');

ts = 1601;
te = 1601 + 150;
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
fprintf(fid, '%7s %11.6f %11.6f %10.5f %10.5f %10.5f %10.5f %10.5f %10.5f \n',stap, [stlo stla LIN HR AZ NAZ EAZ INA]');
%fprintf(fid, '%7s %11.6f %11.6f %8.3f %10.5f %10.5f %10.5f\n',stap, [stlo stla stel V(1,lamid(1)) V(2,lamid(1)) V(3,lamid(1))]');
end

end

fclose(fid);

end

%save('All_incident_angle.mat','inall')
%save('All_azimuth_angle.mat','azmall')

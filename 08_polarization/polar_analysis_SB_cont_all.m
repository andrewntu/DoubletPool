clear all;clc;
%read and write sac files
%polarization analysis
sta = ( '914' );
%sta = input('Enter center station ...> ','s');
%erup = ( '0520' );
slist= '../../stage_list_1min.txt'
%slist= 'timelist_hour_new.txt'
[stage_all] = textread(slist,'%s','headerlines',0);
%stage = '-10';
%flist= strcat('sta_list_',sta,'.txt');
flist= '../../stalst'
[stap_all] = textread(flist,'%s','headerlines',0);
inall = zeros(101,80);
azmall = zeros(101,80);

for s = 1:length(stage_all)
stage = char(stage_all(s))
%ofile = strcat('Polarization_out/',sta,'_polarization_all_stage.',stage,'.txt')
ofile = strcat('../../Polarization_out_correct/',sta,'_polarization_all_4project_stage.',stage,'.txt')
fid = fopen(ofile,'w');

for i = 1:length(stap_all)
stap = char(stap_all(i));  

%stap = '562-005';
%Hours12-cgf-norm_wha-CGF_1028-936
%cor_1028-936_2019071884000.cgf.ZE.sac.1-5.norm_wha
%workdir= strcat('../',sta,'/',stap,'/Stage-',erup,'-cgf-norm_wha-CGF_');
workdir= strcat('../../Data_CCF_v2/',sta,'/1-5hz/');
%workdir
%tarN= strcat(stap,'/cor_',stap,'.stage.',stage,'.cgf.ZN.sac.1-5.norm_wha');
tarN= strcat(stap,'.ZN.stage.',stage,'.sac.norm');
tarE= strcat(stap,'.ZE.stage.',stage,'.sac.norm');
tarZ= strcat(stap,'.ZZ.stage.',stage,'.sac.norm');


if isfile(strcat(workdir,tarZ))

z=rsac([workdir tarZ]);
r=rsac([workdir tarN]);
t=rsac([workdir tarE]);
stla = lh(z,'STLA');stlo = lh(z,'STLO');stel =  lh(z,'STEL');
tt=z(:,1);


% figure(1);clf;hold on
% plot(tt,z(:,2),tt,r(:,2)*-1,tt,t(:,2)*-1);xlim([-0.5 0.5]);legend('ZZ','ZN','ZE');

%ts = 2001;
%te = 2001+300;

ts = 1601-50;
te = 1601+150;
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
else
    sprintf('No file!!\n')
     % File does not exist.
end
end

fclose(fid);

end

% save('../../Polarization_out_correct/All_incident_angle.mat','inall')
% save('../../Polarization_out_correct/All_azimuth_angle.mat','azmall')

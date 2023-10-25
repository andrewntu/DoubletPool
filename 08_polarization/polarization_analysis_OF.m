%%%%%%%%
% Polarization Analysis for Old Faithful tremor migration (Wu et al., 2019) 
% Sin-Mei Wu, University of Utah 
% December, 2019
%%%%%%%%
% Read and write cross-correlation sac files ZZ ZN ZE
% Write the dominant polarized vector (3D) in the output file 
%%%%%%%%

clear all;clc;
% read file setting up
% time list file (here is organized by minutes relative to Old Faithful'seruption)
% slist= '../../stage_list_1min_matlab.txt';
slist= '../../stage_list_all.txt';
[stage_all] = textread(slist,'%s','headerlines',0);

% station list file (here is cross-correlations using 562 as the source station)
% flist= 'station_list.txt'
% flist= '../../stalst'
flist = '../../sta_list_562_select.txt'
[stap_all] = textread(flist,'%s','headerlines',0);

% loop through times
for s = 1:length(stage_all)
 stage = char(stage_all(s));
%stage = cell2mat(stage_all(s));
% stage = str2num(stage);

% if stage > -10 && stage <10
%     stage = fprintf('%.2d\n',stage);
% end

% stage = num2str(stage);

% setting output file name
%ofile = strcat('../../Polarization_out/polarization_4projection_stage.',stage,'.txt')
ofile = strcat('../../Polarization_out/polarization_4projection_stage.',stage,'_select.txt')
fid = fopen(ofile,'w');

%loop through stations
for i = 1:length(stap_all)
stap = char(stap_all(i)); 

% find the data directory
% workdir=strcat('../../stack_wha_1-5_562/stack_wha_1-5_',stap,'/');
workdir=strcat('../../Data_CCF/562/1-5hz/'); %Data_CCF_v2/562/1-5hz/
targetev= strcat('.stage.',stage,'.sac.norm');
z=rsac([workdir stap '.ZZ' targetev]);
r=rsac([workdir stap '.ZN' targetev]);
t=rsac([workdir stap '.ZE' targetev]);
% read station location from the header
stla = lh(z,'STLO');stlo = lh(z,'STLA');stel =  lh(z,'STEL');
tt=z(:,1);

%%%%%%%%%
% set the time window for the siganl of interest (here is 0-1.5s lag time of the cross-correlations)
% make covariance matrix and apply eigen decomposition
% ts = 8001;
% te = 8001+1500;
% ts = 1601;
% te = 1601+150;
ts = 1001;
te = 1001+150;
% X=[z(ts:te,2) r(ts:te,2) t(ts:te,2)];
% figure(1)
% subplot(211)
% plot(z(ts:te,2))
% grid on
% subplot(212)
% plot(flip(z(ts:te,2)))

% X=[flip(z(ts:te,2)) flip(r(ts:te,2)) flip(t(ts:te,2))];
X=[z(ts:te,2) r(ts:te,2)*-1 t(ts:te,2)*-1];
S=X'*X/length(X); 
[V,D] = eig(S);
tmp = diag(D);
% sort the eigenvalues
[lam, lamid] = sort(tmp,'descend');

%%%%%%%
%additional information if you need based on Jurkevics (1988)
LIN = 1 - ((lam(2)+lam(3))/(2*lam(1))); %Polarization
PLAN = 1 - ((2*lam(3))/(lam(1)+lam(2))); %Planarity
HR = lam(2)/lam(1); %ratio between fitst and second lamda 
sign=1;
%if (V(1,lamid(1))<0);sign=-1;end
AZ = rad2deg(atan(V(2,lamid(1))/V(3,lamid(1)))); %Azimuth
EAZ = V(3,lamid(1))*sign; %East-component value
NAZ = V(2,lamid(1))*sign; %North component value
if (AZ<0);AZ=AZ+180;end
INA = rad2deg(acos(abs(V(1,lamid(1))))); %Incidence angle
%%%%%%

%% output station information and the polarized vector
fprintf(fid, '%7s %11.6f %11.6f %8.3f %10.5f %10.5f %10.5f\n',stap, [stlo stla stel V(1,lamid(1)) V(2,lamid(1)) V(3,lamid(1))]');
end %station

fclose(fid);
end %time


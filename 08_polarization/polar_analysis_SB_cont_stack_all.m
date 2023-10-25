clear all;clc;
%read and write sac files
%polarization analysis
% sta = input('Enter center station ...> ','s');
% freq = input('Enter frequency ...> ','s');
sta = ( '149' );
freq = ( '10-20' );
inall = zeros(101,80);
azmall = zeros(101,80);

workdir= strcat('../../Data_CCF/',sta,'/',freq,'hz/');
slist= strcat('../../stage_list_all.txt');
[stage_all] = textread(slist,'%s','headerlines',0);
outdir=strcat('../../Polarization_out_stack/');
if not(isfolder(outdir))
    mkdir(outdir)
end

for s = 1:length(stage_all)
stage = char(stage_all(s))
%ofile = strcat(outdir,'/',sta,'_polarization_all_4project_stage.',stage,'_baz_',freq,'hz.txt')
ofile = strcat(outdir,'/',sta,'_polarization_all_4project_stage.',stage,'_',freq,'hz.txt')

fid = fopen(ofile,'w');
[stap2,num,lat,lon,ele] = textread(['../../UGB21_FALL-Locs_149.txt'],'%s %s %s %s %s','headerlines',0);
for i = 1:length(stap2)

    stap = strcat(sta,'-',char(stap2(i)));

tarN= strcat(stap,'.ZN.stage.',stage,'.sac.norm');
tarE= strcat(stap,'.ZE.stage.',stage,'.sac.norm');
tarZ= strcat(stap,'.ZZ.stage.',stage,'.sac.norm');

if isfile(strcat(workdir,tarZ))

z=rsac([workdir tarZ]);
r=rsac([workdir tarN]);
t=rsac([workdir tarE]);
stla = lh(z,'STLA');stlo = lh(z,'STLO');stel =  lh(z,'STEL');
tt=z(:,1);

%figure(1);clf;hold on
%plot(tt,z(:,2),tt,r(:,2)*-1,tt,t(:,2)*-1);xlim([-1.5 1.5]);legend('ZZ','ZN','ZE');

ts = 1001-50;
te = 1001 + 150;
X=[z(ts:te,2) r(ts:te,2) t(ts:te,2)];
S=X'*X/length(X); 
[V,D] = eig(S);
tmp = diag(D);
[lam, lamid] = sort(tmp,'descend');

%%%%%%%
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
%save('All_incident_angle.mat','inall')
%save('All_azimuth_angle.mat','azmall')

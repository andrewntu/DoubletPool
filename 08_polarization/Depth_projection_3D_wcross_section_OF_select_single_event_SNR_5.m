%%%%%%%%
% 3D backprojection and cross-section for Old Faithful' tremor location  
% For the used formula and details, please see supplmentary in Wu et al. (2019)
% Sin-Mei Wu, University of Utah 
% December, 2019
%%%%%%%%
% Read the ouput file from polarization_analysis_OF.m
% Preliminary visualize the results
% Save the hit count in 3D grids 
% Making cross-section and save the 2D grids ready for Python plot
%%%%%%%%

clear all;clc;close all;
sta = ( '914' );
% time list
% slist= '../../stage_list_1min.txt'
slist= '../../stage_list_all.txt';
[stage_all] = textread(slist,'%s','headerlines',0);

% Old Faithful's location in longitude, latitute, and elevation
of=[-110.828211897200987 44.460437153479248 2240];

% Total grids in cross-section
crosgrid_x=100;
crosgrid_z=20;
crossall = zeros(length(stage_all),crosgrid_x,crosgrid_z); %2D grids for cross-section

% loop through eruption
for y = 26:35
    ee = int2str(y);
% loop through time
 for s = 1:length(stage_all)
% for s = 1:1 
close all;
stage = char(stage_all(s))
smark = strcat('Stage ',stage);
% read the previous output file
%pfile = strcat('../../Polarization_out_correct/',sta,'_polarization_all_4project_stage.',stage,'.txt');
pfile = strcat('../../Polarization_out_single_select_SNR5/eruption_',ee,'/',sta,'_polarization_all_4project_stage.',stage,'_select.txt')
%[stap, stlo, stla, stel, vz, vn, ve,] = textread(pfile,'%7s %11.6f %11.6f %8.3f %10.5f %10.5f %10.5f\n','headerlines',0);
[stap, stlo, stla, stel, vz, vn, ve,] = textread(pfile,'%7s %11.6f %11.6f %10.3f %10.5f %10.5f %10.5f\n','headerlines',0);
% convert the coordinator to local scale in meter using Old Faithful's location as (0,0,0)
[x,y,z] = geodetic2ned(stla,stlo,stel,of(2),of(1),of(3),referenceEllipsoid('GRS 80','m'));

% Note figures are only for visualization here
figure(1);
h = scatter3(0,0,0,'b*');hold on;axis([-210 160 -140 160 -100 20]); %plot Old Faithful  
h = scatter3(y,x,-z,'r^');hold on;title(smark); % plot stations
h.MarkerFaceColor = [0.9 0 0];

% create 3D grid spacing and range in meter 
gx = -200:5:150;
gy = -100:5:150;
gz = -100:5:-5;
total = zeros(length(gx),length(gy),length(gz));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% prepare hit counts in 3D
% loop through stations
for sn = 1:length(stap)
ide = sn;
V = [ve(ide) vn(ide) vz(ide)];
sto = [y(ide) x(ide) -z(ide)];
d=zeros(length(gx),length(gy),length(gz)); %3D array for the hit count 


% only for visualization, plot polarized direction in 3D
t = -200:10:200;
lx=sto(1)+V(1)*t;
ly=sto(2)+V(2)*t;
lz=sto(3)+V(3)*t;
figure(1);
h = plot3(lx,ly,lz,'b');hold on;grid on;
h.LineWidth=1;

%%%%%%%%%
% calculate the hit count based on the distance between grid point and the polarized vector

% distance criteria, imaging the polarized direction is a tube, this parameter will be the radius 
smooth = 10; %meter

for i=1:length(gx)
    for j = 1:length(gy)
        for k=1:length(gz)
        gp=[gx(i) gy(j) gz(k)];
        tmp=gp-sto;
        cro=cross(tmp,V,2);
        d(i,j,k) = sqrt(sum(cro.*cro))./sqrt(sum(V.*V));
        %make the grid counted if the distance to vector is less than 10 meters
        if d(i,j,k)>smooth
           d(i,j,k)=0;
        elseif d(i,j,k)<=smooth
            d(i,j,k)=1;
        end
        end
    end
end

total = total + d;
end %station

%%%%%%%%%
% save figure
h = scatter3(y,x,-z,'r^');hold on;
h.MarkerFaceColor = [0.9 0 0];


outdir= strcat('../../Projection_single_select_SNR5/eruption_',ee);
if not(isfolder(outdir))
  mkdir(outdir)
end

pic1 = strcat(outdir,'/Polarization_stage.',stage,'.png');
%pic1s = strcat('../../Projection_single/Polarization_stage.',stage,'.fig');
saveas(figure(1),pic1);
%savefig(figure(1),pic1s,'compact');

outdirmat= strcat('../../Projection_mat_single_select_SNR5/eruption_',ee);
if not(isfolder(outdirmat))
  mkdir(outdirmat)
end
% save the hit count matrix
mat = strcat(outdirmat,'/polarization_project_total_stage.',stage,'.mat')
save(mat,'total')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% making a cross-section
% 1. seclect two points for your cross-section (in the local coordinates, meter)
crossids = [53.0923  21.6594]; %starting point
crosside = [-39.2567  -24.1387]; %ending point
rad = atan((crosside(2)-crossids(2))/(crosside(1)-crossids(1))); %get the angle 

% here making a longer cross-section from x=-200 to x=150 using the determined angle 
cros1 = [-200 tan(rad)*-200];
cros2 = [150 tan(rad)*150];
crosx = linspace(cros1(1),cros2(1),crosgrid_x);
crosy = linspace(cros1(2),cros2(2),crosgrid_x);
crosxy = linspace(-sqrt(cros1(1).^2+cros1(2).^2),sqrt(cros2(1).^2+cros2(2).^2),crosgrid_x);
crosz = gz;
[X,Y,Z] = meshgrid(gx,gy,gz);
[Xq,Yq,Zq] = meshgrid(crosx,crosy,crosz);
ttotal = permute(total,[2 1 3]);
cV = interp3(X,Y,Z,ttotal,Xq,Yq,Zq); %interpolation
tttotal = permute(cV,[2 1 3]);

% creating cross-section hit count in 2D
[xx,zz]=meshgrid(crosxy,crosz);
sur=zeros(crosgrid_x,crosgrid_z);
for i = 1:length(crosx)
     for k = 1:length(crosz)
          sur(i,k)=tttotal(i,i,k);
     end
end

% visualize the cross-section hit count 
figure(2);
crossall(s,:,:)=sur;
surf(xx,zz,sur');caxis([1 20]);view(0,90);colormap(flipud(hot));hold on;
colorbar;title(smark);axis([-160 100 min(gz) 0]);grid off;

% save the cross-section plot
pic2 = strcat(outdir,'/Surf_cross_section_stage.',stage,'.png');
saveas(figure(2),pic2);

end  %time
end  %eruption

% save the cross-section grid file for all the time windows (use this to have a better plot in Pyhton)
mat2 = '../../Projection_mat_single_select_SNR5/cross-Z.mat';
save(mat2,'crossall')


% save the station location in mat
sta = [y,x,-z];
mat3 = strcat('../../Projection_mat_single_select_SNR5/staloc_select.mat');
save(mat3,'sta')

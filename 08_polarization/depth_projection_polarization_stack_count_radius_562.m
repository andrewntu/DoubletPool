clear all;clc;close all;
%depth projection of polarization

sta = ( '914' );
freq = ( '1-5' );

dist_cri = 0; % in meter, compared to Old Faithful Cone

%slist= '../../stage_list_1min.txt'
%[stage_all] = textread(slist,'%s','headerlines',0);
%of=[-110.828211897200987 44.460437153479248 2240];
of=[-110.828149 44.460461 2240];

smooth = 10; %5; %10; %meter

crosgrid_x=100;
crosgrid_z=20;
%crossall = zeros(length(stage_all),crosgrid_x,crosgrid_z); %2D grids for cross-section

slist= strcat('../../stage_list_all.txt');
[stage_all] = textread(slist,'%s','headerlines',0);
crossall = zeros(length(stage_all),crosgrid_x,crosgrid_z); %2D grids for cross-section
for s = 1:length(stage_all)
	close all;
	figure(1);
	h = scatter3(0,0,0,'b*');hold on;axis([-210 160 -140 160 -100 20]);   
	    
	stage = char(stage_all(s))
	smark = strcat('Stage ',stage);
	pfile = strcat('../../Polarization_out_stack_count_562/',sta,'_polarization_all_4project_stage.',stage,'_select.txt')
	[stap, stlo, stla, stel, vz, vn, ve,] = textread(pfile,'%7s %11.6f %11.6f %8.3f %10.5f %10.5f %10.5f\n','headerlines',0);

	[x,y,z] = geodetic2ned(stla,stlo,stel,of(2),of(1),of(3),referenceEllipsoid('GRS 80','m'));

	wgs84 = wgs84Ellipsoid('m');
	dist = distance(stla, stlo, of(2),of(1), wgs84);

	h = scatter3(y,x,-z,'r^');hold on;title(smark);
	h.MarkerFaceColor = [0.9 0 0];
	%total = zeros(66,49,20);
	total = zeros(71,51,20);

	for sn = 1:length(stap)
	ide = sn;
dd = dist(ide);
	%gx = min(y):5:max(y);
	%gy = min(x):5:max(x);
	gx = -200:5:150;
	gy = -100:5:150;
	gz = -100:5:-5;
	V = [ve(ide) vn(ide) vz(ide)];
	sto = [y(ide) x(ide) -z(ide)];
	d=zeros(length(gx),length(gy),length(gz));


	t = -200:10:200;
	lx=sto(1)+V(1)*t;
	ly=sto(2)+V(2)*t;
	lz=sto(3)+V(3)*t;
	figure(1);
	h = plot3(lx,ly,lz,'b');hold on;grid on;
	h.LineWidth=1;


	for i=1:length(gx)
	    for j = 1:length(gy)
		for k=1:length(gz)
		gp=[gx(i) gy(j) gz(k)];
		tmp=gp-sto;
		cro=cross(tmp,V,2);
		d(i,j,k) = sqrt(sum(cro.*cro))./sqrt(sum(V.*V));
		if d(i,j,k)>smooth
		   d(i,j,k)=0;
		elseif (d(i,j,k)<=smooth) && (dd <= dist_cri)
		    d(i,j,k)=0.25; % if distance is too close, down-weight the value.
		elseif (d(i,j,k)<=smooth) && (dd > dist_cri)
		    d(i,j,k)=1;
		end
		end
	    end
	end


	total = total + d;
	end

	h = scatter3(y,x,-z,'r^');hold on;
	h.MarkerFaceColor = [0.9 0 0];

	outdir= strcat('../../Projection_stack_count_562/');
	if not(isfolder(outdir))
	mkdir(outdir)
	end

	pic1 = strcat(outdir,'/Polarization_stage.',stage,'.png');
	saveas(figure(1),pic1);

	outdirmat= strcat('../../Projection_mat_stack_count_562/');
	if not(isfolder(outdirmat))
	mkdir(outdirmat)
	end

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
	surf(xx,zz,sur');caxis([1 10]);view(0,90);colormap(flipud(hot));hold on;
	colorbar;title(smark);axis([-160 100 min(gz) 0]);grid off;

	% save the cross-section plot
	pic2 = strcat(outdir,'/Surf_cross_section_stage.',stage,'.png');
	saveas(figure(2),pic2);
end
% save the station location in mat
% sta = [y,x,-z];
% mat3 = strcat('../../Projection_count_mat/staloc_select.mat');
% save(mat3,'sta')
% 
% 
% mat2 = '../../Projection_count_mat/cross-Z.mat';
% save(mat2,'crossall')

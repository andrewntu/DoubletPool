clear all;clc;close all;

of=[-110.828149 44.460461 2240];

pfile = '../../Polarization_out_single_count/eruption_32/914_polarization_all_4project_stage.-40_select.txt'
[stap, stlo, stla, stel, vz, vn, ve,] = textread(pfile,'%7s %11.6f %11.6f %8.3f %10.5f %10.5f %10.5f\n','headerlines',0);

[x,y,z] = geodetic2ned(stla,stlo,stel,of(2),of(1),of(3),referenceEllipsoid('GRS 80','m'));

wgs84 = wgs84Ellipsoid('m');
dist = distance(stla, stlo, of(2),of(1), wgs84);

in_10 = 0;
in_20 = 0;
in_30 = 0;
in_40 = 0;
in_50 = 0;
out_50 = 0;

for i=1:length(dist)
    if dist(i) < 10
        in_10 = in_10 + 1;
    elseif (dist(i) >= 10) && (dist(i) < 20)
        in_20 = in_20 + 1;
    elseif (dist(i) >= 20) && (dist(i) < 30)
        in_30 = in_30 + 1;
    elseif (dist(i) >= 30) && (dist(i) < 40)
        in_40 = in_40 + 1;
    elseif (dist(i) >= 40) && (dist(i) < 50)
        in_50 = in_50 + 1;    
    else
        out_50 = out_50 + 1;
    end
end

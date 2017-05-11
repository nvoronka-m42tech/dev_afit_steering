function [  ] = excusa ( )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


sc12_w = 0.239 ;     % 12U spacecraft endplate width
sc12_h = 0.229 ;     % 12U spacecraft endplate height
%sc6_w  = 0.200 ;     % 6U  spacecraft endplate width
%sc6_h  = 0.200 ;     % 6U  spacecraft endplate height

f_lo = 5.50e9 ;
f_hi = 5.65e9 ;

f_center  = 0.5 * (f_lo+f_hi) ;
bandwidth = (f_hi-f_lo) / f_center ;
bw_pct    = bandwidth / f_center * 100 ;

lambda_lo = 299792458 / f_lo ;

max_scan_angle_deg = 65 ;

max_spacing_lambda = 1 / (1+sin(degtorad(max_scan_angle_deg))) 

max_spacing = max_spacing_lambda * lambda_lo 

% max_spacing = 0.5 * lambda_lo ;

%%%%%%%%%%%%%%%%%

% line([-0.5*sc6_w -0.5*sc6_w 0.5*sc6_w 0.5*sc6_w -0.5*sc6_w], [-0.5*sc6_h 0.5*sc6_h 0.5*sc6_h -0.5*sc6_h -0.5*sc6_h],'Color','green') ;
line([-0.5*sc12_w -0.5*sc12_w 0.5*sc12_w 0.5*sc12_w -0.5*sc12_w], [-0.5*sc12_h 0.5*sc12_h 0.5*sc12_h -0.5*sc12_h -0.5*sc12_h],'Color','blue') ;

grid on
axis ([-0.125 0.125 -0.125 0.125]) ;
axis square
hold on
set (gcf,'Color',[1,1,1]) ; % set background color to white

array_r = 4 ;
array_c = 5 ;

for r = 1:array_r
    for c = 1:array_c
        xx = (r - 0.5*array_r - 0.5) * max_spacing ;
        yy = (c - 0.5*array_c - 0.5) * max_spacing ;
        plot (xx,yy,'bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',12) ;
    end
end
hold off
title ('Rectangular Array') ;

%%%%%%%%%%%%%%%%%

figure 

%line([-0.5*sc6_w -0.5*sc6_w 0.5*sc6_w 0.5*sc6_w -0.5*sc6_w], [-0.5*sc6_h 0.5*sc6_h 0.5*sc6_h -0.5*sc6_h -0.5*sc6_h],'Color','green') ;
line([-0.5*sc12_w -0.5*sc12_w 0.5*sc12_w 0.5*sc12_w -0.5*sc12_w], [-0.5*sc12_h 0.5*sc12_h 0.5*sc12_h -0.5*sc12_h -0.5*sc12_h],'Color','blue') ;

xx = [0.0] ;
yy = [0.0] ;

for s = 0:1:5
    xx = [xx max_spacing*cos(s/6*2*pi)] ;
    yy = [yy max_spacing*sin(s/6*2*pi)] ;
end
for s = 0:1:5
    xx = [xx 2*max_spacing*cos(s/6*2*pi)] ;
    yy = [yy 2*max_spacing*sin(s/6*2*pi)] ;
end

for s = 0:1:5
    xx = [xx xx(2+s)+(cos(pi/3)*xx(2+s)-sin(pi/3)*yy(2+s))] ;
    yy = [yy yy(2+s)+(sin(pi/3)*xx(2+s)+cos(pi/3)*yy(2+s))] ;
end

grid on
axis ([-0.125 0.125 -0.125 0.125]) ;
axis square
hold on
set (gcf,'Color',[1,1,1]) ; % set background color to white

for x = 1:length(xx)
        plot (xx,yy,'bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',12) ;
end
hold off
title ('Hexagonal Array') 

%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%

num_elements = 20 ;

xx = zeros (num_elements,1) ;
yy = zeros (num_elements,1) ;

num_found = 0 ;

while (num_found < num_elements)
    xxx = (rand() * 2 - 1) * ((0.5 * sc12_w) - max_spacing) ;
    yyy = (rand() * 2 - 1) * ((0.5 * sc12_h) - max_spacing) ;

    if (num_found > 0)
        spacing_ok = 1 ;
        for ndx = 1:num_found
            spacing = sqrt((xxx-xx(ndx))^2+(yyy-yy(ndx))^2) ;
            if (spacing <= max_spacing)
                spacing_ok = 0 ;
            end
        end
        
        if (spacing_ok)
            num_found = num_found + 1 
            xx(num_found) = xxx ;
            yy(num_found) = yyy ;
        end
    else
        num_found = num_found + 1 
        xx(num_found) = xxx ;
        yy(num_found) = yyy ;
    end
        
end

figure 

%line([-0.5*sc6_w -0.5*sc6_w 0.5*sc6_w 0.5*sc6_w -0.5*sc6_w], [-0.5*sc6_h 0.5*sc6_h 0.5*sc6_h -0.5*sc6_h -0.5*sc6_h],'Color','green') ;
line([-0.5*sc12_w -0.5*sc12_w 0.5*sc12_w 0.5*sc12_w -0.5*sc12_w], [-0.5*sc12_h 0.5*sc12_h 0.5*sc12_h -0.5*sc12_h -0.5*sc12_h],'Color','blue') ;

grid on
axis ([-0.125 0.125 -0.125 0.125]) ;
axis square
hold on
set (gcf,'Color',[1,1,1]) ; % set background color to white

for x = 1:length(xx)
        plot (xx,yy,'bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',12) ;
end
hold off
title ('Random (Monte-Carlo) Array') ;


end

function h = plot_circle(x,y,r)

npoints = 50 ;

theta = 0:pi/npoints:2*pi;

xunit = r * cos(th) + x;
yunit = r * sin(th) + y;

h = plot(xunit, yunit);

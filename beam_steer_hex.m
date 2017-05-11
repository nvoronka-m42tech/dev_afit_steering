function [ steering_vector_out ] = beam_steer_hex ( steer_az_deg, steer_el_deg, steer_freq_hz, toplot, toprint )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if (~exist ('steer_el_deg', 'var'))
    steer_el_deg = 0.0 ;
end

if (~exist ('steer_az_deg', 'var'))
    steer_az_deg = 0.0 ;
end

if (~exist ('steer_freq_hz', 'var'))
    steer_freq_hz = 0.5 * (5.550e9 + 5.650e9) ;
end

if (~exist ('toplot', 'var'))
    toplot = 0 ;
end

if (~exist ('towrite', 'var'))
    towrite = 0 ;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Antenna Parameters
%

operating_freq_min_hz = 5.55e9 ;    % Antenna operating frequency range minimum (GHz)
operating_freq_max_hz = 5.65e9 ;    % Antenna operating frequency range maximum (GHz)

num_elements         = 19 ;                 % Number of elements in array
element_radius       = 0.7275*0.5*0.0254;   % Radius of circular patch array element
ring_spacing_radius  = 1.1 * 0.0254 ;       % Ring element spacing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute phasded array antenna element locations
%
element_position  = zeros (3, num_elements) ;   % (X,Y,Z) location of antenna elements in meters

element_normal_az = zeros (1, num_elements) ;
element_normal_el = zeros (1, num_elements) ;

% Center element (at origin)
element_position (:,1) = [0, 0 0] ;

% First ring
last_element = 1 ;                  % Last element number of previous 'ring'
ring_elements = 6 ;                 % Number of elements in current ring
ring_radius   = 1.1 * 0.0254 ;      % Radius of ring in meters
for ndx = (last_element+1):(last_element+1+ring_elements-1)
    angle = (ndx - (last_element+1)) * (2*pi) / ring_elements ;
    element_position (:,ndx) = [0 ring_radius*cos(angle) ring_radius*sin(angle)] ;
end

% Second ring
last_element = ndx ;                % Last element number of previous ring
ring_elements = 12 ;                % Number of elements in current ring
ring_radius   = 2 * 1.1 * 0.0254 ;  % Radius of ring in meters
for ndx = (last_element+1):(last_element+1+ring_elements-1)
    angle = (ndx - (last_element+1)) * (2*pi) / ring_elements ;
    element_position (:,ndx) = [0 ring_radius*cos(angle) ring_radius*sin(angle)] ;
end

if (towrite)
    fprintf (1, 'Created an array of %d elements\n', num_elements) ;
    for ndx = 1:num_elements
        fprintf (1, '   Element %02d is at [%6.3f, %6.3f] (R=%5.3f)\n', ndx, ...
                 element_position(1, ndx), element_position(2, ndx), sqrt(element_position(1,ndx)^2+element_position(2,ndx)^2)) ;
    end    
end

if (toplot)
    % Plot Antenna Array
    figure (1) ; clf ;

    sc12_w = 0.239 ;     % 12U spacecraft endplate width
    sc12_h = 0.229 ;     % 12U spacecraft endplate height

    line([-0.5*sc12_w -0.5*sc12_w 0.5*sc12_w 0.5*sc12_w -0.5*sc12_w], [-0.5*sc12_h 0.5*sc12_h 0.5*sc12_h -0.5*sc12_h -0.5*sc12_h],'Color','blue') ;

    grid on
    axis ([-0.125 0.125 -0.125 0.125]) ;
    axis square
    hold on
    set (gcf,'Color',[1,1,1]) ; % set background color to white

    % plot (element_position(2,:),element_position(3,:),'bo','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',12) ;

    circles (element_position(2,:),element_position(3,:), element_radius, 'facecolor', 'blue') ;

    for ndx = 1:num_elements
        text (element_position(2,ndx),element_position(3,ndx),sprintf ('%d',ndx), ...
            'HorizontalAlignment', 'center', 'Color', 'white') ;
    end

    hold off
    title ('Gemini Phased Array - As built')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set up phased array elemnt
%

cosine_power = 0.7 ;    

phased_element = phased.CosineAntennaElement ('CosinePower', [cosine_power cosine_power])  ;
phased_element.FrequencyRange = [operating_freq_min_hz operating_freq_max_hz] ;

[element_pattern, el_angle, az_angle] = pattern (phased_element, ...
        steer_freq_hz, [-180:180], 0, 'CoordinateSystem','polar', ...
        'Type', 'directivity') ; % , 'Normalize', false) ;

fprintf (1, '\nMax element gain = %g dBi\n', max (element_pattern)) ;

ndx = find (el_angle == 60) ;
fprintf (1, 'Element Gain at %d deg = %g dBi\n', el_angle(ndx), element_pattern(ndx)) ;
ndx = find (el_angle == 65) ;
fprintf (1, 'Element Gain at %d deg = %g dBi\n', el_angle(ndx), element_pattern(ndx)) ;

if (toplot)
    % 2-D polar plot
    figure (2) ; clf ;
    pattern (phased_element, ...
            steer_freq_hz, [-180:180], 0, 'CoordinateSystem','polar', ...
            'Type', 'directivity') ; % , 'Normalize', false) ;
    % 3-D plot of element gain
    figure (3) ; clf ; 
    plot (el_angle, element_pattern, 'b-') ;
    xlabel ('Elevation Angle (deg)') ;
    ylabel ('Gain (dBi)') ;
    title  (sprintf ('Element Pattern (Cosine Element with Power %g)', cosine_power)) ;
    grid on ; grid minor ;

    figure (4) ; clf ;
    pattern (phased_element, steer_freq_hz) ;
    view (90, -60) ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set up phased array for computations
%

phased_array = phased.ConformalArray('Element',phased_element,...
                                    'ElementPosition',element_position,...
                                    'ElementNormal',[element_normal_az; element_normal_el]);
if (toplot)
    figure (5) ; clf ;
    viewArray(phased_array,'ShowNormals',true)
    view(90,-60) ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute steering vector and analyze beam pattern
%

c = physconst('LightSpeed') ;       % Speed of light (m/sec)

    % Setup steering vector object
phased_sv_obj = phased.SteeringVector ('SensorArray', phased_array, ...
                                       'IncludeElementResponse', true, 'EnablePolarization', false) ;
    % Compute steering vector
steering_vector_out = step (phased_sv_obj, steer_freq_hz, [steer_az_deg; steer_el_deg])

figure (6) ; clf ;
plotResponse(phased_array, steer_freq_hz, c, ...
    'Format', 'Polar', 'RespCut','3D', 'Normalize', false, ...
    'Weights',steering_vector_out)

title (sprintf ('Beam Steered to [az,el] = [%g, %g]', steer_az_deg, steer_el_deg)) ;

figure (7) ; clf ;
plotResponse(phased_array, steer_freq_hz, c, ...
    'Format', 'Line', 'RespCut','Az', 'Normalize', false, ...
    'Weights',steering_vector_out)


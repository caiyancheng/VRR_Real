function [LMS, contrast_pulse]  = create_gabor( im_size, pix_per_deg, fps, s_freq, t_freq, orientation, LMS_mean, LMS_delta, ge_sigma, eccentricity, phase)
% Create a Gabour patch (or a video) according to the stimulus specification
%
% LMS = create_gabor( im_size, pix_per_deg, fps, s_freq, t_freq, orientation, LMS_mean, LMS_delta, area, eccentricity)
%
% im_size - Size of the resulting image/video as [height width frames] in
%           pixels
% pix_per_deg - the spatial resolution in pixels per degree
% fps - the temporal resolution in frames per second
% s_freq - spatial frequency
% t_freq - temporal frequency
% orientation - stimulus orientation in degrees. 0 deg will modulate along
%               the horizontal direction
% LMS_mean - the LMS colour of the background as a [1 3] vector
% LMS_delta - the LMS modeulation as a [1 3] vector. The values will
%             oscilate between LMS_mean-LMS_delta and LMS_mean + LMS_delta
% ge_sigma - the sigma of the Gaussian envelope that limits the size of the
%         stimulus
% eccentricity - eccentricity in degrees. The stimulus is always moved to
%         the right. The fixation point is awlays in the centre. Make sure
%         that the im_size is large enough to accommodate the eccentric
%         stimulus. 
%
% phase - 0 for sine grating, 90 for cosine grating
%
% LMS - [height width 3] image or [height width 3 frames] video in the LMS
%       space

if length(im_size)==2
    frames = 1;
else
    frames = im_size(3);
end

if ~exist( 'phase', 'var' )
    phase = 0;
end

size_deg = im_size / pix_per_deg;

[xx, yy] = meshgrid( linspace( -size_deg(2)/2, size_deg(2)/2, im_size(2) )-eccentricity, linspace( -size_deg(1)/2, size_deg(1)/2, im_size(1) ) );

rr = xx * cosd( -orientation ) + yy * sind( -orientation );

sin_grating = sin( 2*pi*rr*s_freq + deg2rad(phase) ) .* reshape( LMS_delta, [1 1 3] );

t = linspace( 0, frames/fps, frames );
temp_sin = reshape( cos( 2*pi*t*t_freq ), [1 1 1 frames] );

R2 = xx.^2 + yy.^2;
ge = exp(-R2/(2.*ge_sigma^2)); % Gaussian envelope

LMS_mean3 = reshape( LMS_mean, [1 1 3] );

LMS = LMS_mean3 + sin_grating .* ge .* temp_sin;

contrast_pulse = sin_grating .* ge;

end
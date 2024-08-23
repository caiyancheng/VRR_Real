%%
clear all; close all;

n = 200; % number of frames in the gif
frames = 1:n;

% background colors centred around D65 gray
xy_gray = XYZ2Yxy(whitepoint( 'd65' ));
xy_gray = xy_gray(2:3);
xy_r = sin(2*pi*(1/100).*frames).*0.1;
xy_theta = (2*pi/n).*frames;
xy_x = xy_gray(1) + (xy_r .* cos(xy_theta));
xy_y = xy_gray(2) + (xy_r .* sin(xy_theta));
xy_bck_cols = [xy_x', xy_y'];
% figure, scatter(xy_bck_cols(:,1), xy_bck_cols(:,2))

% Modulation colors
contrast = [40, 3, 1];
LMS_delta(1, :) = [0.7347	0.3163	0.02082].*contrast(1); %ach
LMS_delta(2,:) = [0.762860489	-0.646494145	-0.009444331].*contrast(2); %rg
LMS_delta(3,:) = [0.450449715	0.274890824	0.849429272].*contrast(3); %yv
points = [LMS_delta; LMS_delta(1, :)]; % Fourth point
X = points(:,1);
Y = points(:,2);
Z = points(:,3);
t = 1:4;  % Assuming 4 points
tq = linspace(1, 4, 200);  % 200 points between 1 and 4
Xq = spline(t, X, tq);
Yq = spline(t, Y, tq);
Zq = spline(t, Z, tq);
LMS_delta_cols = [Xq; Yq; Zq]';

% Area
areas = 2.^sin(2*pi*(4/200).*frames);
% figure, plot(frames, areas);

% TF 
tf = [0 5 10 7 2];
gif_fps = 20; %
tf_array = repmat(tf, [n/length(tf), 1]);
tf_array = tf_array(:);
f = tf_array./gif_fps;
tf_contrasts = cos(2*pi.*f.*frames');
% figure, plot(frames, tf_contrasts);

% lum
lums = 10.^((sin(2*pi*(1/200).*frames)+1.6990)./2);
% figure, plot(frames, lums);

% ecc
ecc_r = sin(2*pi*(1/100).*frames).*5;
ecc_theta = (2*pi/n).*frames;
ecc_x = (ecc_r .* cos(ecc_theta));
ecc_y = (ecc_r .* sin(ecc_theta));
% figure, scatter(ecc_x, ecc_y)


%% Create gabor

gifname = 'jov_icon2.gif';

addpath(genpath('../../../Github_repos/castleCSF/'));

csf_model = CSF_castleCSF();

im_size = [96 96];
pix_per_deg = 10;
s_freq = [1];
orientation = 0;
phase = 90;

lw = 6;
h = figure;
set(gca, 'Units', 'pixels');
set(gca, 'Position',  [0 0 96 96])
sz = [96 96];

show_plot = true;

for ii = 1:n
    
    clf;
    hold on,

    bck_col = xyz2lms2006( Yxy2XYZ([1, xy_bck_cols(ii, :)]) );
    
    [G_LMS_gabor, ~] = create_gabor( im_size, pix_per_deg, 1, s_freq, 0,...
        orientation, bck_col.*lums(ii), 0.3*LMS_delta_cols(ii, :).*tf_contrasts(ii),... 
        areas(ii), ecc_r(ii), phase );
    G_RGB_gabor = cm_xyz2rgb( lms2006_2xyz(G_LMS_gabor) );
    I_gabor = (G_RGB_gabor/22).^(1/2.2);
    I_gabor = real(I_gabor);

    if ~show_plot

        clf, 
        imshow(I_gabor);
        [imind,cm] = rgb2ind(I_gabor,256);

    else

        lms_background = bck_col.*lums(ii);
        lms_modulation_delta = (0.3*LMS_delta_cols(ii, :).*lums(ii))-lms_background;
        lms_delta_norm = lms_modulation_delta./norm(lms_modulation_delta);
    
        s_frequency = logspace( log10(0.5), log10(64), 30 );    % Spatial frequency in cycles per degree
        csf_pars = struct( 's_frequency', s_frequency(:), 't_frequency', tf_array(ii),... 
            'orientation', orientation, 'area', areas(ii), 'eccentricity', abs(ecc_r(ii)),...
            'lms_bkg', lms_background,...
            'lms_delta', lms_delta_norm);    
     
        S = csf_model.sensitivity( csf_pars );        
        S = reshape( S, size(s_frequency) );
        
        plot(log10(s_frequency), log10(S),... 
                'Color', 'b', 'LineWidth', lw,... 
                'LineStyle', '-');  
        axis square
        f_lab = [ 0.1000        2.0000       10 ];
        xticks = log10(f_lab);
        set( gca, 'XTick', xticks );
        set( gca, 'XTickLabel', [] );
    
        yticks = [0.1 1 10 100 1000];
        set( gca, 'YTick', log10(yticks) );
        set( gca, 'YTickLabel', [] );
        
        xlim( log10([0.5, 50]));
        ylim( log10([0.01 1000]) );       
        grid on
        set (gca, 'XMinorGrid', 'off');
        set (gca, 'MinorGridAlpha', 0);
    
        hl = image(xlim, ylim, I_gabor);
        uistack(hl, 'bottom');
    
        drawnow
        im = frame2im(getframe);
        szf = size(im);
        res = sz./szf(1:2);
        im2 = imresize(im, res(1));
        im2 = im2(1:sz(1), 1:sz(2), :);
    
        [imind,cm] = rgb2ind(im2,256);

    end


    if 1
        if ii == 1
            imwrite(imind,cm,gifname,'gif', 'Loopcount',inf); 
        else
            imwrite(imind,cm,gifname,'gif', 'DelayTime',0.05, 'WriteMode','append'); 
        end
    end

end

rmpath(genpath('../../../Github_repos/castleCSF/'));



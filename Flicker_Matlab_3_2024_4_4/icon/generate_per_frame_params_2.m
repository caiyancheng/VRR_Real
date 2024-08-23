%%
clear all; close all;

n_all = 210; % number of frames in the gif
frames_all = 1:n_all;
n = 35; 
frames = 1:n;

im_scale = 4;


% background colors centred around D65 gray
xy_gray = XYZ2Yxy(whitepoint( 'd65' ));
xy_gray = xy_gray(2:3);
xy_r = sin(2*pi*(1/10).*frames).*0.15;
xy_theta = (2*pi/n).*frames;
xy_x = xy_gray(1) + (xy_r .* cos(xy_theta));
xy_y = xy_gray(2) + (xy_r .* sin(xy_theta));
xy_bck_cols(1:n_all,1) = xy_gray(1);
xy_bck_cols(1:n_all,2) = xy_gray(2);
xy_bck_cols(1:n, :) = [xy_x', xy_y'];
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
tq = linspace(1, 4, n);  % 200 points between 1 and 4
Xq = spline(t, X, tq);
Yq = spline(t, Y, tq);
Zq = spline(t, Z, tq);
LMS_delta_cols_sub = [Xq; Yq; Zq]';
LMS_delta_cols = zeros(n_all, 3);
LMS_delta_cols(1:n_all, 1) = LMS_delta_cols_sub(1, 1);
LMS_delta_cols(1:n_all, 2) = LMS_delta_cols_sub(1, 2);
LMS_delta_cols(1:n_all, 3) = LMS_delta_cols_sub(1, 3);
LMS_delta_cols(36:70, :) = LMS_delta_cols_sub;

% Area
areas_sub = 2.^sin(2*pi*(1/(n)).*frames);
areas = ones(1, n_all);
areas(71:105) = areas_sub;
% figure, plot(frames_all, areas);

% TF 
tf = [0 2 5 10];
gif_fps = 20; %
tf_array = zeros(n_all, 1);
tf_array(111:120) = tf(2);
tf_array(121:130) = tf(3);
tf_array(131:140) = tf(4);
% tf_array = repmat(tf, [n/length(tf), 1]);
tf_array = tf_array(:);
f = tf_array./gif_fps;
tf_contrasts = cos(2*pi.*f.*frames_all');
% figure, plot(frames, tf_contrasts(106:140));
% figure, plot(frames_all, tf_contrasts);

% lum
lums_sub = 10.^((sin(2*pi*(1/35).*frames)+1.6990)./2);
lums = lums_sub(1,35).*ones(1, n_all);
lums(141:175) = lums_sub;
% figure, plot(frames_all, lums);

% ecc
ecc_r = zeros(1, n_all);
ecc_r_sub = sin(2*pi*(1/(35*2)).*frames).*5;
ecc_theta = (2*pi/n).*frames;
ecc_x = (ecc_r_sub .* cos(ecc_theta));
ecc_y = (ecc_r_sub .* sin(ecc_theta));
% figure, scatter(ecc_x, ecc_y)
ecc_r(176:210) = ecc_r_sub;


%% Create gabor

gifname = 'jov_icon_384px.gif';

addpath(genpath('../../../Github_repos/castleCSF/'));

csf_model = CSF_castleCSF();

im_size = [96 96].*im_scale;
pix_per_deg = 10;
s_freq = [1];
orientation = 0;
phase = 90;

lw = 6;
h = figure;
set(gca, 'Units', 'pixels');
set(gca, 'Position',  [0 0 im_size])
sz = im_size;

show_plot = true;

for ii = 1:n_all
    
    clf;
    hold on,

    bck_col = xyz2lms2006( Yxy2XYZ([1, xy_bck_cols(ii, :)]) );
    
    [G_LMS_gabor, ~] = create_gabor( im_size, pix_per_deg, 1, s_freq./im_scale, 0,...
        orientation, bck_col.*lums(ii), 0.2*LMS_delta_cols(ii, :).*tf_contrasts(ii),... 
        areas(ii).*im_scale, ecc_r(ii), phase );
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
        sel_y_lim = S < 0.05;
        S(sel_y_lim) = NaN;
        
        plot(log10(s_frequency), log10(S),... 
                'Color', 'b', 'LineWidth', lw,... 
                'LineStyle', '-');  
        axis square
        f_lab = [ 0.1000   2.0000   10 ];
        xticks = log10(f_lab);
        set( gca, 'XTick', xticks );
        set( gca, 'XTickLabel', [] );
    
        yticks = [0.1 1 10 100 1000];
        set( gca, 'YTick', log10(yticks) );
        set( gca, 'YTickLabel', [] );
        
        xlim( log10([0.2, 64]));
        ylim( log10([0.005 1000]) );

        im_x_lim = xlim; im_x_lim(1) = log10(0.5);
        im_y_lim = ylim; im_y_lim(1) = log10(0.01);

        grid off
        set (gca, 'XMinorGrid', 'off');
        set (gca, 'MinorGridAlpha', 0);
        
%         xlabel('cpd');
%         ylabel('S');

        bck_colour_plot = squeeze(I_gabor(1, 1, :));
        bck_colour_plot = min(bck_colour_plot, [1; 1; 1]);
        bck_colour_plot = max(bck_colour_plot, [0; 0; 0]);
        set(gca, 'Color', bck_colour_plot);

        annotation('arrow', [0.3, 0.3], [0.25 0.9],...
            'LineWidth', 2);
        annotation('arrow', [0.3, 0.8], [0.25 0.25],...
            'LineWidth', 2);
        text(log10(0.27), log10(3), '\it{S}',...
            'FontSize',30, 'Rotation', 90,...
            'Interpreter', 'tex',...
            'FontWeight','bold');
        text(log10(3), log10(0.02), '\rho',...
            'FontSize',30,...
            'Interpreter', 'tex',...
            'FontWeight','bold');

        hl = image(im_x_lim, im_y_lim, I_gabor);
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
            continue;
        elseif ii == 2
            imwrite(imind,cm,gifname,'gif', 'Loopcount',inf); 
        else
            imwrite(imind,cm,gifname,'gif', 'DelayTime',0.05, 'WriteMode','append'); 
        end
    end

end

rmpath(genpath('../../../Github_repos/castleCSF/'));



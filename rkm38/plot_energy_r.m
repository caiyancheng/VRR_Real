
if ~exist( 'CSF_stelaCSF', 'class' )
    addpath( fullfile( pwd, '..', '..', 'csf_datasets', 'models' ) );
end

%energy_func = @flicker_disc_energy;
energy_func = @flicker_disc_energy_spatial;

%csf_model = CSF_stelaCSF();
csf_model = CSF_Barten_HF();
%csf_model = CSF_castleCSF();

OMEGAs = [0.5 1 2 4 8];

figure(1);
html_change_figure_print_size( gcf, 16, 10 );
clf;
hh = [];
%r = linspace( 0.02, 30, 1024 );
%area = pi*r.^2;
area = logspace( log10(0.01), log10(8000), 1024 );
r = sqrt(area/pi);

for ff=1:length(OMEGAs)

    E = energy_func( csf_model, OMEGAs(ff), r );

    hh(ff) = plot( area, E, 'DisplayName', sprintf( '%g Hz', OMEGAs(ff) ) );
    hold on;

end

xticks( [0.8 3.1 800 2400] );
legend( hh, 'Location', 'Best' );
xlabel( 'Area [deg^2]' )
set( gca, 'XScale', 'log' );
ylabel( 'Energy' );
grid on
xlim( [area(1) area(end)] );
set( gca, 'YScale', 'log' );
%ylim( [500 15000] );

fname = [ 'plot_area_' csf_model.short_name() '.png' ];
exportgraphics( gcf, fname );


figure(2);
html_change_figure_print_size( gcf, 16, 10 );
clf;

hh = [];
omega = linspace( 0, 16, 1024 );
AREAs = [0.8 3.1 800 2400];

for ff=1:length(AREAs)

    E = energy_func( csf_model, omega, sqrt(AREAs(ff)/pi));

    if ff==4
        lstyle = '--';
    else
        lstyle = '-';
    end

    hh(ff) = plot( omega, E, lstyle, 'DisplayName', sprintf( '%g deg^2', AREAs(ff) ) );
    hold on;

end

%xticks( [0.8 3.1 800 2400] );
legend( hh, 'Location', 'Best' );
xlabel( 'Temporal freq. [Hz]' )
%set( gca, 'XScale', 'log' );
set( gca, 'YScale', 'log' );
ylabel( 'Energy' );
grid on
%xlim( [area(1) area(end)] );

fname = [ 'plot_freq_' csf_model.short_name() '.png' ];
exportgraphics( gcf, fname );



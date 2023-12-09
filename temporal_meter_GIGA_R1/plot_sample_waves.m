%% plot waveforms

figure,
ylim = 0.5;

subplot(3, 1, 1)
load('data240.mat');
stairs( time, L );
xlabel( 'milliseconds' );
ylabel( 'Sensor reading' );
title('240 Hz refresh rate')
% ylim([0, ylim]);

subplot(3, 1, 2)
load('data120.mat');
stairs( time, L );
xlabel( 'milliseconds' );
ylabel( 'Sensor reading' );
title('120 Hz refresh rate')
% ylim([0, ylim]);

subplot(3, 1, 3)
load('data32.mat');
stairs( time, L );
xlabel( 'milliseconds' );
ylabel( 'Sensor reading' );
title('240 Hz refresh rate + 32Hz sine wave')
% ylim([0, ylim]);
% 


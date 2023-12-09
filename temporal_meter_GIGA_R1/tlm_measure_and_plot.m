l = TemporalLightMeter();
display( 'Taking measurement' );
tic
[time, L] = l.measure(10, 'edge_trigerred', true, 'bright_mode', false);
toc

display( 'Measurement done' );

clf
stairs( time, L );
xlabel( 'milliseconds' );
ylabel( 'Sensor reading' );

ylim([0, 1]);

l.close();


l = TemporalLightMeter();
display( 'Taking measurement' );
tic
[t, L] = l.get_last_measurement();
toc
display( 'Measurement done' );

clf
stairs( t/1000, L );
xlabel( 'milliseconds' );
ylabel( 'Sensor reading' );

ylim([0, 1024]);
l.close();


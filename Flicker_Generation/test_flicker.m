
wait_key_up = false;

bkg_col = 0;
disc_col = 10;
flicker_amp = 30;

shape = 0;

disc_r = 30;

frame = 0;
shape_max = 3;

t_freq = 30;

Screen('Preference', 'SkipSyncTests', 1);

KbName( 'UnifyKeyNames' );

try
    
    InitializeMatlabOpenGL(1);
    AssertOpenGL;    
        
    % Find screen with maximal index:
    screenid = max(Screen('Screens'));

    % Open fullscreen onscreen window on that screen. Background color is
    % gray, double buffering is enabled. Return a 'win'dowhandle and a
    % rectangle 'winRect' which defines the size of the window:
    [win, winRect] = Screen('OpenWindow', screenid, 128);
   
    dim = [1200 1920];
           

    
    while true
        Screen( 'FillRect', win, [1 1 1]*bkg_col );

        phase = t_freq/30;
        oval_col = [1 1 1]*(disc_col + flicker_amp*mod(frame*phase,2));

        if shape == 0
            rect = [winRect(3:4)/2-disc_r winRect(3:4)/2+disc_r];
            Screen( 'FillOval', win, oval_col, rect );
        elseif shape == 1
            rect = [winRect(3:4)/2-[disc_r 90] winRect(3:4)/2+[disc_r 90]];
            Screen( 'FillRect', win, oval_col, rect );
        else
            pos = winRect(3:4)/2 - [disc_r 0];
            rect = [pos-[60 60] pos+[60 60]];
            Screen( 'FillRect', win, oval_col, rect );
            pos = winRect(3:4)/2 + [disc_r 0];
            rect = [pos-[60 60] pos+[60 60]];
            Screen( 'FillRect', win, oval_col, rect );
        end
            
               
        Screen('Flip', win, 0 );
        
        frame = frame + 1;
        
        [keyIsDown, ~, keyCode, ~] = KbCheck();
        if( ~keyIsDown )
            wait_key_up = false;
            continue;
        end
        if( wait_key_up ) 
            continue
        end
        
        if( keyIsDown ) 

            if all(keyCode(KbName({'DownArrow'}))) 
                flicker_amp = max( 1, flicker_amp-1 );
                fprintf( 1, 'Flicker amp: %g\n', flicker_amp );
                wait_key_up = true;
            elseif all(keyCode(KbName({'UpArrow'}))) 
                flicker_amp = flicker_amp+1;
                fprintf( 1, 'Flicker amp: %g\n', flicker_amp );            
                wait_key_up = true;
            elseif all(keyCode(KbName({'LeftArrow'}))) 
                disc_r = max( 10, disc_r-10 );
                fprintf( 1, 'Disc radius: %g\n', disc_r );
                wait_key_up = true;
            elseif all(keyCode(KbName({'RightArrow'}))) 
                disc_r = disc_r+10;
                fprintf( 1, 'Disc radius: %g\n', disc_r );            
                wait_key_up = true;
            elseif all(keyCode(KbName({'PageDown'}))) 
                t_freq = max( 2, t_freq/2 );
                fprintf( 1, 'Temporal freq: %g\n', t_freq );
                wait_key_up = true;
            elseif all(keyCode(KbName({'PageUp'}))) 
                t_freq = min( 30, t_freq*2 );
                fprintf( 1, 'Temporal freq: %g\n', t_freq );
                wait_key_up = true;
            elseif all(keyCode(KbName({'ESCAPE'}))) || all(keyCode(KbName({'q'}))) 
                wait_key_up = true;
                break;
            elseif all(keyCode(KbName({'b'}))) 
                bkg_col = 128 - bkg_col;
                wait_key_up = true;
            elseif all(keyCode(KbName({'s'}))) 
                shape = mod( shape+1, shape_max );
                wait_key_up = true;
            end
        end
        

    end
    
    % Done. Close Screen, release all ressouces:
    sca;
catch
    % Our usual error handler: Close screen and then...
    sca;
    % ... rethrow the error.
    psychrethrow(psychlasterror);
end

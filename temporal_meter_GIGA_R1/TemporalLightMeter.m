classdef TemporalLightMeter
    
    methods 
        function sc = TemporalLightMeter()
            if( ispc() ) %是否运行在windows上？
                sc.serial_port = serial('COM4');
                % COM Port. This is likely to differ from computer to
                % computer. Please find the right value from device manager
                % or regedit. DO NOT COMMIT the change!
            elseif( ismac() ) %是否运行在Mac上？
                sc.serial_port = serial( '/dev/tty.usbserial-A5027IVC' );
            else
                sc.serial_port = serial( '/dev/ttyACM0' );
            end
            % set(sc.serial_port,'BaudRate',57600); %57600 是波特率的值，表示每秒传输的位数。
            set(sc.serial_port,'BaudRate',115200);
            % 这个值需要与硬件通信设置相匹配，以确保正常的数据传输。
            %set(sc.serial_port,'BaudRate',74880);  % Not suported on the
                                                    % latest Matab
            set(sc.serial_port,'DataBits',8);
            set(sc.serial_port,'StopBits',1);
            set(sc.serial_port,'Parity', 'none'); %不进行"奇偶校验"
            % set(sc.serial_port,'Terminator', 0 ); %串口对象的终止符属性（Terminator）设置为 0
            set(sc.serial_port,'DataTerminalReady', 'off' );
            set(sc.serial_port,'RequestToSend', 'off' );            
            set(sc.serial_port,'Timeout', 15 ); %15s内没有接收到数据，读取操作将会超时
            fopen(sc.serial_port);
            get(sc.serial_port);    
            
            pause( 1 );
            fprintf( sc.serial_port, 'i' );
            id_string = fgets( sc.serial_port );
            fprintf( 1, 'Arduino identified as: %s\n', id_string ); 
            assert( strncmp( id_string, 'flicker_meter', 13 ) );

        end
        
        function [time, L] = measure( obj, duration, options )                        
            % measure measure "brightness" using the Arduino device
            % [duration = 6]: 0..6: change the time period (for fixed sample
            %             size, this affects temporal resolution.
            %             shorter time periods might be less accurate
            %
            % [edge_tiggered = false]: false/true: wait for a rising edge before recording
            %                  measurements
            %
            % [async = false]: false/true: asynchronous measurement -
            %             return immediately without waiting for the measurement to
            %             finish. [time, L] will be set to NaN
            
            arguments
                obj TemporalLightMeter
                duration (1,1) double = 6 %默认值们
                options.edge_triggerred logical = false
                options.bright_mode logical = false
                options.async logical = false
            end
            
            % 本行负责读取所有数据
            fprintf( obj.serial_port, ['M',  char(options.edge_trigerred + 'A'), char(duration + 'A'), char(options.bright_mode + 'A')]);
            
            if options.async
                time = NaN;
                L = NaN;
            else
                [time, L] = obj.get_last_measurement();
            end
            
        end

        function [time, L] = get_last_measurement( obj )    
            % get measurement data from the last measurement
            fprintf( obj.serial_port, 'G' );
            [time, L] = fetch_data(obj);
        end
        
        function close( lm )
            fclose( lm.serial_port );
        end
    end

    properties( Access = protected)
        serial_port = [];
        
    end

    methods( Access = protected )
        function [time, L] = fetch_data( lm )            
            tline = fgets(lm.serial_port);       
            N = sscanf( tline, '%d;' );
            L = zeros(N,1);
            time = zeros(N,1);
            
            
            for kk=1:N
                tline = fgets(lm.serial_port);                
                if ~ischar(tline)
                    break;
                end
                %display( tline );
                v = sscanf( tline, '%d,%d;' );
                if( length(v) ~= 2 )
                    break;
                end
                time(kk) = v(1);
                L(kk)= v(2);
            end
            if( kk ~= N ) 
                L = L(1:(kk-1));
                time = time(1:(kk-1));
            end
            
            L = L / 1024;
%             if options.bright_mode
%                 L = L + 0.5;
%             end
            time = time / 1000;
            
        end
    end

end
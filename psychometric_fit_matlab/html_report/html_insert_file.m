function html_insert_file( hth, file_name )

fin = fopen( file_name, 'r' );

while( true )
    line = fgetl( fin );
    if( isnumeric( line ) ), break, end;
    fwrite( hth.fh, [line 10], 'uchar' );
%    fprintf( hth.fh, [line '\n'] );
end

end
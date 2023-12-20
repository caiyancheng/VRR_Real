function hth = html_table_end( hth )

if isfield( hth, 'table_row' ) && strcmp( hth.table_row, 'body' )
    fprintf( hth.fh, '</tbody>' );
    hth.table_row = '';
end

fprintf( hth.fh, '</TABLE>\n' );

end
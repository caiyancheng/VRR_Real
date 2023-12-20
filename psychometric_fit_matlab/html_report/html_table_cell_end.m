function html_table_cell_end( hth, tag )
    if exist( 'tag', 'var' ) && strcmp( tag, 'header' )
        fprintf( hth.fh, '</th>\n' );
    else
        fprintf( hth.fh, '</td>\n' );
    end
end
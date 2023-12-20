function html_qtable_beg( ht, varargin )

html_table_beg( ht );

fprintf( ht.fh, '<tr>' );
for kk=1:length( varargin )
    fprintf( ht.fh, '<th>%s</th>', varargin{kk} );
end
fprintf( ht.fh, '</tr>\n' );

end
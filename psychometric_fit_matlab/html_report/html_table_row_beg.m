function hth = html_table_row_beg( hth, varargin )

p = inputParser();
p.addRequired('hth',@isstruct);
p.addParameter('head', false, @islogical);
p.parse( hth, varargin{:} );

header_started = (isfield( hth, 'table_row' ) && strcmp( hth.table_row, 'head' ));

if p.Results.head && ~header_started
    fprintf( hth.fh, '<thead>\n' );
    hth.table_row = 'head';
end

if ~p.Results.head && header_started
    fprintf( hth.fh, '</thead>\n' );
    fprintf( hth.fh, '<tbody>\n' );
    hth.table_row = 'body';
end

fprintf( hth.fh, '<tr>' );

end
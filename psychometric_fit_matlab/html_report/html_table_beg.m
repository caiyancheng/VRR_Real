function hth = html_table_beg( hth, varargin )

p = inputParser();
p.addRequired('hth',@isstruct);
p.addParameter('id',[], @ischar);
p.addParameter('class', [], @ischar);
p.addParameter('style',[], @ischar);

p.parse( hth, varargin{:} );

fprintf( hth.fh, '<TABLE' );
if ~isempty( p.Results.id )
    fprintf( hth.fh, ' id="%s"', p.Results.id );
end
if ~isempty( p.Results.class )
    fprintf( hth.fh, ' class="%s"', p.Results.class );
end
if ~isempty( p.Results.style )
    fprintf( hth.fh, ' style="%s"', p.Results.style );
end
fprintf( hth.fh, '>\n' );

end
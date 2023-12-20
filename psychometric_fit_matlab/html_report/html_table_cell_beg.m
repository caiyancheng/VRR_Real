function html_table_cell_beg( hth, varargin )

element = 'td';
tag = '';
for kk=1:length(varargin)
    if strcmp( varargin{kk}, 'header' )
        element = 'th';
    else
        tag = cat( 2, tag, ' ', varargin{kk});
    end
end
fprintf( hth.fh, '<%s%s>', element, tag );

end
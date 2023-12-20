function hth = html_table_row_end( hth )

% p = inputParser();
% p.addRequired('hth',@isstruct);
% p.addParameter('head', false, @islogical);
% p.parse( hth, varargin{:} );

fprintf( hth.fh, '</tr>\n' );

% if ~p.Results.head && isfield( hth, 'table_row' ) && strcmp( hth.table_row, 'head' )
%     fprintf( hth.fh, '</thead>\n' );
%     hth.table_row = 'head_closed';
% end

end
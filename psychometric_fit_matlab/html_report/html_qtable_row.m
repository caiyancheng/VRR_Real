function html_qtable_row( ht, varargin )

fprintf( ht.fh, '<tr>' );
tags = '';
for kk=1:length( varargin )
    if( isnumeric( varargin{kk} ) )
        for ii=1:length(varargin{kk})
            if( ~isempty( tags ) )
                fprintf( ht.fh, '<td %s>%g</td>', tags, varargin{kk}(ii) );
            else
                fprintf( ht.fh, '<td>%g</td>', varargin{kk}(ii) );
            end
        end
        tags = '';       
    else
        if( varargin{kk}(1) == '/' )
            tags = varargin{kk}(2:end);
            continue;
        end
        
        if( ~isempty( tags ) )
            fprintf( ht.fh, '<td %s>%s</td>', tags, varargin{kk} );
            tags = '';
        else
            fprintf( ht.fh, '<td>%s</td>', varargin{kk} );
        end
    end
end
fprintf( ht.fh, '</tr>\n' );


end
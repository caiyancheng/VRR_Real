function html_insert_figure( hth, fig_h, name, density, width, height)

file_tmp = [tempname() '.eps'];

% if( ~exist( 'fig_size', 'var' ) )
%     fig_size = [12 8];
% end

if( ~exist( 'density', 'var' ) || isempty( density ) )
    density = 100;
    resolution = '-r0';
else
    resolution = sprintf( '-r%d', density );
end


% if( ~exist( 'font_size', 'var' ) )
%     font_size = 1;
% end

%exportfig(fig_h, tmp_file, 'Color', 'rgb', 'Width', fig_size(2), 'Height', fig_size(1), ...
%    'FontMode', 'scaled', 'FontSize', font_size );

if( exist( 'width', 'var' ) && exist( 'height', 'var' ) )
    html_change_figure_print_size( gcf, width, height );
end

%fix_text_overlap( gcf );

if( ~exist( 'name', 'var' ) || isempty( name ) )
    [~, name] = fileparts(tempname());
end
dest_name = sprintf( '%s.png', name );

dest_path = fullfile( hth.path, dest_name );

if( false ) %strcmp( get( gcf, 'Renderer' ), 'painters' ) )
    % good quality EPS

    exportfig(fig_h, file_tmp, 'Color', 'rgb', 'Resolution', 200 );

%system( sprintf( 'gs -r50 -dEPSCrop -dTextAlphaBits=4 -sDEVICE=png16m -sOutputFile=%s -dBATCH -dNOPAUSE %s', ...
%    dest_path, tmp_file ) );

    system( sprintf( '%sconvert -density %d ''%s'' ''%s''%s', pfs_shell(), density, pfs_fix_path(file_tmp), pfs_fix_path(dest_path), pfs_shell(1) ) );
    
    delete( file_tmp );
    
else
    print( dest_path, '-dpng', resolution );
end


fprintf( hth.fh, '<img src="%s"/>\n', dest_name );


end

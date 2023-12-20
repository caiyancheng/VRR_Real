function html_save_figure_as_image( fig_h, dest_name, density )


if( ~exist( 'density', 'var' ) )
    density = 100;
end

if( strcmp( get( gcf, 'Renderer' ), 'painters' ) )
    % good quality EPS

    file_tmp = [tempname() '.eps'];
    exportfig(fig_h, file_tmp, 'Color', 'rgb', 'Resolution', 200 );

%system( sprintf( 'gs -r50 -dEPSCrop -dTextAlphaBits=4 -sDEVICE=png16m -sOutputFile=%s -dBATCH -dNOPAUSE %s', ...
%    dest_path, tmp_file ) );

    system( sprintf( '%sconvert -density %d "%s" "%s"%s', pfs_shell(), density, file_tmp, dest_name, pfs_shell(1) ) );
    
    delete( file_tmp );
    
else
    print( dest_name, '-dpng' );
end

end

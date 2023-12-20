function html_close( hth )

fprintf( hth.fh, '</body>\n' );
fprintf( hth.fh, '</html>\n' );

fclose( hth.fh );

fprintf(1, 'The report is  generated and available <a href="%s">here</a>\n (%s)\n.', hth.html_file, hth.html_file);

end
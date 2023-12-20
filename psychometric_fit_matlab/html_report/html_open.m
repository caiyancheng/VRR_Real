function hth = html_open( file_name, title, header_file, stylesheet_file )
% Open an HTML report.
%
% hth = html_open( file_name, title )
% hth = html_open( file_name, title, header_file )
% hth = html_open( file_name, title, header_file, stylesheet_file )
%
% file_name - path to the HTML file. A directory will be creates as needed.
% title - title of the HTML web page
% header_file - the name of the file to be inserted in the header part of
%         the HTML
% stylesheet_file - the name of the stylesheet file tp use. The stylesheet file
%         will be coppied into the directory with the report.
%

% Get path to HTML report toolbox
[m_path] = fileparts(mfilename( 'fullpath' ));

%[pathstr, name, ext, versn] = fileparts(file_name);
[pathstr] = fileparts(file_name);

if( ~exist( fullfile('.', pathstr), 'dir' ) )
    mkdir( pathstr );
end

fh = fopen( file_name, 'w' );

hth.fh = fh;
hth.path = pathstr;
hth.html_file = file_name;

fprintf( fh, '<html>\n' );
fprintf( fh, '<head>\n' );
fprintf( fh, '<title>%s</title>\n', title );

html_insert_file( hth, fullfile( m_path, 'html_preamble.html' ) );

if( exist( 'stylesheet_file', 'var' ) && ~isempty(stylesheet_file) )
    copyfile( stylesheet_file, pathstr );
    [~,stylesheet_name, stylesheet_ext] = fileparts( stylesheet_file );
    fprintf( fh, '<link rel="stylesheet" type="text/css" href="%s%s">', stylesheet_name, stylesheet_ext );
end

if( exist( 'header_file', 'var' ) && ~isempty( header_file ) )
    html_insert_file( hth, header_file );
end
fprintf( fh, '</head>\n\n<body>\n' );


end
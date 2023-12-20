function html_insert_image( hth, image, options )
% Instert image into an html page
%
% html_insert_image( hth, image, options )
%
% hth - html handle returned by HTML_OPEN
% image - either (HxWx3) matrix or a path to an image. If it is a path
%         the image file will be copied to the target directory.
% options - a cell array of { 'tag', value } pairs. Supported options:
%
%   dest_file_name - file name for the image (without path)
%   title - title to show under the image
%   div_style - extra style for the DIV element (image and title)
%   style - extra style options for the IMG element
%   mousedown_image - image to show on mousepress
%   mousedown_title - title to show when mouse is presses over the image
%   overlay_images - a cell array containing images that will be shown as
%              overlays. This can be file names or matrices. Overlay images
%              are shown as small icons on the bottom-left. When clicked,
%              they are expanded to the full size.

if( exist( 'options', 'var' ) ) 
    % parse options
    for k=1:2:length(options)
        opt.(options{k}) = options{k+1};
    end
else
    opt = struct();
end

% For backward compatibility
if( isfield( opt, 'mouseover_image' ) )
    opt.mousedown_image = opt.mouseover_image;
end
if( isfield( opt, 'mouseover_title' ) )
    opt.mousedown_title = opt.mouseover_title;
end




if( ischar( image ) )
    
    [~, name, ext] = fileparts(image);
    
    if( isfield( opt, 'dest_file_name' ) )
        dest_name = opt.dest_file_name;
    else
        dest_name = [name ext];
    end
    
    [~, ~, dest_ext] = fileparts(image);
    
    if( ~strcmp( ext, dest_ext ) ) %necessary format conversion
        system( sprintf( 'convert %s %s', image, fullfile( hth.path, dest_name ) ) );
    else
        copyfile( image, fullfile( hth.path, dest_name ) );
    end
    
else
    
    if( isfield( opt, 'dest_file_name' ) )
        dest_name = opt.dest_file_name;
        [~, ~, ext] = fileparts(dest_name);
    else
        [~, dest_name, ~] = fileparts( tempname() );
        dest_name = [dest_name '.jpg'];
        ext = '.jpg';
    end
    
    imwrite_8bithq( image, fullfile( hth.path, dest_name ) );
    
end

% generate name ID for extra images
[~, img_id, ~] = fileparts( dest_name );

if( isfield( opt, 'div_style' ) )
    extra_style = opt.div_style;
else
    extra_style = '';
end

fprintf( hth.fh, '<div style="display: inline-block; %s">', extra_style );

if( isfield( opt, 'mousedown_image' ) )
    
    mo_dest_name = [ img_id '_mo' ext ];
    
    % avoid some characters
    img_id = strrep( img_id, '-', '_' );
    img_id = strrep( img_id, ' ', '_' );

    title_id = ['title_' img_id];

    
    if( ischar( opt.mousedown_image ) )
        if( exist( fullfile( hth.path, opt.mousedown_image ), 'file' ) ) % if the file is already there
            mo_dest_name = opt.mousedown_image;
        else
            copy_image_file( hth, opt.mousedown_image, mo_dest_name, ext );
        end
    else
        imwrite_8bithq( opt.mousedown_image, fullfile( hth.path, mo_dest_name ) );
    end

    if( isfield( opt, 'mousedown_title' ) )
        if( ~isfield( opt, 'title' ) )
            error( 'You must specify both "title" and "mousedown_title"' );
        end
        mover_extra = sprintf( ' document.getElementById("%s").innerHTML="%s";', title_id, opt.mousedown_title );
        mout_extra = sprintf( ' document.getElementById("%s").innerHTML="%s";', title_id, opt.title );
    else
        mover_extra = '';
        mout_extra = '';
    end
    extra = sprintf( 'name="%s" unselectable="on" onDragStart=''return false;'' onMouseDown=''if(detectLeftButton(event)){document.%s.src="%s";%sreturn true;}'' onMouseUp=''document.%s.src="%s";%sreturn true;'' ', ...
        img_id, img_id, mo_dest_name, mover_extra, img_id, dest_name, mout_extra );

    
else
    extra = '';
end


img_style = '';

if( isfield( opt, 'style' ) )
    img_style = cat( 2, img_style, opt.style );
end
extra = cat( 2, extra, 'style="', img_style, '" ' );

if( isfield( opt, 'overlay_images' ) )
    fprintf( hth.fh, '<div style="padding: 0px; position: relative; left: 0px; top: 0px;">' );
    
    ob_id = [ img_id '_ob' ]; %overlay box ID

%    extra = cat( 2, extra, 'onMouseOver=''document.getElementById("', ob_id, '").style.visibility="visible"''' );
%    extra = cat( 2, extra, 'onMouseOut=''document.getElementById("', ob_id, '").style.visibility="hidden"''' );
end

if( ~ischar( image ) )
    fprintf( hth.fh, '<img %s src="%s" width="%d" height="%d"/>', extra, dest_name, size(image,2), size(image,1) );
else
    fprintf( hth.fh, '<img %s src="%s"/>', extra, dest_name );
end

if( isfield( opt, 'overlay_images' ) )
    
    fprintf( hth.fh, '<div id="%s" style="position: absolute; bottom: 0px; left: 0px">', ob_id );
    for kk=1:length( opt.overlay_images )
        
        o_img_p = opt.overlay_images{kk,1}; % overlay image, path or matrix
        
        o_img = get_image( o_img_p );
        o_img_thumb = imresize( o_img, [64 64] ); % create a thumbnail

        oi_id = sprintf( '%s_oit_%d', img_id, kk );
        oit_dest_name = sprintf( '%s_oit_%d%s', img_id, kk, ext );
        oit_dest_name = create_image_file( hth, oit_dest_name, o_img_thumb );
        
        js_code = [ 'onMouseDown=''document.getElementById("', oi_id, '").style.visibility="visible"''' ];
        fprintf( hth.fh, '<img style="padding: 10px;" src="%s" %s/>', oit_dest_name, js_code );
    
    end
    fprintf( hth.fh, '</div>' );
    
    for kk=1:length( opt.overlay_images )
        
        o_img_p = opt.overlay_images{kk,1}; % overlay image, path or matrix
        
        oi_id = sprintf( '%s_oit_%d', img_id, kk );
        oi_dest_name = sprintf( '%s_oi_%d%s', img_id, kk, ext );
        oi_dest_name = create_image_file( hth, oi_dest_name, o_img_p );
        
        js_code = [ 'onMouseDown=''document.getElementById("', oi_id, '").style.visibility="hidden"''' ];
        fprintf( hth.fh, '<img id="%s" style="visibility: hidden; position: absolute; bottom: 0px; left: 0px" src="%s" %s/>', oi_id, oi_dest_name, js_code );
    
    end


    fprintf( hth.fh, '</div>' );

end

if( isfield( opt, 'title' ) )
    if( exist( 'title_id', 'var' ) )
        fprintf( hth.fh, '<br/><span id="%s">%s</span>\n', title_id, opt.title );
    else
        fprintf( hth.fh, '<br/><span>%s</span>\n', opt.title );
    end
end

fprintf( hth.fh, '</div>\n' );

end

function imwrite_8bithq( img, filename )

[pathstr, name, ext ] = fileparts(filename);

if( strcmpi( ext, '.png' ) )
    imwrite( img, filename, 'bitdepth', 8 );
elseif( strcmpi( ext, '.jpg' ) )
    imwrite( img, filename, 'Quality', 95 );
    
    % work-around for the Matlab bug
    %pfs_write_image( filename, img );
else
    imwrite( img, filename );
end

end

function copy_image_file( hth, from_file, dest_name, ext )

[~, ~, src_ext] = fileparts(from_file);
    
if( ~isempty( ext ) && ~strcmp( ext, src_ext ) ) %necessary format conversion
    system( sprintf( 'convert %s %s', from_file, fullfile( hth.path, dest_name ) ) );
else
    copyfile( from_file, fullfile( hth.path, dest_name ) );
end

end

function dest_name = create_image_file( hth, dest_name, image )

if( ischar( image ) )
    
    % Check if the image is in the right folder
    pp = strfind( image, hth.path );
    if( ~isempty( pp ) && pp == 1 )
        % no need to do anything, image in the right place
        dest_name = image( (length(hth.path)+2):end );
    else
        copy_image_file( hth, image, dest_name, [] )
    end
else
    imwrite_8bithq( image, fullfile( hth.path, dest_name ) );    
end

end

function I = get_image( image )

if( ischar( image ) )
    I = imread2double( image );
else
    I = image;
end

end

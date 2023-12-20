% An example how to generate an HTML report

% First, open the report and specify HTML file name. The directory will be
% created as needed.
ht = html_open( 'report/index.html', 'This is an example report', [], 'style.css' );

% You can directly write into the HTML file
fprintf( ht.fh, '<h1>This is an example report</h1>\n' );

% Plots can be easily added to the report
x = linspace( 0, 2*pi, 200 );
clf
plot( x, sin(x) );

% It is a good idea to specify the name of the plot so that the same file
% is create when the report is generated. Specify also with and height so
% that the plots look the same every time the report is generated.
html_insert_figure( ht, gcf, 'my_plot', [], 15, 10 );

fprintf( ht.fh, '<br/><hr/><br/>\n' );

img_rnd = rand( [200 200 3] );
img_sin = ones(200,1) * (sin(16*x)+1)/2;

% Check the documentation of html_insert_image for the full list of fancy
% optioons. 
html_insert_image( ht, img_rnd, { 'dest_file_name', 'rnd_img.png', ...
    'title', 'This is just some random noise (click on me)', ...
    'mousedown_image', img_sin, ...
    'mousedown_title', 'Sine grating', ...
    } )

fprintf( ht.fh, '<br/><hr/><br/>\n' );


% This is how to create an HTML table 
html_table_beg( ht, 'border_table' ); % You can specify the class of your table (must be present in the stylesheet file).
for rr=1:10 % For each row
    html_table_row_beg(ht);
    
    for cc=1:10 % For each column
        html_table_cell_beg(ht);
        
        fprintf( ht.fh, 'A<sub>%d,%d</sub>', rr, cc );
        
        html_table_cell_end(ht);
    end
    
    html_table_row_end(ht);
end
html_table_end( ht );

fprintf( ht.fh, '<br/><hr/><br/>\n' );

% This is even a quicker way to insert a table 
html_qtable_beg( ht, 'First', 'Second', 'Third' );
html_qtable_row( ht, '1', '2', '3' );
html_qtable_row( ht, 'A', 'B', 'C' );
html_qtable_end( ht );

html_close( ht );




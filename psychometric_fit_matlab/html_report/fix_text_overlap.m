function fix_text_overlap( h )

if( ~exist( 'h', 'var' ) )
    h = gcf;
end

oldUnits = get(h,'Units');
set( h, 'Units', 'characters' );

axs = findall( h, 'Type', 'axes' );

for aa = 1:length(axs)
    
    th = findall( axs(aa), 'Type', 'text' );
    N = length(th);
    
    for it = 1:200
        E = zeros(N,4);
        for k=1:N
            E(k,:) = get( th(k), 'Extent' );
        end
        % Vertical extend is repoted too large 
        E(:,2) = E(:,2) + 0.1*E(:,4);
        E(:,4) = 0.8*E(:,4);
        
        E(:,3:4) = E(:,3:4)+E(:,1:2);
        
        
        Ov = false(N,N);
        
        delta = 0.05;
        for k=1:N
            for l=k+1:N
                Ov(k,l) = bb_check( E(k,:), E(l,:) );
                
                if( Ov(k,l) )
                    Pk = get( th(k), 'Position' );
                    Pl = get( th(l), 'Position' );
                    
                    D = (Pk-Pl);
                    if( sum( D.^2 ) == 0 ) % if exactly the same position
                        % move in random dir by up to 5% of the original position
                       D(1:2) = 0.1*(rand(1,2)-0.5).*Pk(1:2);                        
                    end
%                    D = D/sqrt( sum(D.^2) );
                    
                    set( th(k), 'Position', Pk + D*delta );
                    set( th(l), 'Position', Pl - D*delta );
                end
            end
        end
        
        if( nnz(Ov) == 0 )
            break;
        end
        
    end
    
end

set( h, 'Units', oldUnits );

end

function overlap = bb_check( B1, B2 )

overlap = B1(1) <= B2(3) && B1(3) >= B2(1) && B1(2) <= B2(4) && B1(4) >= B2(2);

%overlap = is_inside( B1([1 2]), B2 ) || is_inside( B1([3 2]), B2 ) || ...
%    is_inside( B1([3 4]), B2 ) || is_inside( B1([1 4]), B2 );
end

function inside = is_inside( p, B )
if( p(1) >= B(1) && p(1) <= B(3) && p(2) >= B(2) && p(2) <= B(4) )
    inside = true;
else
    inside = false;
end
end
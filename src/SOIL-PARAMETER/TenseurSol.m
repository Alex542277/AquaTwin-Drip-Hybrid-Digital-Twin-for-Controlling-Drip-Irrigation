function K = TenseurSol(typeSol,k_s)

% Retourne le tenseur de conductivite hydraulique (m/s)
% selon le type de sol
r=1;

typeSol = lower(typeSol);

switch typeSol

    case 'sableux'

        % Infiltration tr?s rapide
        Kr = r*k_s;
        Kz = k_s;

    case 'limoneux'

        % Souvent favorable au ma?s
        Kr = r*k_s;
        Kz = k_s;

    case 'franco-limoneux'

        % Sol agricole ?quilibr?

        Kr = r*k_s;
        Kz = k_s;

    case 'argileux'
        

        Kr = r*k_s;
        Kz = k_s;   % quasi-isotrope

    case 'franco-argileux'
    

        Kr = r*k_s;
        Kz = k_s;   % anisotropie mod?r?e
        
    case 'limono-argileux'

        Kr = r*k_s;
        Kz = k_s;  
        

    otherwise

        warning('Type de sol inconnu -> limoneux par defaut')
        
        Kr = r*k_s;
        Kz = k_s;

end

% Construction du tenseur anisotrope
K = [Kr 0;
     0 Kz];

end
function [psi_w, psi_h, psi_c] = SeuilsHydriques(culture, typesol)
    
    % Saturation (independant de la culture)
    psi_w = -1;  % hPa
    
    % Valeurs de base selon la culture (en hPa)
    switch lower(culture)
        case {'mais', 'corn', 'maize'}
            psi_h = -600;
            psi_c = -1200;
        case {'ble', 'wheat', 'ble'}
            psi_h = -800;
            psi_c = -1500;
        case {'tomate', 'tomato'}
            psi_h = -350;
            psi_c = -800;
        case {'vigne', 'grape', 'vine'}
            psi_h = -1000;
            psi_c = -1500;
        case {'soja', 'soybean'}
            psi_h = -500;
            psi_c = -1000;
        case {'riz', 'rice'}
            psi_h = -250;
            psi_c = -600;
        case {'coton', 'cotton'}
            psi_h = -800;
            psi_c = -1600;
        otherwise
        
            % Valeurs par defaut
            warning('Culture non reconnue, utilisation valeurs defaut');
            psi_h = -600;
            psi_c = -1200;
    end
    
    % Ajustement selon le type de sol (facteurs multiplicatifs)
    switch lower(typesol)
        case 'sableux'
            facteur = 0.7;    % Stress tres precoce
        case 'sablo-limoneux'
            facteur = 0.85;   % Stress precoce
        case 'limoneux'
            facteur = 1.0;    % Reference
        case 'limono-argileux'
            facteur = 1.15;   % Stress tardif
        case 'argileux'
            facteur = 1.3;    % Stress tres tardif
        otherwise
            warning('Type de sol non reconnu, utilisation limoneux');
            facteur = 1.0;
    end
    
    % Application du facteur sol
    psi_h = psi_h * facteur;
    psi_c = psi_c * facteur;
    

end
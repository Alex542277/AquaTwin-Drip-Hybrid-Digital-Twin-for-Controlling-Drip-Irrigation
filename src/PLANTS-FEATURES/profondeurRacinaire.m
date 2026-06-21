function Zr = profondeurRacinaire(culture,t)

% Dynamic calculation of root depth (m)
% t in hours

switch lower(culture)

    case 'mais'

        Zr0 = 0.10;      % initial depth (m)
        Zrmax = 1.20;    % Maximum depth (m)
        Tcroissance = 120;

    case 'coton'

        Zr0 = 0.15;
        Zrmax = 1.50;
        Tcroissance = 160;

    case 'tomate'

        Zr0 = 0.08;
        Zrmax = 0.60;
        Tcroissance = 100;

    otherwise
        error('Unrecognized culture');

end


% Linear root growth
Zr = Zr0 + (Zrmax - Zr0)*(t/Tcroissance);

% Maximum depth limit
Zr = min(Zr,Zrmax);

end
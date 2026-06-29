function Zr = profondeurRacinaire(culture,t)

% Calcul dynamique de la profondeur racinaire (m)

switch lower(culture)

    case 'mais'

        Zr0 = 0.10;      % profondeur initiale (m)
        Zrmax = 1.20;    % profondeur max (m)
        Tcroissance = Croissance('mais');
    case 'coton'

        Zr0 = 0.15;
        Zrmax = 1.50;
        Tcroissance = Croissance('coton');

    case 'tomate'

        Zr0 = 0.08;
        Zrmax = 0.60;
        Tcroissance = Croissance('tomate');

    otherwise
        error('Culture non reconnue');

end


% Croissance lineaire des racines
Zr = Zr0 + (Zrmax - Zr0)*(t/Tcroissance);

% Limitation a la profondeur maximale
Zr = min(Zr,Zrmax);

end
function Tcroissance = Croissance(culture)

% Calcul dynamique de la profondeur racinaire (m)

switch lower(culture)

    case 'mais'

        Tcroissance = 120;

    case 'coton'

        Tcroissance = 160;

    case 'tomate'

        Tcroissance = 100;

    otherwise
        error('Culture non reconnue');

end



end
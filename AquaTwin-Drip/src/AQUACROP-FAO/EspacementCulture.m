function [d_r,dl] = EspacementCulture(culture)

% ESPACEMENT ENTRE RANGS ET PLANTS (m)
% d_r = distance entre rangs
% dl  = distance entre plants sur la ligne

culture = lower(culture);

switch culture

    % MAIS

    case {'mais','ma?s'}

        d_r = 0.80;     % 80 cm entre rangs
        dl  = 0.25;     % 25 cm entre pieds

    % TOMATE

    case 'tomate'

        d_r = 1.20;     % 1.2 m entre rangs
        dl  = 0.45;     % 45 cm entre plants

    % COTON


    case 'coton'

        d_r = 0.90;     % 90 cm entre rangs
        dl  = 0.30;     % 30 cm entre plants

    otherwise

        warning('Culture inconnue');
        d_r = 1;
        dl  = 0.5;

end

end
function KcTr=PlanteFeatures(JJ,culture)

% Caracteristiques des plantes selon FAO56/AquaCrop
% ETo     : evapotranspiration de reference (mm/j)
% JJ      : jour apres semis
% culture :'tomate','coton','mais'
% Tpot  : transpiration potentielle (mm/j)
% KcTr  : coefficient cultural
% stade : stade cultural
% Parametre selon culture

switch lower(culture)

    % Tomate
    
    case 'tomate'
        Lini = 25;
        Ldev = 40;
        Lmid = 35;
        Lend = 25;

        Kc_ini = 0.60;
        Kc_mid = 1.15;
        Kc_end = 0.80;


    % Coton
    
    case 'coton'
        Lini = 30;
        Ldev = 50;
        Lmid = 60;
        Lend = 40;

        Kc_ini = 0.35;
        Kc_mid = 1.15;
        Kc_end = 0.60;



    % Mais
    
    case 'mais'

        % Durees typiques FAO
        Lini = 20;     % Germination
        Ldev = 30;     % Croissance vegetative
        Lmid = 40;     % Floraison
        Lend = 30;     % Maturation

        % Coefficients culturaux FAO
        Kc_ini = 0.40;
        Kc_mid = 1.20;
        Kc_end = 0.60;

    otherwise

        error('Culture inconnue');

end

% Determination stade cultural

if JJ/24 <= Lini

    % Initial
    stade='Initial';
    KcTr=Kc_ini;

elseif JJ/24 <= (Lini+Ldev)

    % Stade de developpement
    stade='Developpement';
    KcTr = Kc_ini +(Kc_mid-Kc_ini)*(JJ-Lini)/Ldev;

elseif JJ/24 <= (Lini+Ldev+Lmid)

    % Intermediaire
    % Besoin maximal d'irrigation

    stade='Intermediaire';
    KcTr=Kc_mid;

elseif JJ/24 <= (Lini+Ldev+Lmid+Lend)

    % Final
    stade='Final';
    KcTr = Kc_mid-(Kc_mid-Kc_end)*(JJ-Lini-Ldev-Lmid)/Lend;

else

    % Fin culture
    stade='Mature';
    KcTr=Kc_end;

end


end

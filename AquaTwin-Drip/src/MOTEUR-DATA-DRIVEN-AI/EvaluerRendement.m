function appreciation=EvaluerRendement(culture, rendement)

% EvaluerRendement : Evaluons la qualite d'un rendement agricole.
culture = lower(strtrim(culture));

switch culture

    case {'mais','ma?s'}

        if rendement < 4000
            appreciation = 'Faible';
        elseif rendement < 8000
            appreciation = 'Bon';
        else
            appreciation = 'Exceptionnel';
        end

    case 'riz'

        if rendement < 3000
            appreciation = 'Faible';
        elseif rendement < 7000
            appreciation = 'Bon';
        else
            appreciation = 'Exceptionnel';
        end

    case 'coton'

        if rendement < 1000
            appreciation = 'Faible';
        elseif rendement < 2000
            appreciation = 'Bon';
        else
            appreciation = 'Exceptionnel';
        end

    case 'tomate'

        if rendement < 20000
            appreciation = 'Faible';
        elseif rendement < 50000
            appreciation = 'Bon';
        else
            appreciation = 'Exceptionnel';
        end

    otherwise
        error('Culture non prise en charge.');
end

end
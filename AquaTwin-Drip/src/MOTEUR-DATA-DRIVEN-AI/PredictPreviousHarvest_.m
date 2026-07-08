function [Rendement, Biomasse] = PredictPreviousHarvest_(culture, ETo)
    
    % Si ETo est une py.list, la convertir en tableau MATLAB
    if isa(ETo, 'py.list')
        try
            % Methode 1 : via py.array.array
            ETo = double(py.array.array('d', ETo));
        catch
            try
                % Methode 2 : via cell array
                ETo = cell2mat(cell(ETo));
                ETo = double(ETo);
            catch
                try
                    % Methode 3 : via py.list() et boucle
                    n = py.len(ETo);
                    ETo_temp = zeros(1, n);
                    for i = 1:n
                        ETo_temp(i) = double(py.getitem(ETo, py.int(i-1)));
                    end
                    ETo = ETo_temp';
                catch
                    error('Impossible de convertir ETo en tableau MATLAB');
                end
            end
        end
    elseif isa(ETo, 'py.numpy.ndarray')
        
        % Si c'est un numpy array
        ETo = double(ETo);
        
    elseif isa(ETo, 'py.tuple')
        
        % Si c'est un tuple
        ETo = double(py.array.array('d', py.list(ETo)));
        
    end
    
    % Verifions que ETo est un tableau MATLAB
    if ~isnumeric(ETo)
        error('ETo doit ?tre un tableau num?rique. Type re?u: %s', class(ETo));
    end
    
    % S'assurer que ETo est un vecteur colonne
    if size(ETo, 1) == 1
        ETo = ETo';
    end

    % CALCUL DU RENDEMENT ET DE LA BIOMASSE

    % T: nombre de jours de periode de croissance
    T = Croissance(culture);
    Tr = 0;
    [WP, Hi] = parameterAquaCrop(culture);
    Rendement = zeros(T, 1);
    Biomasse = zeros(T, 1);
    
    % Verifions que ETo a assez de donnees
    if length(ETo) < T
        warning('ETo a %d jours, mais %d jours sont n?cessaires. Compl?tion avec des z?ros.', length(ETo), T);
        ETo = [ETo; zeros(T - length(ETo), 1)];
    end
    
    for i = 1:T
        v = ETo(i);
        Tpot = TranspirationPotentielle(v, i, culture);
        Tr = Tr + Tpot / v;
        B = WP * Tr;
        Rendement(i) = B * Hi;
        Biomasse(i) = B;
    end
    
end
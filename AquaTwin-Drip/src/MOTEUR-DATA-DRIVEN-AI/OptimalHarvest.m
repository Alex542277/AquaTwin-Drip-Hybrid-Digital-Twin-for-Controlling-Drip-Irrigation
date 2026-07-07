function [OptimalHarvest, Optimalwater] = OptimalHarvest(culture, DateSemis, PredictEvapo)

    % Un algorithme pour trouver un rendement exceptionnel et optimal
    pas_choix = 1e-3;
    
    DateSemis = datetime(DateSemis, 'InputFormat', 'yyyy-MM-dd');
    DateAujourdhui = datetime('today');
    AgePlante = days(DateAujourdhui - DateSemis);
    
    % Conversion initiale
    PredictEvapo = convertPy(PredictEvapo);
    variance = var(PredictEvapo);
    vectChoice = min(PredictEvapo):pas_choix:max(PredictEvapo);
    
    [Rendement_, Biomasse] = PredictPreviousHarvest(culture, PredictEvapo);
    Rendement_ = convertPy(Rendement_);
    
    Rendement_ = Rendement_(:)';
    PredictEvapo = PredictEvapo(:)';
    
    py.importlib.import_module('PredictionRendementTest');
    
    while 0<1
        
        k = vectChoice(randi(numel(vectChoice)));
        
        choice1 = mean(PredictEvapo) + k * variance;
        choice2 = max(0,mean(PredictEvapo) - k * variance);
        
        ETo = [choice1 choice2];
        
        % Conversion MATLAB -> Python
        pyEToTrain = py.list(num2cell(PredictEvapo));
        pyYield    = py.list(num2cell(Rendement_));
        pyPredict  = py.list(num2cell(ETo));
        
        % Prediction Python
        Yield_py = py.PredictionRendementTest.PredictionRendementTest( ...
            pyEToTrain, pyYield, pyPredict);
        
        % Conversion Python -> MATLAB
       

    % Nouvelle ligne 
        if isa(Yield_py, 'py.numpy.ndarray')
            Yield = double(py.array.array('d', py.list(Yield_py.flatten())));
        else
            Yield = convertPy(Yield_py);
        end
        
        [~,idx] = max(Yield);

        if idx == 1
            BestETo = choice1;
        else
            BestETo = choice2;
        end
        
        % Mise a jour
        if AgePlante + 1 <= length(PredictEvapo)
            PredictEvapo(AgePlante + 1) = BestETo;
        else
            PredictEvapo = [PredictEvapo, BestETo];
        end
        
        % Nouveau rendement
        [Rendement, Biomasse] = PredictPreviousHarvest(culture, PredictEvapo);
        Rendement = convertPy(Rendement);
        
        appreciation = EvaluerRendement(culture, Rendement);
        OptimalHarvest = sum(Rendement(:));
        Optimalwater = BestETo;
        
        if strcmpi(appreciation, 'Excellent')
            fprintf('Excellent')
            break;
        end
        
        
    end
    
end
function [Biomasse,Rendement] = rendementPredictionGood(lat,lon,culture)

    %% Date de semis
    DateSemence = input('Entrez la date de votre semence (ex : 2026-04-03) : ','s');

    %% Duree de croissance
    T = Croissance(culture);

    %% Evapotranspiration (Python)
    py.importlib.import_module('EvapotranspirationCulture');
    ETo_py = py.EvapotranspirationCulture.EvapotranspirationCulture(lat,lon,DateSemence,T);
    
    %% Rendement AquaCrop
    [Rendement_,Biomasse_] = PredictPreviousHarvest_(culture,ETo_py);

    A = input('Entrez le vecteur des jours concernes par la prediction (ex : [6 9 12]) : ');
    A = A(:)';

    for k=1:length(A)

        if A(k)<=length(Rendement_)
            Rendement_(A(k)) = 0;
        end

    end


    %% Valeurs ETo ? tester

    ET_A_Mod = zeros(1,length(A));
    for k=1:length(A)

        ET_A_Mod(k)=input(sprintf('Entrez la valeur de ETo(valeur a tester) au jour %d : ',A(k)));

    end


    Rendement_ = Rendement_(:)';
    ET_A_Mod   = ET_A_Mod(:)';
    pyYield = py.list(num2cell(Rendement_));
    pyET    = py.list(num2cell(ET_A_Mod));


    py.importlib.import_module('PredictionRendement');

    Yield_py = py.PredictionRendementTest.PredictionRendementTest(ETo_py,pyYield,pyET);


    if isa(Yield_py,'py.numpy.ndarray')

        Yield = double(py.array.array('d',py.numpy.nditer(Yield_py)));

    elseif isa(Yield_py,'py.list')

        n = int64(py.len(Yield_py));

        Yield = zeros(1,n);

        for i=1:n
            Yield(i)=double(Yield_py{i-1});
        end

    else

        error('Type Python non reconnu.');

    end

        
[WP,Hi]=parameterAquaCrop(culture);
Rendement = sum(Rendement_) + sum(Yield);
Biomasse = Rendement/Hi;
disp(EvaluerRendement(culture,Rendement));

end
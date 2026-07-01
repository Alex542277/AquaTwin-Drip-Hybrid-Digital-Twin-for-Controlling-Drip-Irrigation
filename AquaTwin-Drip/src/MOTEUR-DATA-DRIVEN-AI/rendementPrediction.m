function [Biomasse,Rendement]=rendementPrediction(lat,lon,culture)

    % T: nombre de jours de periode de croissance
    DateSemence=input('Entrez la date de votre semence : ');
    T=Croissance(culture);
    py.importlib.import_module('EvapotranspirationPredBon')
    ETo_py=py.EvapotranspirationPredBon.EvapotranspirationCulture(lat,lon,DateSemence,T);
    ETo = double(py.array.array('d', py.numpy.nditer(ETo_py)));
    [Rendement_,Biomasse_]=PredictPreviousHarvest(culture,ETo);
    A = input('Entrez le vecteur v contenant les jours(jours apr?s la semence) concernes par le test de prediction : ');
    
    for k=1:length(A)
        Rendement_(A(k))=0;
    end
    
    ET_A_Mod=zeros(1,length(A));
    k=1;
    for i=1:T
        
        if any(A == i)
            
            Eto = input(sprintf('Entrez la valeur a tester pour le jour j=%d : ', i));
            ET_A_Mod(k)=Eto;
            k=k+1;
            
        end
        py.importlib.import_module('PredRendement')
        Yield_py = py.PredRendement.PredRendement(py.list(num2cell(ETo(:)')),py.list(num2cell(Rendement_(:)')),py.list(num2cell(ET_A_Mod(:)')));
        Yield = double(py.array.array('d',Yield_py));

    end
        
    [WP,Hi]=parameterAquaCrop(culture);
    Rendement=sum(Rendement_)+sum(Yield);
    Biomasse= Rendement/Hi;
    appreciation=EvaluerRendement(culture, Rendement);
    disp(appreciation)

end
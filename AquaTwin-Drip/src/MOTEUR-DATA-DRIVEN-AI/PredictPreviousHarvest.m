function [Rendement,Biomasse]=PredictPreviousHarvest(culture,ETo)

    % T: nombre de jours de periode de croissance
    T=Croissance(culture);
    Tr=0;
    [WP,Hi]=parameterAquaCrop(culture);
    Rendement=zeros(T,1);
    Biomasse=zeros(T,1);
    
    for i=1:T
        
        v=ETo(i);
        Tpot=TranspirationPotentielle(v,i,culture);
        Tr=Tr+Tpot/v;
        B=WP*Tr;
        Rendement(i)=B*Hi;
        Biomasse(i)=B;
        
    end
    

end
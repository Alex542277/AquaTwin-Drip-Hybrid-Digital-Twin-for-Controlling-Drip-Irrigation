function ETr=EvapotranspirationRelle(Tpot,ETo,SH,J,culture)

    % Calculons a present l'evapotranspiration reelle:
    
    Ks=StressCoefficient(SH,J,culture);
    ETr=Tpot*Ks;
    

end
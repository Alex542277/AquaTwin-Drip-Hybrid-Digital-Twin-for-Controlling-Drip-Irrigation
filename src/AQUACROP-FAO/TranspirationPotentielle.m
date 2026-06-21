function Tpot=TranspirationPotentielle(ETo,JJ,culture)

    % Calcul de la transpiration potentielle par AquaCrop Tpot:
    % Tpot est l'evapotranspiration en absence du stress hydrique:Tpot est
    % calcule a partir de ETo
    
    KcTr=PlanteFeatures(JJ,culture); % Coefficient de culture. Elle depend de la couverture de la canopee(CC)
    Tpot=ETo*KcTr; % KcTr: coefficient de culture relatif de la transpiration, dependant du stade de developpement de la plante


end


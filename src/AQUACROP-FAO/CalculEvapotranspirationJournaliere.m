function ET0 =CalculEvapotranspirationJournaliere(J,culture,typeSol,lat,lon,T,RH,u2,Rs)

if(T<0)
    
    
    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid();
    [r_emitter, q_irr,Efficience]=parameterGoutteur();
    [T,V]=TempsEtVolumeEauNecessaireIrrigationAbsolu(q_irr,total_dof,J,culture,typeSol,lat,lon);
    ET0=V;
    
else
    
   [Delta, Gamma, Rn, G, T,VPD, u2]=PenmanMontheithParameter(T,RH,u2,Rs);

    % ET0 horaire
    ET0=(0.409*Delta.*(Rn-G)+Gamma.*(37./(T+273)).*abs(u2) .*VPD)./(Delta +Gamma.*(1+0.208*abs(u2)));
    ET0=max(ET0,0);
    ET0=ET0/(3600*1000);
    
end
    




end
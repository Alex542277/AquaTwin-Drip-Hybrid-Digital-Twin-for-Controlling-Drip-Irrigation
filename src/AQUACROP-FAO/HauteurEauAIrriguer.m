function Hauteur=HauteurEauAIrriguer(total_dof,J,culture,typeSol,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)
    
    [h,r,zmax]=coordonnesPlot();
    [Hcc,RU,p_s,theta_actuel]=Solfeatures(J,culture,typeSol,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
    [r_emitter, q_irr,Efficience]=parameterGoutteur();
    [dr,dz,ri,zi,zr,R]=coordonneesRacinaire(r,zmax,total_dof,J,culture);
    Hauteur=abs((Hcc-theta_actuel))*zr/Efficience;
     



end
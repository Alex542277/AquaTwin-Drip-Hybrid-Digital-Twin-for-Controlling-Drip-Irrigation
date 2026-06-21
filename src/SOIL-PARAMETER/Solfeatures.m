function[Hcc,RU,p_s,theta_actuel]=Solfeatures(J,culture,typeSol,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)
    
    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid();
    [h,r,zmax]=coordonnesPlot();
    [Hcc,Hpf,RU] = ParametresSol(alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)
    p_s=potentielHydriqueCritique(lat,lon,alpha_vg,n_vg, m_vg,theta_s,theta_r,k_s);% Soit p_s le potentiel hydrique critique de la plante:
    [dr,dz,ri,zi,zr,R]=coordonneesRacinaire(r,zmax,total_dof,J,culture);
    
    % zr = profondeur de la couche racinaire consideree (dm)
    % Reserve utile
    % RU=(Hcc-HpF)*da*zr;
    
    RU=(Hcc-Hpf)*zr;
    [C,theta_func,kr_func,K_func]=VanMualemParameter(theta_s,theta_r,alpha_vg,n_vg,m_vg,k_s);
    t_actuel=InitialSolution(lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
    theta_actuel_=theta_func(t_actuel);
    theta_actuel=theta_actuel_(1);
    
    
    
end
function[SH,Pt,k]=StresseHydriqueEtPotentielHydrique(Theta_root,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)

    [Hcc,RU,p_s,theta_actuel]=Solfeatures(J,culture,typeSol,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid();
    [r_emitter, q_irr,Efficience]=parameterGoutteur();
    [Tmax,V]=TempsEtVolumeEauNecessaireIrrigation(q_irr,total_dof,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s);
    [max_iter,tol,t]=valorsForSimulation(max(Tmax));

    % Calculons maintenant le stress hydrique:
    
    SH_=(Hcc-Theta_root)/RU ;
    figure()
    plot(t,SH_,'LineWidth', 2);
    xlabel('Temps');
    ylabel('Ks');
    title('Stress hydrique');
    grid on;

    % Potentiel Hydrique du sol:
    % Potentiel Hydrique critique de la plante:
    % Relation entre potentiel hydrique du sol et Humidite: phi_s=a*H^b+c:
    
    SH=SH_;
    phi_s=modeleRawlsSaxton(lat,lon,theta_r, theta_s, alpha_vg, n_vg, k_s);
    Pt=phi_s(Theta_root);
    
    figure()
    plot(t,Pt,'LineWidth', 2);
    xlabel('Temps');
    ylabel('Ks');
    title('Potentiel hydrique');
    grid on;
    
    if max(Pt)>=p_s
        fprintf('Stress hydrique eleve')
        k=1;
    end

end
function psi_old=InitialSolution(lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)

    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid();
    psi_old =zeros(total_dof, 1);

    
    try
        
        
        [h,r,zmax]=coordonnesPlot();
        psi_sol=ThetaInitialeOpenMeteo(zmax,h,lat,lon);
        psi_sol_=CalculTheta(psi_sol,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
        psi_old(:,1)=psi_sol_;
        
        
    catch
        
        warning('Open-Meteo unavailable, using default initial pressure head');
        psi_old(1:n_prim,1) = 0.15;
        psi_old(n_prim+1:total_dof,1) = 0.15;
        psi_sol_=CalculTheta(psi_old,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
        psi_old(:,1)=psi_sol_;
        
    end
end
    



function Trace2DFinDI(J,culture,typeSol,psi_solution,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)

    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof] = MeshGrid();
    [r_emitter, q_irr,Efficience] = parameterGoutteur();
    [T,V]=TempsEtVolumeEauNecessaireIrrigation(q_irr,total_dof,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s);
    [h,r,zmax]=coordonnesPlot();

    figure('Position',[100 100 1000 1000]);
    psi_solution_ = psi_solution(end,:)';
    psi_prim = psi_solution_(1:n_prim);
    psi_dual = psi_solution_(n_prim+1:end);
    [C,theta_func,kr_func,K_func]= VanMualemParameter(theta_s,theta_r,alpha_vg,n_vg,m_vg,k_s);

    theta_all = [theta_func(psi_prim); theta_func(psi_dual)];
    z_max = max(Y_all);
    r_max = max(X_all);
    [Rplot,Zplot] = meshgrid(linspace(0,z_max,150), linspace(0,r_max,150));

    % Interpolation coherente
    F = scatteredInterpolant(X_all, Y_all, theta_all,'natural','nearest');

    % Visualisation de la solution                     
    Theta = F(Rplot, Zplot);
    contourf(Zplot,Rplot,Theta, 400,'LineColor','none');
    colormap(jet);
    colorbar;

    xlabel('r (m)');
    ylabel('z (m)');

    xlim([0 r_max]);
    ylim([0 z_max]);
    
    % INVERSION DE L'AXE VERTICAL : l'eau descend vers le bas
    set(gca, 'YDir', 'reverse');
    
    hold on;

    % placement du goutteur
    scatter(r_emitter, 0, 1000, 'filled', 'r');
    hold off;

    drawnow;
    waitfor(gcf);
    %saveas(gcf,'Solution_Finale_Irrigation.png');

end
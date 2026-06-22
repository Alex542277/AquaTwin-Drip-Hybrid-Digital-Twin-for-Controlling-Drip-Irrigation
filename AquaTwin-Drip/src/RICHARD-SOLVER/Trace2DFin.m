function Trace2DFin(psi_solution,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s)

    % Trace 2D de la fin d'irrigation
    % Equation de Richards-DDFV
    
    [h,r,zmax] = coordonnesPlot();

    % Maillage
    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof] = MeshGrid();

    % Parametres
    [r_emitter,q_irr,Efficience] = parameterGoutteur();
    [Tmax,V] = TempsEtVolumeEauNecessaireIrrigation(q_irr,total_dof,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s);
    [max_iter,tol,t] = valorsForSimulation(Tmax);

    % Parametres Van Genuchten
    [C,theta_func,kr_func,K_func]=VanMualemParameter(theta_s,theta_r,alpha_vg,n_vg,m_vg,k_s);

    % Domaine
    r_max = max(X_all);
    z_max = max(Y_all);
    
    % Grille pour l'interpolation
   [Xplot,Yplot] = meshgrid(linspace(0,z_max,150),linspace(0,r_max,150));

   
    % Figure
    figure('Position',[100 100 1000 1000]);
    k = 0;

    % BOUCLE TEMPORELLE
    
    for l = 11:-1:0

        psi_k = psi_solution(length(t)-l,:)';
        psi_prim = psi_k(1:n_prim);
        psi_dual = psi_k(n_prim+1:end);

        % Teneur en eau
        theta_prim = theta_func(psi_prim);
        theta_dual = theta_func(psi_dual);
        theta_all = [theta_prim ; theta_dual];
        
        % Interpolation robuste
        F = scatteredInterpolant(X_all,Y_all,theta_all,'natural','nearest');
        Theta_interp = F(Xplot,Yplot);

        % Affichage
        subplot(3,4,l+1)
        contourf(Yplot, Xplot, Theta_interp, 40, 'LineColor', 'none');
        hold on;

        
        % Position physique du goutteur
        scatter(r_emitter, 0, 100, 'filled', 'r');
        hold off;
        colormap(jet);
        colorbar;

        % Axes
        xlabel('r (m)','FontSize',11);
        ylabel('z (m)','FontSize',11);

        xlim([0 r_max]);
        ylim([0 z_max]);

        % INVERSION DE L'AXE VERTICAL : l'eau descend vers le bas
        set(gca, 'YDir', 'reverse');

        axis equal tight;
        set(gca,'FontSize',10);

        if l == 11

            title(sprintf('End of irrigation  t = %.10f s',t(length(t)-k)), 'FontWeight','bold');

        else

            title(sprintf('t = %.10f s',t(length(t)-k)),'FontWeight','bold');

        end

        k = k + 1;

    end
    

    
    % Sauvegarde    
    saveas(gcf,'Solution_Fin_Irrigation.png');

end
function Trace2D(psi_solution,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s)

    % Trace 2D de l'evolution de la teneur en eau
    [h,r,zmax]=coordonnesPlot();

    % Maillage
    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof] = MeshGrid();

    % Parametres
    [r_emitter, q_irr, Efficience] = parameterGoutteur();

    [Tmax,V] = TempsEtVolumeEauNecessaireIrrigation(q_irr,total_dof,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s);

    [max_iter,tol,t] = valorsForSimulation(Tmax);

    % Parametres Van Genuchten
    
    [C,theta_func,kr_func,K_func] = VanMualemParameter(theta_s,theta_r,alpha_vg,n_vg,m_vg,k_s);

    % Domaine
    r_max = max(X_all);
    z_max = max(Y_all);

    % Grille d'affichage
    [Xplot,Yplot] = meshgrid(linspace(0,z_max,150),linspace(0,r_max,150));

    figure('Position',[120 120 1000 1000]);
    n_plot = min(12,size(psi_solution,1));

    % ETAT INITIAL
    psi0 = psi_solution(1,:)';

    for k = 1:n_plot

        % Solution 
        psi_k = psi_solution(k,:)';

        % Reconstruction du potentiel total
        psi_total = psi_k + psi0;

        % Decoupage primal / dual
        psi_prim = psi_total(1:n_prim);
        psi_dual = psi_total(n_prim+1:end);

        % Teneur en eau (loi de Van Genuchten)
        theta_prim = theta_func(psi_prim);
        theta_dual = theta_func(psi_dual);

        theta_all = [theta_prim ; theta_dual];

        % Interpolation spatiale
        F = scatteredInterpolant(X_all,Y_all,theta_all, 'natural', 'nearest');

        Theta_interp = F(Xplot,Yplot);

        % Affichage
        subplot(3,4,k)

        contourf(Yplot,Xplot,Theta_interp,40,'LineColor','none');

        hold on;

        % Goutteur
        scatter(r_emitter, 0, 100, 'filled', 'r');

        hold off;

        colormap(jet);
        colorbar;

        xlabel('r (m)','FontSize',11);
        ylabel('z (m)','FontSize',11);

        xlim([0 r_max]);
        ylim([0 z_max]);

        set(gca, 'YDir', 'reverse');

        axis equal tight;

        % Titres
        if k == 1
            title('Initial Soil Condition','FontWeight','bold');

        elseif k == 2
            title(sprintf('Start of irrigation t = %.10f s', t(k)),'FontWeight','bold');

        else
            title(sprintf('t = %.10f s', t(k)),'FontWeight','bold');
        end

    end

    % Sauvegarde
    saveas(gcf,'Solution_Debut_Irrigation.png');

end
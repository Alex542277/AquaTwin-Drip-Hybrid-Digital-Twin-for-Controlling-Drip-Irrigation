function Animation2DIrrigation(psi_solution,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)

% Parametres

[h,r,zmax]=coordonnesPlot();
[X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid();
[r_emitter,q_irr,Efficience]=parameterGoutteur();
[Tmax,V]=TempsEtVolumeEauNecessaireIrrigation(q_irr,total_dof,J,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s);
[max_iter,tol,t]=valorsForSimulation(Tmax);
[C,theta_func,kr_func,K_func]=VanMualemParameter(theta_s,theta_r,alpha_vg,n_vg,m_vg,k_s);


% GRILLE INTERPOLATION

r_max = max(X_all); 
z_max = max(Y_all); 
[Xplot,Yplot]=meshgrid(linspace(0,r_max,100),linspace(0,z_max,100));

% FIGURE
figure('Position',[120 120 1000 1000]);
colormap(jet);

% FRAMES
n_frames=size(psi_solution,1);
indices=1:max(1,round(n_frames/50)):n_frames;

% GIF
gif_filename='Animation_Irrigation.gif';

if exist(gif_filename,'file')==2
    try delete(gif_filename); catch; end
end

gifCree=false;

% BOUCLE ANIMATION
for k=1:length(indices)

    nt=indices(k);
    % SOLUTION

    psi_solution_=psi_solution(nt,:)';
    psi_prim=psi_solution_(1:n_prim);
    psi_dual=psi_solution_(n_prim+1:end);

    % TENEUR EAU
    teneur_prim=theta_func(psi_prim);
    teneur_dual=theta_func(psi_dual);
    Teneur_eau=[teneur_prim; teneur_dual];

    % INTERPOLATION

    F=scatteredInterpolant(X_all,Y_all,Teneur_eau,'natural','linear');
    Teneur_interp=F(Xplot,Yplot);

    % TRACE : r horizontal, z vertical
    % z=0 en haut (surface)

    contourf(Xplot, Yplot, Teneur_interp, 80, 'LineColor', 'none');
    colormap(jet);
    colorbar;
    caxis([theta_r theta_s]);

    % AXES : r horizontal (0 -> r_max), z vertical (0 -> z_max)
    xlabel('r (m)');
    ylabel('z (m)');

    xlim([0 r_max]);   % 0 -> 0.5 pour r
    ylim([0 z_max]);   % 0 -> 0.8 pour z

    % z=0 en haut (surface du sol)
    set(gca, 'YDir', 'reverse');
    hold on

    % SURFACE DU SOL (ligne horizontale en z=0)
   
    plot([0 r_max], [0 0],'Color', [0.55 0.27 0.07],'LineWidth', 1.5);

    % GOUTTEUR A LA SURFACE (r_emitter, z=0)
    scatter(r_emitter, 0, 600, 'filled', 'r');
    hold off

    % TITRE
    title(sprintf('Drip Irrigation : t = %.2f min', t(nt)/60));

    axis equal tight
    drawnow

    % GIF
    frame=getframe(gcf);
    im=frame2im(frame);
    [imind,cm]=rgb2ind(im,256,'nodither');

    if ~gifCree
        imwrite(imind,cm,gif_filename,'gif','LoopCount',Inf,'DelayTime',0.1);
        gifCree=true;
    else
        imwrite(imind,cm,gif_filename,'gif','WriteMode','append','DelayTime',0.1);
    end


end

end
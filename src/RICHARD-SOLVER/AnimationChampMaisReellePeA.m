function AnimationChampMaisReellePeA(psi_solution,JourSemis,JourRecolte,culture,typeSol,Tmax,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)

close all
clc

% Figure
fig = figure('Position',[100 100 500 500]);
gif = 'Animation_Culture_Saison.gif';



if exist(gif,'file')==2
    delete(gif)
end
premiereFrame = true;


% MAILLAGE
[X_all,Y_all, Xp,Yp, n_prim,n_dual, total_dof] = MeshGrid();
[C, theta_func, kr_func, K_func] = VanMualemParameter( theta_s,theta_r,alpha_vg,n_vg,m_vg,k_s);


% IMPORTANT : d?tection automatique axes
if max(X_all) < max(Y_all)
    r_coord = X_all;
    z_coord = Y_all;
else
    r_coord = Y_all;
    z_coord = X_all;
end
r_max = max(r_coord);
z_max = max(z_coord);
[Xplot,Zplot] = meshgrid(linspace(0,r_max,150),linspace(0,z_max,150));

% PLANTE + GOUTTEUR

[r_emitter, q_irr, Efficience] = parameterGoutteur();
[h, r, zmax] = coordonnesPlot();
xPlant = r_emitter;
yPlant = 0;

% Boucle jour
for Jour = JourSemis:JourRecolte

    fprintf('Jour = %d\n',Jour)
    t = linspace(0, Tmax, size(psi_solution, 1));
    
    % CROISSANCE
    age = Jour - JourSemis;
    duree = max(1, JourRecolte - JourSemis);
    croissance = age / duree;
    hauteur = 0.1 + 2*croissance;
    nbFeuilles = 2 + round(8*croissance);
    fruits = round(5*croissance);
    profondeurRacine = 0.2 + 0.6*croissance;

    % FRAMES
    indices = 1:max(1,round(size(psi_solution,1)/60)):size(psi_solution,1);

    for k = 1:length(indices)

        nt = indices(k);
        
        % Verification supplementaire de securite
        if nt > size(psi_solution, 1)
            fprintf('Erreur: nt=%d de passe size(psi_solution,1)=%d\n',nt, size(psi_solution, 1));
            continue;
        end
        
        psi = psi_solution(nt,:)';
        theta = [
            theta_func(psi(1:n_prim));
            theta_func(psi(n_prim+1:end))
        ];

        % Ajustement des axes physiques
       if max(X_all) < max(Y_all)
            r = X_all;
            z = Y_all;
        else
            r = Y_all;
            z = X_all;
        end

        F = scatteredInterpolant(r, z, theta, 'natural','linear');
        H = F(Xplot,Zplot);
        H(isnan(H)) = theta_r;

        % FIGURE
        
        clf(fig)
        hold on
        contourf(Xplot,Zplot,H,80,'LineColor','none');
        colormap(jet)
        colorbar
        caxis([theta_r theta_s])
        plot([0 r_max],[0 0],'Color',[0.55 0.27 0.07],'LineWidth',6)

        
        % GOUTTEUR (SUR SOL)
        scatter(xPlant,0,100,'r','filled')

        
        % PLANTE
        plot([xPlant xPlant],[0 -hauteur],'g','LineWidth',5)

        
        % FEUILLES
        for f = 1:nbFeuilles

            hf = f/(nbFeuilles+1);
            Lf = 0.012 + 0.52*hf;
            plot([xPlant xPlant-Lf],[-hf*hauteur -(hf+0.1)*hauteur],'g','LineWidth',2)
            plot([xPlant xPlant+Lf],[-hf*hauteur -(hf+0.1)*hauteur],'g','LineWidth',2)

        end

       
        % FRUITS
        for ff = 1:fruits
            scatter(xPlant+0.1*cos(ff),-0.2*hauteur,100,[1 0.8 0],'filled')
        end

    
        % RACINES (STABLES)
        for rr = 1:8

            angle = (-80+20*rr)*pi/180;
            L = profondeurRacine*(0.6+0.05*rr);
            x2 = xPlant + L*sin(angle);
            z2 = L*cos(angle);   % IMPORTANT : vers le bas
            plot([xPlant x2],[0 z2],'Color',[0.4 0.2 0],'LineWidth',2)

        end

        
        % Verification que nt ne depasse pas la taille de t
        temps = t(nt);
        jourAff = floor(temps/Tmax);
        reste = mod(temps,Tmax);
        heure = floor(reste/3600);
        minute = floor(mod(reste,3600)/60);
        seconde = floor(mod(reste,60));
        title(sprintf('%s |%02dh:%02dm:%02ds',upper(culture),heure,minute,seconde))

        % AXES CORRIGES

        set(gca,'YDir','reverse')
        xlabel('Rayon (m)')
        ylabel('Profondeur (m)')
        xlim([0 r_max])
        ylim([-1 z_max])   % IMPORTANT : pas negatif ici
        drawnow

        
        % GIF
        frame = getframe(fig);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);

        if premiereFrame
            imwrite(imind,cm,gif,'gif','Loopcount',inf,'DelayTime',0.05);
            premiereFrame = false;
        else
            imwrite(imind,cm,gif,'gif','WriteMode','append','DelayTime',0.05);
        end

    end
end

disp(gif)

end
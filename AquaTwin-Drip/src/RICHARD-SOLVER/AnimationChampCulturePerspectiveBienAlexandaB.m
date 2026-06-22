function AnimationChampCulturePerspectiveBienAlexandaB(psi_solution,JourSemis,T,JourRecolte,culture,typeSol,Tmax,ETcum,somme,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s)

clc
close all

% VALIDATION DES ENTREES

% Verifions que psi_solution n'est pas vide
if isempty(psi_solution)
    error('psi_solution est vide');
end

% Verifier la taille de psi_solution
[n_rows, n_cols] = size(psi_solution);

% Assurons que Tmax est valide
if Tmax <= 0
    Tmax = 86400; % 24 heures par defaut en secondes
    fprintf('Warning: Tmax invalide, utilisation de %d secondes (24h)\n', Tmax);
end

% FIGURE

fig = figure( 'Position',[100 50 1300 850],'Color',[1 1 1]);
gif='ChampCulture3DBien_.gif';

% SUPPRESSION ANCIEN GIF

if exist(gif,'file')==2
    try
        delete(gif)
    catch
        warning('Impossible de supprimer ancien GIF')
    end
end


% CONTROLE GIF

gifCree=false;

% MAILLAGE

[X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid();
[C,theta_func,kr_func,K_func] = VanMualemParameter(theta_s,theta_r,alpha_vg,n_vg,m_vg,k_s);
zmax=max(Y_all);
[Xplot,Zplot]=meshgrid(linspace(-1,1,60),linspace(0,zmax,60));

% CHAMP
[d_r,dl]=EspacementCulture(culture);
nbPlants=6;

rang1_x=0:dl:(nbPlants-1)*dl;
rang2_x=rang1_x;

rang1_y=zeros(1,nbPlants);
rang2_y=d_r*ones(1,nbPlants);

Lchamp=max(rang1_x)+dl;
lchamp=d_r+1;

% OBTENIR t - VERSION CORRIGEE

% Essayons d'obtenir t de valorsForSimulation
try
    [max_iter, tol, t] = valorsForSimulation(Tmax);
    
    % V?rifier que t est valide
    if isempty(t)
        %fprintf('Warning: t est vide, creation d''un nouveau vecteur temps\n');
        t = linspace(0, Tmax, n_rows);
    elseif ~isvector(t)
        %fprintf('Warning: t n''est pas un vecteur, creation d''un nouveau vecteur temps\n');
        t = linspace(0, Tmax, n_rows);
    elseif length(t) == 1 && t == 0
        % Cas special: t est juste [0]
        %fprintf('Warning: t ne contient qu''une valeur, creation d''un vecteur complet\n');
        t = linspace(0, Tmax, n_rows);
    end
    
catch ME
    %fprintf('Erreur dans valorsForSimulation: %s\n', ME.message);
    %fprintf('Creation d''un vecteur temps par d?faut\n');
    t = linspace(0, Tmax, n_rows);
end

% CORRECTION IMPORTANTE : Verifions et redimensionnons t
if length(t) ~= n_rows
    %fprintf('Attention: Redimensionnement de t de %d  %d\n', length(t), n_rows);
    % Creons un nouveau vecteur temps lineairement espace
    t = linspace(0, Tmax, n_rows);
end

% Verification finale que t est correct
if length(t) ~= n_rows
    error('Impossible de creer un vecteur temps de taille %d', n_rows);
end

fprintf('Vecteur temps cree avec succes: %d elements, de %.2f %.2f\n',length(t), t(1), t(end));

% BOUCLE JOUR
for Jour=JourSemis:T-1

%fprintf('Jour %d\n',Jour)

% ECRAN INTRODUCTION

if isempty(fig) || ~isgraphics(fig)
    fig=figure('Position',[100 50 1300 850],'Color',[1 1 1]);
end

figure(fig)
clf

text(.5,.60,'Jumeau agricole','Units','normalized','FontSize',28,'FontWeight','bold','HorizontalAlignment','center');
text(.5,.40,['Culture : ',upper(culture)],'Units','normalized','FontSize',18,'HorizontalAlignment','center');

axis off
drawnow

frame=getframe(gcf);
im=frame2im(frame);
[imind,cm]=rgb2ind(im,256,'nodither');

% ECRITURE GIF

if gifCree==false
    imwrite(imind,cm,gif,'gif','LoopCount',Inf,'DelayTime',2);
    gifCree=true;
else
    imwrite(imind,cm,gif,'gif','WriteMode','append','DelayTime',2);
end

pause(2)

% PARAMETRES SIMULATION

[r_emitter, q_irr, Efficience] = parameterGoutteur();
% CORRECTION: Indices raisonnables pour l'animation
% Ne pas prendre plus de 60 frames par jour pour eviter la surcharge

max_frames_per_day = 60;
if n_rows <= max_frames_per_day
    indices = 1:n_rows;
else
    step = round(n_rows / max_frames_per_day);
    indices = 1:step:n_rows;
end

fprintf('Animation: %d frames pour ce jour\n', length(indices));

% CROISSANCE CULTURE
[hauteur, nbFeuilles, profondeurRacine, fruits, largeurFeuille]=CroissanceCulture(Jour, JourSemis, JourRecolte, culture);

% ANIMATION
for k=1:length(indices)

    figure(fig)
    clf
    hold on

    nt = indices(k);
    
    % Verification que nt est valide
    if nt < 1
        nt = 1;
    elseif nt > n_rows
        fprintf('Warning: nt=%d depasse n_rows=%d, utilisation de %d\n', nt, n_rows, n_rows);
        nt = n_rows;
    end

    % Extraire la solution pour cet instant
    psi = psi_solution(nt,:)';
    
    % Verifions que psi a la bonne taille
    if length(psi) < n_prim + n_dual
        fprintf('Warning: psi a %d elements, attendu %d\n', length(psi), n_prim + n_dual);
        % Pas avec des zeros si necessaire
        psi = [psi; zeros(n_prim + n_dual - length(psi), 1)];
    end

    theta = [theta_func(psi(1:n_prim)); theta_func(psi(n_prim+1:end))];

    F = scatteredInterpolant(X_all, Y_all, theta, 'natural', 'linear');
    H = F(Xplot,Zplot);
    H(isnan(H)) = theta_r;

    % SOL
    
    surf([-1 Lchamp;-1 Lchamp], [-1 -1;lchamp lchamp], [0 0;0 0], 'FaceColor', [0.55 0.27 0.07], 'EdgeColor', 'none');

    % PLANTES

    for rang=1:2
        if rang==1
            Xc=rang1_x;
            Yc=rang1_y;
        else
            Xc=rang2_x;
            Yc=rang2_y;
        end

        for i=1:length(Xc)
            xc=Xc(i);
            yc=Yc(i);

            surf(xc+Xplot, yc+0*Xplot, -Zplot, H, ...
                 'FaceAlpha',0.75, 'EdgeColor','none');

            scatter3(xc,yc,0,120,'r','filled');
            plot3([xc xc],[yc yc],[0 hauteur],'g','LineWidth',3);

            % FEUILLES
            for f=1:nbFeuilles
                hf=f/(nbFeuilles+1);
                Lf=largeurFeuille;
                plot3([xc xc+Lf],[yc yc],[hf*hauteur (hf+.1)*hauteur],'g');
                plot3([xc xc-Lf],[yc yc],[hf*hauteur (hf+.1)*hauteur],'g');
            end

            % FRUITS
            for ff=1:fruits
                scatter3(xc, yc, 0.6*hauteur, 100, [1 .6 0], 'filled');
            end

            % RACINES
            for rr=1:8
                angle=2*pi*rr/8;
                xr=xc+.3*cos(angle);
                yr=yc+.3*sin(angle);
                zr=-profondeurRacine*(.5+.5*rand);
                plot3([xc xr],[yc yr],[0 zr],'Color',[.1 .05 0]);
            end
        end
    end

    % TEMPS CORRIGE AVEC VERIFICATION DE S?CURIT?
    if nt <= length(t)
        temps = t(nt);
    else
        fprintf('Warning: nt=%d > length(t)=%d, utilisation de la derni?re valeur\n', nt, length(t));
        temps = t(end);
    end

    heure = floor(temps/3600);
    minute = floor(mod(temps,3600)/60);
    seconde = floor(mod(temps,60));

    title(sprintf('%s | Jour:%d | Irrigation: %02d:%02d:%02d', ...
                  upper(culture), Jour, heure, minute, seconde));

    view(-35,25)
    camlight
    lighting gouraud
    camproj perspective

    xlim([-1 Lchamp])
    ylim([-1 lchamp])
    zlim([-2 3])

    axis off
    drawnow


    % FRAME GIF

    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256,'nodither');

    if gifCree==false
        imwrite(imind,cm,gif,'gif','LoopCount',Inf,'DelayTime',0.08);
        gifCree=true;
    else
        imwrite(imind,cm,gif,'gif','WriteMode','append','DelayTime',0.08);
    end

end

end

% ECRAN FINAL

if T==JourRecolte

    [Biomasse, Rendement] = RendementBiomasse(culture,somme);
    EH = efficienceHydrique(Rendement,ETcum);

    figure(fig)
    clf

    text(.5,.80,'RECOLTE','Units','normalized','FontWeight','bold',...
         'FontSize',30,'HorizontalAlignment','center');
    text(.5,.60,['Biomasse : ',num2str(mean(Biomasse),'%.2f')],...
         'Units','normalized','FontSize',20,'HorizontalAlignment','center');
    text(.5,.45,['Rendement : ',num2str(mean(Rendement),'%.2f')],...
         'Units','normalized','FontSize',20,'HorizontalAlignment','center');
    text(.5,.30,['Efficience hydrique : ',num2str(mean(EH),'%.2f')],...
         'Units','normalized','FontSize',20,'HorizontalAlignment','center');

    axis off
    drawnow

    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256,'nodither');

    if gifCree==false
        imwrite(imind,cm,gif,'gif','LoopCount',Inf,'DelayTime',8);
        gifCree=true;
    else
        imwrite(imind,cm,gif,'gif','WriteMode','append','DelayTime',8);
    end

    pause(8)

    disp('RECOLTE')
    disp(['Biomasse : ',num2str(Biomasse)])
    disp(['Rendement : ',num2str(mean(Rendement))])
    disp(['Efficience hydrique : ',num2str(mean(EH))])
    disp(['GIF : ',gif])
    

end

end
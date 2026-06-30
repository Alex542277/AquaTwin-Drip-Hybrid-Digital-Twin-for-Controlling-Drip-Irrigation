function main_good(culture,typeSol,pas_heure,JourJulien,lat,lon)

    
    if nargin < 4
        error('Le parametre culture est obligatoire');
    end
    if ~exist('typeSol', 'var') || isempty(typeSol)
        typeSol=classifySoilType(lat,lon);  % Valeur par defaut
    end
    c=1;
    heureSemisorStartsystem = hour(datetime('now'));
    today=datetime('today'); % System Start Date
    Tcroissance = Croissance(culture);
    JourRecolte=Tcroissance+heureSemisorStartsystem;
    

    t=0:pas_heure:JourRecolte*24;
    somme=0;
    ETcum=0;
    
    heure = hour(datetime('now'));
    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid();
    [r_emitter, q_irr,Efficience]=parameterGoutteur();
    [T,RH,u2,Rs]=DataEvapotranspiration(lat,lon);
    [alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s]=vanMualemParametersValor(lat,lon);
    [Capacite_hydrique, theta_func, kr_func, K_func] = VanMualemParameter(theta_s, theta_r, alpha_vg, n_vg, m_vg, k_s);
    if(T<0)
        
        [Tmax,V]=TempsEtVolumeEauNecessaireIrrigationAbsolu(q_irr,total_dof,heure,culture,typeSol,lat,lon);
        
    else
        
        [Tmax,V]=TempsEtVolumeEauNecessaireIrrigation(q_irr,total_dof,JourJulien,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s);

        
    end
    
    
    fprintf('Volume Eau Necesaire %d\n', max(V));
    fprintf('Temps Irrigation: %.10f\n', max(T));
    
   
    [max_iter,tol,t]=valorsForSimulation(Tmax);
    [h,r,zmax]=coordonnesPlot();
    [dr,dz,ri,zi,zr,R]=coordonneesRacinaire(r,zmax,total_dof,JourJulien,culture);
    Theta_r=zeros(length(zi),1);
    
    
    % Variables de controle ajoutees pour eviter la boucle infinie
    tempsSimule = 0;
    dureeSimulation = JourRecolte * 24;
    theta_infiltre=0;
    
    while tempsSimule < dureeSimulation
        
        % Incrementation du temps simule
        tempsSimule = tempsSimule + pas_heure;
        
        heure = hour(datetime('now'));
        minute_actuelle = minute(datetime('now'));
        Temps=heure+pas_heure;
        c = c + 1;
        
        psi_old=InitialSolution(lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
        % Nouvelles donnees meteos
        [T, RH, u2, Rs] = DataEvapotranspiration(lat, lon);
            
        if(T<0)
        
            [Tmax,V]=TempsEtVolumeEauNecessaireIrrigationAbsolu(q_irr,total_dof,heure,culture,typeSol,lat,lon);
                
        else
                
            [Tmax,V]= TempsEtVolumeEauNecessaireIrrigation(q_irr,total_dof,JourJulien,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s);

        end
            
        fprintf('Volume Eau Necessaire %d\n', max(V));
        fprintf('Temps Irrigation: %.10f\n', max(Tmax));
        [max_iter,tol,t]=valorsForSimulation((Tmax));
        Psi_solution=zeros(length(t),total_dof);
        Psi_solution(1,:)=psi_old+CalculTheta(theta_infiltre,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
        Theta_root=TraceDeLaTeneurEnEauRacinaireVeri(Theta_r,Psi_solution,heure,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
        [SH,Pt,k]=StresseHydriqueEtPotentielHydriqueVeri(Theta_root,heure,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
            
        if k==1

            if(T<0)
                [solution,Tmax,V]=DDFVRichardIrrigation(psi_old,heure,culture,typeSol,lat,lon);
            else
                [solution, Erreur]=DDFVRichardIrrigationAPI(psi_old,heure,culture,typeSol,lat,lon,Tmax,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
            end
                
            % Mise a jour de psi_old pour la prochaine iteration
                
            Trace2D(solution,heure,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s);
            Trace2DFin(solution,heure,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg,m_vg,theta_s,theta_r,k_s)
            Trace2DFinDI(heure,culture,typeSol,solution,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
            AnimationChampMaisReellePeA(solution,heureSemisorStartsystem,Temps,culture,typeSol,max(Tmax),lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
            Animation2DIrrigation(solution,heure,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
            ETo = CalculEvapotranspirationJournaliere(heure,culture,typeSol,lat,lon,T,RH,u2,Rs);
            Tpot = TranspirationPotentielle(max(ETo),heure,culture);
            ETr = EvapotranspirationRelle(max(Tpot),max(ETo),SH,heure,culture);
            ETcum=ETcum + ETr;
            somme=somme + ETr/ETo;
            AnimationChampCulturePerspectiveBienAlexandaB(solution,heureSemisorStartsystem,Temps,JourRecolte,culture,typeSol,Tmax,ETcum,somme,lat,lon,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
            [SH,Pt,l]=StresseHydriqueEtPotentielHydrique(Theta_root,heure,culture,typeSol,lat,lon,T,RH,u2,Rs,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
            
            figure(100);
            subplot(2,1,1);
            plot(c,max(V),'o','MarkerSize',3,'LineWidth',2);
            xlabel('temps');
            ylabel('volume');
            hold on;
            
            subplot(2,1,2);
            plot(c,max(Tmax),'o','MarkerSize',3,'LineWidth',2);
            xlabel('temps');
            ylabel('Temps Irrigation');
            hold on;
            
            [SH, Pt,t_t,Theta_root]=TraceTeneurEnEauRacinaireStresseHydriqueEtPotentielHydrique_(lat,lon,culture,typeSol,Tmax+3600,solution,Tmax,heure,alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s);
            Theta_r=Theta_root;
            theta_infiltre=interp1(t_t, Theta_root, Temps);
                
        end

        next=datetime('today');
        if next==today
            % Meme jour, pas de changement
            y=0;
            JourJulien=JourJulien+y;
        else
            JourJulien=JourJulien+1;
            today=next;
            fprintf('Jour %d \n', JourJulien);
        end
        
        % SYSTEME REEL
        pause(pas_heure*3600);
        
    end

        
end
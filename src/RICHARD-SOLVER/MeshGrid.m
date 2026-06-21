function [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid()

  % Grille primale (centres des cellules)
  % Coordonnees des maillages
  
    [h,r,zmax]=coordonnesPlot();
    [Xp, Yp] = meshgrid(h/2:h:1-h/2, h/2:h:1-h/2);
    [Xd, Yd] = meshgrid(0:h:1, 0:h:1);

    % Vectorisation

    Xp = r*Xp(:);  Yp = zmax*Yp(:);
    Xd = r*Xd(:);  Yd = zmax*Yd(:);
    
    % Fusion DDFV (PRIMAL + DUAL)

    X_all = [Xp; Xd];
    Y_all = [Yp; Yd];
    n_prim = length(Xp);           % N^2 points primaux
    n_dual = length(Xd);           % (N+1)^2 points duaux
    total_dof = n_prim + n_dual;

end
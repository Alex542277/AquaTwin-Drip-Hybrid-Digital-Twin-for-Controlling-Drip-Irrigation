function [psi_omega,psi_c,psi_h,ro,A,d_r,phi]=parametresSource(total_dof,culture,typesol)
    
    [psi_w, psi_h_, psi_c_] = SeuilsHydriques(culture, typesol);
    psi_omega=ones(total_dof, 1); % Saturation
    psi_c=ones(total_dof, 1); % arret de transpiration
    psi_h=ones(total_dof, 1); % Debut de stress
    psi_omega(:,1)=psi_w; 
    psi_c(:,1)=-psi_c_;
    psi_h(:,1)=-psi_h_;
    [d_r,dl]=EspacementCulture(culture);
    A=d_r*dl; % Surface correspondant a une plante
    phi = @(t) -sin(t-2*pi); % 0 la nuit
    ro = @(r,z)1/A;

end
function [Hcc, Hpf, RU] = ParametresSol(alpha,n, m_vg,theta_s, theta_r,k_s)
    
    % Utilise Rosetta (via SoilGrids) pour donnees reelles
    % van Genuchten pour les seuils
    
    psi_fc = 33000;     
    psi_pwp = 1500000;  
    
    Se_fc = (1 + (alpha * psi_fc)^n)^(-(1 - 1/n));
    Hcc = theta_r + Se_fc * (theta_s - theta_r);
    
    Se_pwp = (1 + (alpha * psi_pwp)^n)^(-(1 - 1/n));
    Hpf = theta_r + Se_pwp * (theta_s - theta_r);
    RU = Hcc - Hpf;
    
end
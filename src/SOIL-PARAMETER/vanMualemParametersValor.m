function [alpha_vg,n_vg, m_vg,theta_s, theta_r,k_s]=vanMualemParametersValor(lat,lon)

    % Recuperation des parametres via SoilGrids + Rosetta
    [theta_r, theta_s, alpha_vg_cm, n_vg, k_s_cm_day,Sand, Silt, Clay, BD] = SoilGrids_Rosetta(lat, lon);
    
    % Conversion des unites pour RicharDs
    alpha_vg = alpha_vg_cm * 100;  
    
    % Ks : conversion de cm/jour 
    % 1 cm/jour = 1e-2 m / (86400 s) = 1.1574e-7 m/s
    k_s = k_s_cm_day * 1.1574e-7;  % m/s
    
    % m : parametre derive (optionnel, souvent utilise)
    m_vg = 1 - 1/n_vg;
    
end
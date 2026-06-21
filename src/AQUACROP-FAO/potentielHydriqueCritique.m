function p_s = potentielHydriqueCritique(lat,lon,alpha_vg,n_vg, m_vg,theta_s,theta_r,k_s)
    
    % theta_critique : l'humidite (m3/m3) a laquelle la plante commence a se stresser
    % a, b, theta_r : parametres du sol
    
    [a, b, theta_r] = parametresRawlsSaxton(lat,lon,theta_r, theta_s, alpha_vg, n_vg, k_s);
    [Hcc,Hpf,RU] = ParametresSol(alpha_vg,n_vg, m_vg,theta_s,theta_r,k_s);
    theta_critique = Hpf + 0.5 * (Hcc-Hpf);
    theta_eff = max(theta_critique - theta_r, 0.001);
    p_s = -(theta_eff / a)^(1/b);  % Potentiel critique en hPa
    
end
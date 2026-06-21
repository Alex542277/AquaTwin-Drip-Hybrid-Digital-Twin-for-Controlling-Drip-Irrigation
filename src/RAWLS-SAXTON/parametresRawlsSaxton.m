function [a, b, theta_r] = parametresRawlsSaxton(lat,lon,theta_r, theta_s, alpha, n, k_s)

    % Version Systeme International (Pa, m/s)
    m = 1 - 1/n;

    % Capacite au champ (psi_fc = -33 kPa = -33000 Pa)

    psi_fc = 33000;  % Pa (valeur positive pour le calcul)
    Se_fc = (1 + (alpha * psi_fc)^n)^(-m);
    theta_fc = theta_r + Se_fc * (theta_s - theta_r);

    % Point de fletrissement ( psi_pwp = -1500 kPa = -1500000 Pa)

    psi_pwp = 1500000;  % Pa (valeur positive pour le calcul)
    Se_pwp = (1 + (alpha * psi_pwp)^n)^(-m);
    theta_pwp = theta_r + Se_pwp * (theta_s - theta_r);
    
    % Calcul des parametres a et b pour la loi de puissance
    % Relation : phi_s=@(H) a*H.^(b)+c;

    theta_fc_eff = theta_fc - theta_r;
    theta_pwp_eff = theta_pwp - theta_r;
    b = log(theta_pwp_eff / theta_fc_eff) / log(psi_pwp / psi_fc);
    a = theta_fc_eff / (psi_fc^b);
    
end
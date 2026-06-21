function[Capacite_hydrique, theta_func,kr_func,K_func]=VanMualemParameter(theta_s,theta_r,alpha_vg,n_vg,m_vg,k_s)

    % Fonction capacite hydrique C(psi)
    Capacite_hydrique= @(psi) (theta_s - theta_r) * m_vg * n_vg * alpha_vg^n_vg * abs(psi).^(n_vg-1) ./ ...
               ((1 + abs(alpha_vg * psi).^n_vg).^(m_vg+1));    

    % Fonction teneur en eau theta(psi)
    theta_func = @(psi) theta_r + (theta_s - theta_r) ./ ((1 + abs(alpha_vg * psi).^n_vg).^m_vg);

    % Fonction permeabilite relative (loi de Mualem-van Genuchten)
    kr_func = @(Se) sqrt(Se) .* (1 - (1 - Se.^(1/m_vg)).^m_vg).^2;

    % Fonction permeabilite K(psi)
    K_func = @(psi) k_s * kr_func((theta_func(psi) - theta_r) / (theta_s - theta_r));
    
    

end
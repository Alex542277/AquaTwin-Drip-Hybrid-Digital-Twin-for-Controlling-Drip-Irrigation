function phi_s=modeleRawlsSaxton(lat,lon,theta_r, theta_s, alpha, n, k_s)

    % modele de Rawls et Saxton
    [a, b, c]=parametresRawlsSaxton(lat,lon,theta_r, theta_s, alpha, n, k_s)
    phi_s=@(H) a*H.^(b)+c;
    
end
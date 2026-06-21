function thetaInitiale=ThetaInitialeOpenMeteo(zmax,h,lat,lon)

thetaDuale=ThetaInitialeDualeOpenMeteo(zmax,h,lat,lon);
thetaPrimale=ThetaInitialePrimaleOpenMeteo(zmax,h,lat,lon);

% CONCATENATION
thetaInitiale = [thetaDuale;thetaPrimale ];

end
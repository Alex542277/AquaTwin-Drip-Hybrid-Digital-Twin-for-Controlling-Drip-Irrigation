function [Delta,Gamma,Rn,G,T,VPD,u2]=PenmanMontheithParameter(T,RH,u2,Rs)


% Pression vapeur saturante
ew =0.6108.*exp(17.27*T./(T+237.3));

% Pression vapeur reelle

e = RH.*ew/100;

% VPD

VPD = ew-e;

% Delta

Delta =4098.*ew./(T+237.3).^2;

% Gamma

P = 101.3;
Gamma =0.000665*P;

% Rayonnement net

alpha = 0.23;

Rn =(1-alpha)*Rs;


% Flux chaleur sol G

G = zeros(size(Rn));
jour = Rs>0;
G(jour)=0.1*Rn(jour);
G(~jour)=0.5*Rn(~jour);

end
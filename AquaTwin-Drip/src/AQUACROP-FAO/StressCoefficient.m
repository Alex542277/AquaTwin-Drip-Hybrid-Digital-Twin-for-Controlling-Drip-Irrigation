function Ks = StressCoefficient(SH, J,culture)

switch culture

case 'mais'
    p = 0.50;

case 'coton'
    p = 0.55;

case 'tomate'
    p = 0.40;

end

SH_=mean(SH);

Ks = min(1,max(0,((SH_)/(1-p))));

end
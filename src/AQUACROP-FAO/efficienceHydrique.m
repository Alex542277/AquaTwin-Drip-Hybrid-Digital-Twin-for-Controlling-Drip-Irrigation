function EH=efficienceHydrique(Rendement,ETcum)

    EH = max(Rendement)/(ETcum*24*3600);

end
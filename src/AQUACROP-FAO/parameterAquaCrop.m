function [WP,Hi] = parameterAquaCrop(culture)

switch culture

    case 'mais'
        Hi = 0.50;
        WP = 4.5;

    case 'coton'
        Hi = 0.35;
        WP = 2.8;

    case 'tomate'
        Hi = 0.65;
        WP = 6.5;

    otherwise
        error('Culture non reconnue');

end

end
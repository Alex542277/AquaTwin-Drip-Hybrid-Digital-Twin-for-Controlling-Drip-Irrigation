function matArray = convertPy(pyArray)
    
    if ~isa(pyArray, 'py.object')
        % Ce n'est pas un objet Python, c'est probablement un tableau MATLAB
        if isnumeric(pyArray) || islogical(pyArray) || ischar(pyArray) || isstring(pyArray)
            matArray = pyArray;
            return;
        end
    end
    
    try
        
        % Cas 1: Numpy array
        if isa(pyArray, 'py.numpy.ndarray')
            
            % Verifier si c'est un scalaire numpy
            if pyArray.size == 1
                matArray = double(pyArray.item());
            else
                
                % Convertir en liste puis en array MATLAB
                matArray = double(py.array.array('d', pyArray.flatten()));
                
                % Reshape si necessaire
                if pyArray.ndim > 1
                    dims = cellfun(@double, cell(pyArray.shape));
                    matArray = reshape(matArray, dims);
                end
            end
            return;
        end
        
        % Cas 2: Liste Python
        if isa(pyArray, 'py.list')
            matArray = double(py.array.array('d', pyArray));
            return;
        end
        
        % Cas 3: Tuple Python
        if isa(pyArray, 'py.tuple')
            matArray = double(py.array.array('d', py.list(pyArray)));
            return;
        end
        
        % Cas 4: Scalaire Python (float, int, long)
        if isa(pyArray, 'py.float') || isa(pyArray, 'py.int') || isa(pyArray, 'py.long')
            matArray = double(pyArray);
            return;
        end
        
        % Cas 5: String Python
        if isa(pyArray, 'py.str')
            matArray = char(pyArray);
            return;
        end
        
        % Cas 6: Tentative generique
        % Essayer de convertir en liste d'abord
        if py.hasattr(pyArray, '__iter__')
            pyList = py.list(pyArray);
            matArray = double(py.array.array('d', pyList));
        else
            matArray = double(pyArray);
        end
        
    catch ME
        
        % Derniere tentative: conversion directe
        try
            matArray = double(pyArray);
        catch
            error('Conversion impossible: type=%s, erreur=%s', ...
                char(py.type(pyArray)), ME.message);
        end
    end
end
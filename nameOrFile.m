function out = nameOrFile(in, mode)

    switch mode
        case 'em'
            reader = @emread;
        case 'mrc'
            reader = @mrcreadMK;
    end
    
    
    if ischar(in)
        out = reader(in);
    else
        out = in;
    end
end
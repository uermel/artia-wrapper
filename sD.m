function outstr = sD(str)
% Make directory names sane (ending with a /)

    if strcmp(str(end), '/')
        outstr = str;
    else 
        outstr = [str '/'];
    end
end
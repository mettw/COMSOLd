% Like the load() function, but it also handles complex numbers.

function out = loadcomplex(fname)
    out = [];
    
    % Open file
    [fd, errmsg] = fopen(fname, 'r');
    
    if fd == -1
        error( 'loadcomplex: %s: %s\n', fname, errmsg);
    end
    
    cur_line = fgets(fd);
    while cur_line ~= -1
        data = cell2mat(textscan(cur_line, '%f'));
        if ~isempty(data)
            out = [out; data'];
        end
        cur_line = fgets(fd);
    end
    
    %close file
    close_status = fclose(fd);
    if close_status == -1
        warning('loadcomplex: Error while closing file.\n');
    end
    
end
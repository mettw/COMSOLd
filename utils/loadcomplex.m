% Like the load() function, but it also handles complex numbers.
% {
function out = loadcomplex(fname)
    % Open file
    [fd, errmsg] = fopen(fname, 'r');
    
    if fd == -1
        error( 'loadcomplex: %s: %s\n', fname, errmsg);
    end
    
    % Read first line to determine number of entries per line
    cur_line = fgets(fd);
    while cur_line(1) == '%'
        cur_line = fgets(fd);
    end
    data = cell2mat(textscan(cur_line, '%f'));
    
    if isempty(data)
        out = [];
        fclose(fd);
        return;
    end
    
    num_cols = length(data); % Number of columns per line
    
    % Pre-count the number of lines in the file
    num_lines = 1; % We already have one line
    while fgets(fd) ~= -1
        num_lines = num_lines + 1;
    end
    
    % Pre-allocate 'out' based on number of lines and columns
    out = zeros(num_lines, num_cols);
    
    % Rewind to the start of the file
    fseek(fd, 0, 'bof');
    
    % Now read the file and fill the pre-allocated 'out' matrix
    cur_line = fgets(fd);
    line_idx = 1;
    while cur_line ~= -1
        data = cell2mat(textscan(cur_line, '%f'));
        if ~isempty(data)
            out(line_idx, :) = data';
            line_idx = line_idx + 1;
        end
        cur_line = fgets(fd);
    end
    
    % Convert -0 to 0
    out(out == 0) = 0;

    % Convert very small values to zero 

    % Calculate mean and standard deviation
    x = log10(abs(out(:,1)));
    x(isinf(x)) = 0; % 0 goes to Inf with log10()
    mean_x = mean(x);
    std_x = std(x);
    
    % Define the threshold for exclusion (5 standard deviations)
    threshold = mean_x - 5 * std_x;
    
    % Exclude values that are more than 5 standard deviations from the mean
    out(x<=threshold,1) = 0;

    % Calculate mean and standard deviation
    x = log10(abs(out(:,2)));
    x(isinf(x)) = 0; % 0 goes to Inf with log10()
    mean_x = mean(x);
    std_x = std(x);
    
    % Define the threshold for exclusion (5 standard deviations)
    threshold = mean_x - 5 * std_x;
    
    % Exclude values that are more than 5 standard deviations from the mean
    out(x<=threshold,2) = 0;

    % Close file
    close_status = fclose(fd);
    if close_status == -1
        warning('loadcomplex: Error while closing file.\n');
    end
end
%}
%{
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
%}
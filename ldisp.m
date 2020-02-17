function ldisp(fid, message)
    % Write to log file.
	fprintf(fid, '%s\r\n', message);
    
	% Write to console
	disp(message); % To command window.
    
	
return;
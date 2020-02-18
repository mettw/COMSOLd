function ldisp(fid, message)
    % Write to log file.
	fprintf(fid, [convertStringsToChars(message), '\r\n']);
    
	% Write to console
	fprintf([convertStringsToChars(message) '\n']); % To command window.
    
	
return;
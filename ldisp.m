function ldisp(fid, message)
    % Write to log file.
    if fid ~= -1
        fprintf(fid, [convertStringsToChars(message), '\r\n']);
    end
    
	% Write to console
	fprintf([convertStringsToChars(message) '\n']); % To command window.
    
	
return;
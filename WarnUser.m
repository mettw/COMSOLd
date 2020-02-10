function WarnUser(errorMessage, fid)
    % Write error to log file.
	fprintf(fid, '%s\r\n', errorMessage);
    
	% Alert user via the command window.
	warning(errorMessage); % To command window.
    
    % popup message.
	%uiwait(warndlg(errorMessage));
	
return; % from WarnUser()
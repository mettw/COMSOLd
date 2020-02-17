function ErrorUser(fid, errorMessage)
    % Write error to log file.
	fprintf(fid, '%s\r\n', errorMessage);
    
	% Alert user via the command window.
	error(errorMessage); % To command window.
    
    % popup message.
	%uiwait(warndlg(errorMessage));
	
return; % from WarnUser()
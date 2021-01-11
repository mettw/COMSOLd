classdef COMSOLdFarfield < handle
    % COMSOLdFarfield - Farfields saved from COMSOLd job.
    %
    % This object is generated by a COMSOLdResults object via the
    % getFarfield method.
    %
    % Because there is a seperate farfield for each frequency in the study
    % this class only presents a single farfield at a time.  Like with
    % the COMSOLdResults class you can step through the frequencies with
    % similar methods as explained in that class file.
    %
    % Data is accessed through the getField method:
    %
    % farfield.getField("Ex")
    %
    % for example returns and array of the x component of the E field at  
    % the current frequency, and so on. Obviously you need to modify this 
    % class file to match the cut plane files that your comsol file 
    % outputs.  By default the current class calculates the farfield time
    % averaged Poynting vector, which can be accessed with 
    % getField("Poynting") and getField("relPoynting") for the ralive field
    % Poynting vector.
    %
    % The method
    %
    % farfield.getPartField("Ex", x_range, y_range)
    %
    % returns only a portion of the cut plane, with x_range and y_range
    % being indexes into the array.
    %
    
    properties (SetAccess='private')
        % where the completed job scripts are stored.
        jobs_dir = 'C:\Users\matthew\MATLAB Drive\COMSOL\jobs\completed\';
        
        % Change the path temprorarily to add these directories where the
        % function scripts are kept.
        COMSOL_dir = {'C:\Users\matthew\MATLAB Drive\COMSOL\', ...
            'C:\Users\matthew\MATLAB Drive\COMSOL\COMSOLd\', ...
            'C:\Users\matthew\MATLAB\Projects\COMSOLd\config\', ...
            'C:\Users\matthew\MATLAB\Projects\COMSOLd\post_processing\'};
        
        % The options struct defined by the job script.
        options;
       
        % Data
        x;
        y;
        
        Ex;
        Ey;
        Ez;
        relEx;
        relEy;
        relEz;
         
        Hx;
        Hy;
        Hz;
        relHx;
        relHy;
        relHz;
        
        Pynting;
        relPoynting;
        
        % Which frequency are we looking at
        freq_num;
        
        % Whether we are stepping through frequencies
        stepping_through_freqs;
    end
    
    methods
        %%
        %
        % SETUP functions
        %
        function hObj = COMSOLdFarfield(options, farfield_in)
            
            hObj.options = options;
            hObj.freq_num = 1;
            hObj.stepping_through_freqs = false;
            
            hObj.x = farfield_in.x;
            hObj.y = farfield_in.y;

            hObj.Ex = farfield_in.Ex_ff;
            hObj.Ey = farfield_in.Ey_ff;
            hObj.Ez = farfield_in.Ez_ff;
            hObj.relEx = farfield_in.relEx_ff;
            hObj.relEy = farfield_in.relEy_ff;
            hObj.relEz = farfield_in.relEz_ff;

            hObj.Hx = farfield_in.Hx_ff;
            hObj.Hy = farfield_in.Hy_ff;
            hObj.Hz = farfield_in.Hz_ff;
            hObj.relHx = farfield_in.relHx_ff;
            hObj.relHy = farfield_in.relHy_ff;
            hObj.relHz = farfield_in.relHz_ff;

            hObj.Pynting = farfield_in.Poynting;
            hObj.relPoynting = farfield_in.relPoynting;
        
        end
      
        %%
        % 
        % Methods to access data
        %
        
        
        % How many freqs are there?
        %
        function out = numFreqs(hObj)
            out = size(hObj.Ex, 3);
        end
        
        % Is there another study in the sweep?
        %
        function out = moreFreqs(hObj)
            % If we are on the last study, so there is no next study
            if hObj.freq_num == hObj.numFreqs()
                out = false;
            else
                out = true;
            end
        end
        
        % Is there a previous study in the sweep?
        %
        function out = earlierFreqs(hObj)
            % If we are on the first study, so there is no previous study
            if hObj.freq_num == 1
                out = false;
            else
                out = true;
            end
        end
        
        % Move a particular study
        %
        function setFreq(hObj, num)
            % The requested study does not exist
            if num < 1 || num > hObj.numFreqs()
                error("Requested frequency number %d but there are only %d studies", num, hObj.numFreqs());
            else
                hObj.freq_num = num;
            end
        end
        
        % Move to the next study
        %
        function nextFreq(hObj)
            % If we are on the last study, so there is no next study
            if ~hObj.moreFreqs()
                error("No next frequency");
            else
                hObj.setFreq(hObj.freq_num + 1);
            end
        end
        
        % Move to the previous study
        %
        function previousFreq(hObj)
            if ~hObj.earlierFreqs()
                error("No previous frequency");
            else
                hObj.setFreq(hObj.freq_num - 1);
            end
        end
        
        % Move to the first study
        %
        function firstFreq(hObj)
            hObj.setFreq(1);
        end
        
        % Move to the last study
        %
        function lastFreq(hObj)
            hObj.setFreq(hObj.numFreqs());
        end
        
        
        % Step through the frequencies one at a time
        %
        function out = stepThroughFrequencies(hObj)
            % If this is the first step
            if ~hObj.stepping_through_freqs
                hObj.stepping_through_freqs = true;
                hObj.firstFreq();
                out = true;
            else
                if hObj.moreFreqs()
                    hObj.nextFreq();
                    out = true;
                else
                    hObj.stepping_through_freqs = false;
                    out = false;
                end
            end
        end
        
        % Only get a field at the current frequency
        function out = getField(hObj, field)
            switch lower(field)
                case "ex"
                    out = squeeze(hObj.Ex(:,:,hObj.freq_num));
                case "ey"
                    out = squeeze(hObj.Ey(:,:,hObj.freq_num));
                case "ez"
                    out = squeeze(hObj.Ez(:,:,hObj.freq_num));
                case "relex"
                    out = squeeze(hObj.relEx(:,:,hObj.freq_num));
                case "reley"
                    out = squeeze(hObj.relEy(:,:,hObj.freq_num));
                case "relez"
                    out = squeeze(hObj.relEz(:,:,hObj.freq_num));
                case "hx"
                    out = squeeze(hObj.Hx(:,:,hObj.freq_num));
                case "hy"
                    out = squeeze(hObj.Hy(:,:,hObj.freq_num));
                case "hz"
                    out = squeeze(hObj.Hz(:,:,hObj.freq_num));
                case "relhx"
                    out = squeeze(hObj.relHx(:,:,hObj.freq_num));
                case "relhy"
                    out = squeeze(hObj.relHy(:,:,hObj.freq_num));
                case "relhz"
                    out = squeeze(hObj.relHz(:,:,hObj.freq_num));
                case "poynting"
                    out = squeeze(hObj.Poynting(:,:,hObj.freq_num));
                case "relpoynting"
                    out = squeeze(hObj.relPoynting(:,:,hObj.freq_num));
                otherwise
                    error("Unknown field: %s", field);
            end
        end
        
        % get a subsection of the field at the current frequency
        function out = getPartField(hObj, field, x_range, y_range)
            switch lower(field)
                case "ex"
                    out = squeeze(hObj.Ex(x_range, y_range,hObj.freq_num));
                case "ey"
                    out = squeeze(hObj.Ey(x_range, y_range,hObj.freq_num));
                case "ez"
                    out = squeeze(hObj.Ez(x_range, y_range,hObj.freq_num));
                case "relex"
                    out = squeeze(hObj.relEx(x_range, y_range,hObj.freq_num));
                case "reley"
                    out = squeeze(hObj.relEy(x_range, y_range,hObj.freq_num));
                case "relez"
                    out = squeeze(hObj.relEz(x_range, y_range,hObj.freq_num));
                case "hx"
                    out = squeeze(hObj.Hx(x_range, y_range,hObj.freq_num));
                case "hy"
                    out = squeeze(hObj.Hy(x_range, y_range,hObj.freq_num));
                case "hz"
                    out = squeeze(hObj.Hz(x_range, y_range,hObj.freq_num));
                case "relhx"
                    out = squeeze(hObj.relHx(x_range, y_range,hObj.freq_num));
                case "relhy"
                    out = squeeze(hObj.relHy(x_range, y_range,hObj.freq_num));
                case "relhz"
                    out = squeeze(hObj.relHz(x_range, y_range,hObj.freq_num));
                case "poynting"
                    out = squeeze(hObj.Poynting(x_range, y_range,hObj.freq_num));
                case "relpoynting"
                    out = squeeze(hObj.relPoynting(x_range, y_range,hObj.freq_num));
                otherwise
                    error("Unknown field: %s", field);
            end
        end
    end
end


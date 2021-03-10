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
    % farfield.gotoMaxValueFreq() - Go to that frequency for which the sum
    %                               of the farfield Poynting vector over
    %                               all diffraction orders is maximum.
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
    % farfield.trimFarfield(max_diffraction_order) - Trim off all
    %                                   diffraction orders higher than
    %                                   max_diffraction_order on all
    %                                   farfields.
    %
    % farfield.getPoyntingAllFreqs() - returns the farfield Poynting vector
    %                                  for all diffraction orders and all
    %                                  frequencies, not just the current
    %                                  frequency.
    % farfield.getFieldAllFreqs(field) - Get a field for all frequencies.
    %
    % farfield.getFreq() - Get the current frequency.
    % farfield.getAllFreqs() - get a list of all frequencies.
    
    properties (SetAccess='private')
        % where the completed job scripts are stored.
        jobs_dir = 'C:\Users\matthew\MATLAB Drive\COMSOL\jobs\completed\';
        
        % Change the path temprorarily to add these directories where the
        % function scripts are kept.
        COMSOL_dir = {'C:\Users\matthew\MATLAB Drive\COMSOL\', ...
            'C:\Users\matthew\MATLAB Drive\COMSOL\COMSOLd\', ...
            'C:\Users\matthew\MATLAB\Projects\COMSOLd\utils\', ...
            'C:\Users\matthew\MATLAB\Projects\COMSOLd\post_processing\'};
        
        % The options struct defined by the job script.
        options;
       
        c = 299792458;
        epsilon_0 = 8.854187817e-12;
        mu_0 = pi*4e-7;
        
        % Data
        freqs;
        mu_r;
        epsilon_r;
        
        x;
        y;
        
        Ex;
        Ey;
        relEx;
        relEy;
        Ebx;
        Eby;
         
        Hx;
        Hy;
        relHx;
        relHy;
        Hbx;
        Hby;
        
        Poynting;
        relPoynting;
        Poyntingb;
        
        % The Fourier transforms used to calculate the farfield
        F_Ex;
        F_Ey;
        F_Ez;
        F_relEx;
        F_relEy;
        F_relEz;
        F_Ebx;
        F_Eby;
        F_Ebz;
         
        F_Hx;
        F_Hy;
        F_Hz;
        F_relHx;
        F_relHy;
        F_relHz;
        F_Hbx;
        F_Hby;
        F_Hbz;
        
        F_Poynting;
        F_relPoynting;
        F_Poyntingb;
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
        function hObj = COMSOLdFarfield(options, farfield_in, freqs, mu_r, epsilon_r, varargin)
            % Check to see if the user is setting the jobs_dir or
            % COMSOLd_dir variables.
            if nargin > 5 % nargin is the total num of arguments
                hObj.jobs_dir = varargin{1};
                if nargin > 6
                    hObj.COMSOL_dir = varargin{2};
                end
            end
            
            hObj.options = options;
            hObj.freq_num = 1;
            hObj.stepping_through_freqs = false;
            
            hObj.x = farfield_in.x;
            hObj.y = farfield_in.y;
            hObj.freqs = freqs;
            hObj.mu_r = mu_r;
            hObj.epsilon_r = epsilon_r;

            hObj.F_Ex = farfield_in.Ex_ff;
            hObj.F_Ey = farfield_in.Ey_ff;
            hObj.F_Ez = farfield_in.Ez_ff;
            if isfield(farfield_in,"relEx_ff")
                hObj.F_relEx = farfield_in.relEx_ff;
                hObj.F_relEy = farfield_in.relEy_ff;
                hObj.F_relEz = farfield_in.relEz_ff;
            else
                hObj.F_relEx = zeros(size(hObj.F_Ex));
                hObj.F_relEy = zeros(size(hObj.F_Ex));
                hObj.F_relEz = zeros(size(hObj.F_Ex));
            end
            if isfield(farfield_in,"Ebx_ff")
                hObj.F_Ebx = farfield_in.Ebx_ff;
                hObj.F_Eby = farfield_in.Eby_ff;
                hObj.F_Ebz = farfield_in.Ebz_ff;
            else
                hObj.F_Ebx = zeros(size(hObj.F_Ex));
                hObj.F_Eby = zeros(size(hObj.F_Ex));
                hObj.F_Ebz = zeros(size(hObj.F_Ex));
            end

            hObj.F_Hx = farfield_in.Hx_ff;
            hObj.F_Hy = farfield_in.Hy_ff;
            hObj.F_Hz = farfield_in.Hz_ff;
            if isfield(farfield_in,"relHx_ff")
                hObj.F_relHx = farfield_in.relHx_ff;
                hObj.F_relHy = farfield_in.relHy_ff;
                hObj.F_relHz = farfield_in.relHz_ff;
            else
                hObj.F_relHx = zeros(size(hObj.F_Hx));
                hObj.F_relHy = zeros(size(hObj.F_Hx));
                hObj.F_relHz = zeros(size(hObj.F_Hx));
            end
            if isfield(farfield_in,"Hbx_ff")
                hObj.F_Hbx = farfield_in.Hbx_ff;
                hObj.F_Hby = farfield_in.Hby_ff;
                hObj.F_Hbz = farfield_in.Hbz_ff;
            else
                hObj.F_Hbx = zeros(size(hObj.F_Hx));
                hObj.F_Hby = zeros(size(hObj.F_Hx));
                hObj.F_Hbz = zeros(size(hObj.F_Hx));
            end

            hObj.F_Poynting = farfield_in.Poynting;
            if isfield(farfield_in, "relPoynting")
                hObj.F_relPoynting = farfield_in.relPoynting;
            else
                hObj.F_relPoynting = zeros(size(hObj.F_Poynting));
            end
            if isfield(farfield_in, "Poyntingb")
                hObj.F_Poyntingb = farfield_in.Poyntingb;
            else
                hObj.F_Poyntingb = zeros(size(hObj.F_Poynting));
            end
            
            hObj.Ex = zeros(size(hObj.F_Hy));
            hObj.Ey = zeros(size(hObj.F_Hx));
            hObj.relEx = zeros(size(hObj.F_relHy));
            hObj.relEy = zeros(size(hObj.F_relHx));
            hObj.Hx = zeros(size(hObj.F_Ey));
            hObj.Hy = zeros(size(hObj.F_Ex));
            hObj.relHx = zeros(size(hObj.F_relEy));
            hObj.relHy = zeros(size(hObj.F_relEx));
            hObj.Poynting = zeros(size(hObj.Ex));
            hObj.relPoynting = zeros(size(hObj.relEx));
            hObj.Poyntingb = zeros(size(hObj.Poynting));
            
            while hObj.stepThroughFrequencies
                hObj.Ex(:,:,hObj.freq_num) = -1i*hObj.F_Hy(:,:,hObj.freq_num)*...
                    hObj.c*hObj.mu_r(hObj.freq_num)*hObj.mu_0;
                hObj.Ey(:,:,hObj.freq_num) = 1i*hObj.F_Hx(:,:,hObj.freq_num)*...
                    hObj.c*hObj.mu_r(hObj.freq_num)*hObj.mu_0;
                
                hObj.Hx(:,:,hObj.freq_num) = 1i*hObj.F_Ey(:,:,hObj.freq_num)*...
                    hObj.c*hObj.epsilon_r(hObj.freq_num)*hObj.epsilon_0;
                hObj.Hy(:,:,hObj.freq_num) = -1i*hObj.F_Ex(:,:,hObj.freq_num)*...
                    hObj.c*hObj.epsilon_r(hObj.freq_num)*hObj.epsilon_0;
                
                
                hObj.Poynting(:,:,hObj.freq_num) = ...
                    real(hObj.Ex(:,:,hObj.freq_num).*conj(hObj.Hy(:,:,hObj.freq_num)) - ...
                    hObj.Ey(:,:,hObj.freq_num).*conj(hObj.Hx(:,:,hObj.freq_num)))/2;
                
                if isfield(farfield_in, "relPoynting")
                    hObj.relHx(:,:,hObj.freq_num) = -1i*hObj.F_relEy(:,:,hObj.freq_num)*...
                        hObj.c*hObj.epsilon_r(hObj.freq_num)*hObj.epsilon_0;
                    hObj.relHy(:,:,hObj.freq_num) = -1i*hObj.F_relEx(:,:,hObj.freq_num)*...
                        hObj.c*hObj.epsilon_r(hObj.freq_num)*hObj.epsilon_0;
                    hObj.relEx(:,:,hObj.freq_num) = 1i*hObj.F_relHy(:,:,hObj.freq_num)*...
                        hObj.c*hObj.mu_r(hObj.freq_num)*hObj.mu_0;
                    hObj.relEy(:,:,hObj.freq_num) = 1i*hObj.F_relHx(:,:,hObj.freq_num)*...
                        hObj.c*hObj.mu_r(hObj.freq_num)*hObj.mu_0;
                    hObj.relPoynting(:,:,hObj.freq_num) = ...
                        real(hObj.relEx(:,:,hObj.freq_num).*conj(hObj.relHy(:,:,hObj.freq_num)) - ...
                        hObj.relEy(:,:,hObj.freq_num).*conj(hObj.relHx(:,:,hObj.freq_num)))/2;
                end
                if isfield(farfield_in, "Poyntingb")
                    hObj.Ebx(:,:,hObj.freq_num) = 1i*hObj.F_Hy(:,:,hObj.freq_num)*...
                        hObj.c*hObj.mu_r(hObj.freq_num)*hObj.mu_0;
                    hObj.Eby(:,:,hObj.freq_num) = 1i*hObj.F_Hx(:,:,hObj.freq_num)*...
                        hObj.c*hObj.mu_r(hObj.freq_num)*hObj.mu_0;
                    hObj.Hbx(:,:,hObj.freq_num) = -1i*hObj.F_Eby(:,:,hObj.freq_num)*...
                        hObj.c*hObj.epsilon_r(hObj.freq_num)*hObj.epsilon_0;
                    hObj.Hby(:,:,hObj.freq_num) = -1i*hObj.F_Ebx(:,:,hObj.freq_num)*...
                        hObj.c*hObj.epsilon_r(hObj.freq_num)*hObj.epsilon_0;
                    hObj.Poyntingb(:,:,hObj.freq_num) = ...
                        real(hObj.Ebx(:,:,hObj.freq_num).*conj(hObj.Hby(:,:,hObj.freq_num)) - ...
                        hObj.Eby(:,:,hObj.freq_num).*conj(hObj.Hbx(:,:,hObj.freq_num)))/2;
                end
            end
            hObj.firstFreq;
        
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
        
        % Move to study with maximum sum of values of the Poynting vector.
        function gotoMaxValueFreq(hObj)
            %all_freqs = squeeze(sum(sum(hObj.Poynting)));
            
            % If even number of elements in each direction, assuming it is
            % square
            if rem(size(hObj.Ex, 1), 2) == 0
                zeroth_order_ind = size(hObj.Ex, 1)/2+1;
            else % odd
                zeroth_order_ind = ceil(size(hObj.Ex, 1)/2);
            end
            
            all_freqs = abs(squeeze(hObj.F_Poynting(zeroth_order_ind,zeroth_order_ind,:)));
            
            [~,max_ind] = max(all_freqs);
            hObj.setFreq(max_ind);
        end
        
        %%
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
                case "relex"
                    out = squeeze(hObj.relEx(:,:,hObj.freq_num));
                case "reley"
                    out = squeeze(hObj.relEy(:,:,hObj.freq_num));
                case "ebx"
                    out = squeeze(hObj.Ebx(:,:,hObj.freq_num));
                case "eby"
                    out = squeeze(hObj.Eby(:,:,hObj.freq_num));
                case "hx"
                    out = squeeze(hObj.Hx(:,:,hObj.freq_num));
                case "hy"
                    out = squeeze(hObj.Hy(:,:,hObj.freq_num));
                case "relhx"
                    out = squeeze(hObj.relHx(:,:,hObj.freq_num));
                case "relhy"
                    out = squeeze(hObj.relHy(:,:,hObj.freq_num));
                case "hbx"
                    out = squeeze(hObj.Hbx(:,:,hObj.freq_num));
                case "hby"
                    out = squeeze(hObj.Hby(:,:,hObj.freq_num));
                case "poynting"
                    out = squeeze(hObj.Poynting(:,:,hObj.freq_num));
                case "relpoynting"
                    out = squeeze(hObj.relPoynting(:,:,hObj.freq_num));
                case "poyntingb"
                    out = squeeze(hObj.Poyntingb(:,:,hObj.freq_num));
                case "f_ex"
                    out = squeeze(hObj.F_Ex(:,:,hObj.freq_num));
                case "f_ey"
                    out = squeeze(hObj.F_Ey(:,:,hObj.freq_num));
                case "f_ez"
                    out = squeeze(hObj.F_Ez(:,:,hObj.freq_num));
                case "f_relex"
                    out = squeeze(hObj.F_relEx(:,:,hObj.freq_num));
                case "f_reley"
                    out = squeeze(hObj.F_relEy(:,:,hObj.freq_num));
                case "f_relez"
                    out = squeeze(hObj.F_relEz(:,:,hObj.freq_num));
                case "f_ebx"
                    out = squeeze(hObj.F_Ebx(:,:,hObj.freq_num));
                case "f_eby"
                    out = squeeze(hObj.F_Eby(:,:,hObj.freq_num));
                case "f_ebz"
                    out = squeeze(hObj.F_Ebz(:,:,hObj.freq_num));
                case "f_hx"
                    out = squeeze(hObj.F_Hx(:,:,hObj.freq_num));
                case "f_hy"
                    out = squeeze(hObj.F_Hy(:,:,hObj.freq_num));
                case "f_hz"
                    out = squeeze(hObj.F_Hz(:,:,hObj.freq_num));
                case "f_relhx"
                    out = squeeze(hObj.F_relHx(:,:,hObj.freq_num));
                case "f_relhy"
                    out = squeeze(hObj.F_relHy(:,:,hObj.freq_num));
                case "f_relhz"
                    out = squeeze(hObj.F_relHz(:,:,hObj.freq_num));
                case "f_hbx"
                    out = squeeze(hObj.F_Hbx(:,:,hObj.freq_num));
                case "f_hby"
                    out = squeeze(hObj.F_Hby(:,:,hObj.freq_num));
                case "f_hbz"
                    out = squeeze(hObj.F_Hbz(:,:,hObj.freq_num));
                case "f_poynting"
                    out = squeeze(hObj.F_Poynting(:,:,hObj.freq_num));
                case "f_relpoynting"
                    out = squeeze(hObj.F_relPoynting(:,:,hObj.freq_num));
                case "f_poyntingb"
                    out = squeeze(hObj.F_Poyntingb(:,:,hObj.freq_num));
                otherwise
                    error("Unknown field: %s", field);
            end
        end
        
        % get a subsection of the field at the current frequency
        function out = getPartField(hObj, field, x_range, y_range)
            switch lower(field)
                case "ex"
                    out = squeeze(hObj.Ex(x_range, y_range, hObj.freq_num));
                case "ey"
                    out = squeeze(hObj.Ey(x_range, y_range, hObj.freq_num));
                case "relex"
                    out = squeeze(hObj.relEx(x_range, y_range, hObj.freq_num));
                case "reley"
                    out = squeeze(hObj.relEy(x_range, y_range, hObj.freq_num));
                case "hx"
                    out = squeeze(hObj.Hx(x_range, y_range, hObj.freq_num));
                case "hy"
                    out = squeeze(hObj.Hy(x_range, y_range, hObj.freq_num));
                case "relhx"
                    out = squeeze(hObj.relHx(x_range, y_range, hObj.freq_num));
                case "relhy"
                    out = squeeze(hObj.relHy(x_range, y_range, hObj.freq_num));
                case "poynting"
                    out = squeeze(hObj.Poynting(x_range, y_range, hObj.freq_num));
                case "relpoynting"
                    out = squeeze(hObj.relPoynting(x_range, y_range, hObj.freq_num));
                case "poyntingb"
                    out = squeeze(hObj.Poyntingb(x_range, y_range, hObj.freq_num));
                case "f_ex"
                    out = squeeze(hObj.F_Ex(x_range, y_range,hObj.freq_num));
                case "f_ey"
                    out = squeeze(hObj.F_Ey(x_range, y_range,hObj.freq_num));
                case "f_ez"
                    out = squeeze(hObj.F_Ez(x_range, y_range,hObj.freq_num));
                case "f_relex"
                    out = squeeze(hObj.F_relEx(x_range, y_range,hObj.freq_num));
                case "f_reley"
                    out = squeeze(hObj.F_relEy(x_range, y_range,hObj.freq_num));
                case "f_relez"
                    out = squeeze(hObj.F_relEz(x_range, y_range,hObj.freq_num));
                case "f_ebx"
                    out = squeeze(hObj.F_Ebx(x_range, y_range,hObj.freq_num));
                case "f_eby"
                    out = squeeze(hObj.F_Eby(x_range, y_range,hObj.freq_num));
                case "f_ebz"
                    out = squeeze(hObj.F_Ebz(x_range, y_range,hObj.freq_num));
                case "f_hx"
                    out = squeeze(hObj.F_Hx(x_range, y_range,hObj.freq_num));
                case "f_hy"
                    out = squeeze(hObj.F_Hy(x_range, y_range,hObj.freq_num));
                case "f_hz"
                    out = squeeze(hObj.F_Hz(x_range, y_range,hObj.freq_num));
                case "f_relhx"
                    out = squeeze(hObj.F_relHx(x_range, y_range,hObj.freq_num));
                case "f_relhy"
                    out = squeeze(hObj.F_relHy(x_range, y_range,hObj.freq_num));
                case "f_relhz"
                    out = squeeze(hObj.F_relHz(x_range, y_range,hObj.freq_num));
                case "f_hbx"
                    out = squeeze(hObj.F_Hbx(x_range, y_range,hObj.freq_num));
                case "f_hby"
                    out = squeeze(hObj.F_Hby(x_range, y_range,hObj.freq_num));
                case "f_hbz"
                    out = squeeze(hObj.F_Hbz(x_range, y_range,hObj.freq_num));
                case "f_poynting"
                    out = squeeze(hObj.F_Poynting(x_range, y_range,hObj.freq_num));
                case "f_relpoynting"
                    out = squeeze(hObj.F_relPoynting(x_range, y_range,hObj.freq_num));
                case "f_poyntingb"
                    out = squeeze(hObj.F_Poyntingb(:,:,hObj.freq_num));
                otherwise
                    error("Unknown field: %s", field);
            end
        end
        
        % Get the sum of all diffraction orders for all frequencies
        function out = getPoyntingAllFreqs(hObj)
            out = hObj.F_Poynting;
        end
        
        function out = getFieldAllFreqs(hObj, field)
            switch lower(field)
                case "ex"
                    out = hObj.Ex;
                case "ey"
                    out = hObj.Ey;
                case "relex"
                    out = hObj.relEx;
                case "reley"
                    out = hObj.relEy;
                case "hx"
                    out = hObj.Hx;
                case "hy"
                    out = hObj.Hy;
                case "relhx"
                    out = hObj.relHx;
                case "relhy"
                    out = hObj.relHy;
                case "poynting"
                    out = hObj.Poynting;
                case "relpoynting"
                    out = hObj.relPoynting;
                case "poyntingb"
                    out = hObj.Poyntingb;
                case "f_ex"
                    out = hObj.F_Ex;
                case "f_ey"
                    out = hObj.F_Ey;
                case "f_ez"
                    out = hObj.F_Ez;
                case "f_relex"
                    out = hObj.F_relEx;
                case "f_reley"
                    out = hObj.F_relEy;
                case "f_relez"
                    out = hObj.F_relEz;
                case "f_ebx"
                    out = hObj.F_Ebx;
                case "f_eby"
                    out = hObj.F_Eby;
                case "f_ebz"
                    out = hObj.F_Ebz;
                case "f_hx"
                    out = hObj.F_Hx;
                case "f_hy"
                    out = hObj.F_Hy;
                case "f_hz"
                    out = hObj.F_Hz;
                case "f_relhx"
                    out = hObj.F_relHx;
                case "f_relhy"
                    out = hObj.F_relHy;
                case "f_relhz"
                    out = hObj.F_relHz;
                case "f_hbx"
                    out = hObj.F_Hbx;
                case "f_hby"
                    out = hObj.F_Hby;
                case "f_hbz"
                    out = hObj.F_Hbz;
                case "f_poynting"
                    out = hObj.F_Poynting;
                case "f_relpoynting"
                    out = hObj.F_relPoynting;
                case "f_poyntingb"
                    out = hObj.F_Poyntingb;
                otherwise
                    error("Unknown field: %s", field);
            end
        end
        
        function out = getFreq(hObj)
            out = hObj.freqs(hObj.freq_num);
        end
        
        function out = getAllFreqs(hObj)
            out = hObj.freqs;
        end
        
        % Trim the farfields so that only the diffractions orders remain.
        % Must pass maximum diffraction order since we can't work out what
        % it would be from the data.
        function trimFarfield(hObj, max_diffraction_order)
            
            zeroth_order_ind = size(hObj.Ex, 1)/2+1;
            diff_order_range = (zeroth_order_ind-max_diffraction_order:zeroth_order_ind+max_diffraction_order);
            
            % We squeeze the fields in case the user requests only the
            % zeroth order, so that two of the dimensions of the matices
            % are not being used.
            hObj.Ex = squeeze(hObj.Ex(diff_order_range,diff_order_range,:));
            hObj.Ey = squeeze(hObj.Ey(diff_order_range,diff_order_range,:));
            hObj.F_Ex = squeeze(hObj.F_Ex(diff_order_range,diff_order_range,:));
            hObj.F_Ey = squeeze(hObj.F_Ey(diff_order_range,diff_order_range,:));
            hObj.F_Ez = squeeze(hObj.F_Ez(diff_order_range,diff_order_range,:));
            hObj.relEx = squeeze(hObj.relEx(diff_order_range,diff_order_range,:));
            hObj.relEy = squeeze(hObj.relEy(diff_order_range,diff_order_range,:));
            hObj.F_relEx = squeeze(hObj.F_relEx(diff_order_range,diff_order_range,:));
            hObj.F_relEy = squeeze(hObj.F_relEy(diff_order_range,diff_order_range,:));
            hObj.F_relEz = squeeze(hObj.F_relEz(diff_order_range,diff_order_range,:));
            
            hObj.Hx = squeeze(hObj.Hx(diff_order_range,diff_order_range,:));
            hObj.Hy = squeeze(hObj.Hy(diff_order_range,diff_order_range,:));
            hObj.F_Hx = squeeze(hObj.F_Hx(diff_order_range,diff_order_range,:));
            hObj.F_Hy = squeeze(hObj.F_Hy(diff_order_range,diff_order_range,:));
            hObj.F_Hz = squeeze(hObj.F_Hz(diff_order_range,diff_order_range,:));
            hObj.relHx = squeeze(hObj.relHx(diff_order_range,diff_order_range,:));
            hObj.relHy = squeeze(hObj.relHy(diff_order_range,diff_order_range,:));
            hObj.F_relHx = squeeze(hObj.F_relHx(diff_order_range,diff_order_range,:));
            hObj.F_relHy = squeeze(hObj.F_relHy(diff_order_range,diff_order_range,:));
            hObj.F_relHz = squeeze(hObj.F_relHz(diff_order_range,diff_order_range,:));
            
            hObj.Poynting = squeeze(hObj.Poynting(diff_order_range,diff_order_range,:));
            hObj.relPoynting = squeeze(hObj.relPoynting(diff_order_range,diff_order_range,:));
            hObj.Poyntingb = squeeze(hObj.Poyntingb(diff_order_range,diff_order_range,:));
            hObj.F_Poynting = squeeze(hObj.F_Poynting(diff_order_range,diff_order_range,:));
            hObj.F_relPoynting = squeeze(hObj.F_relPoynting(diff_order_range,diff_order_range,:));
            hObj.F_Poyntingb = squeeze(hObj.F_Poyntingb(diff_order_range,diff_order_range,:));
        
        end
    end
end


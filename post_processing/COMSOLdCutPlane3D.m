classdef COMSOLdCutPlane3D < handle
    % COMSOLdCutPlane - cut planes saved from COMSOLd job.
    %
    % This object is generated by a COMSOLdResults object via the
    % getCutPlane method.
    %
    % Because there is a seperate cut plane for each frequency in the study
    % this class only presents a single cut plane at a time.  Like with
    % the COMSOLdResults class you can step through the frequencies with
    % similar methods as explained in that class file.
    %
    % Data is accessed through the getField method:
    %
    % cut_plane.getField("Ex")
    %
    % for example returns and array of the x component of the E field at  
    % the current frequency, and so on. Obviously you need to modify this 
    % class file to match the cut plane files that your comsol file 
    % outputs.
    %
    % The method
    %
    % cut_plane.getPartField("Ex", x_range, y_range)
    %
    % returns only a portion of the cut plane, with x_range and y_range
    % being indexes into the array.
    %
    % cut_plane.getFieldAllFreqs(field) - return the field at all
    %                                     frequencies, not just the current
    %                                     one.
    %
    % cut_plane.getdx(), cut_plane.getdy() - Assuming the cut plane was
    %                       taken over a regular grid, returns the spacing
    %                       between each x or y value.
    %
    
    properties (SetAccess='private')
       
        % Data
        x;
        y;
        z;
        
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
        
        Poynting;
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
        function hObj = COMSOLdCutPlane3D(cut_plane_in)
            hObj.freq_num = 1;
            hObj.stepping_through_freqs = false;
            if isempty(cut_plane_in)
                hObj.x = [];
                hObj.y = [];
                hObj.z = [];

                hObj.Ex = [];
                hObj.Ey = [];
                hObj.Ez = [];
                hObj.relEx = [];
                hObj.relEy = [];
                hObj.relEz = [];

                hObj.Hx = [];
                hObj.Hy = [];
                hObj.Hz = [];
                hObj.relHx = [];
                hObj.relHy = [];
                hObj.relHz = [];

                hObj.Poynting = [];
                hObj.relPoynting = [];
            else

                hObj.x = cut_plane_in{1}.cut_plane.x;
                hObj.y = cut_plane_in{1}.cut_plane.y;
                hObj.z = cut_plane_in{1}.cut_plane.z;

                % Assume that the fields come in the order of x, y, z.
                hObj.Ex = reshape(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(1))), ...
                    [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                    size(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(1))), 2)]);
                hObj.Ey = reshape(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(2))), ...
                    [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                    size(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(1))), 2)]);
                hObj.Ez = reshape(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(3))), ...
                    [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                    size(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(1))), 2)]);
                if length(cut_plane_in{1}.cut_plane.fields) == 6
                    hObj.relEx = reshape(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(4))), ...
                        [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                        size(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(4))), 2)]);
                    hObj.relEy = reshape(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(5))), ...
                        [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                        size(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(4))), 2)]);
                    hObj.relEz = reshape(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(6))), ...
                        [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                        size(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(4))), 2)]);
                else
                    hObj.relEx = zeros(size(hObj.Ex));
                    hObj.relEy = zeros(size(hObj.Ey));
                    hObj.relEz = zeros(size(hObj.Ez));
                end

                hObj.Hx = reshape(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(1))), ...
                    [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                    size(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(1))), 2)]);
                hObj.Hy = reshape(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(2))), ...
                    [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                    size(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(1))), 2)]);
                hObj.Hz = reshape(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(3))), ...
                    [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                    size(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(1))), 2)]);
                if length(cut_plane_in{1}.cut_plane.fields) == 6
                    hObj.relHx = reshape(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(4))), ...
                        [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                        size(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(4))), 2)]);
                    hObj.relHy = reshape(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(5))), ...
                        [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                        size(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(4))), 2)]);
                    hObj.relHz = reshape(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(6))), ...
                        [length(unique(hObj.x)) length(unique(hObj.y)) length(unique(hObj.z)) ...
                        size(cut_plane_in{2}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{2}.cut_plane.fields(4))), 2)]);
                else
                    hObj.relHx = zeros(size(hObj.Hx));
                    hObj.relHy = zeros(size(hObj.Hy));
                    hObj.relHz = zeros(size(hObj.Hz));
                end

                for i=1:size(hObj.Ex, 4)
                    ffex = squeeze(hObj.Ex(:,:,:,i));
                    ffey = squeeze(hObj.Ey(:,:,:,i));
                    ffhx = squeeze(hObj.Hx(:,:,:,i));
                    ffhy = squeeze(hObj.Hy(:,:,:,i));
                    hObj.Poynting(:,:,:,i) = real(ffex.*conj(ffhy)-ffey.*conj(ffhx))/2;
                    ffex = squeeze(hObj.relEx(:,:,:,i));
                    ffey = squeeze(hObj.relEy(:,:,:,i));
                    ffhx = squeeze(hObj.relHx(:,:,:,i));
                    ffhy = squeeze(hObj.relHy(:,:,:,i));
                    hObj.relPoynting(:,:,:,i) = real(ffex.*conj(ffhy)-ffey.*conj(ffhx))/2;
                end
            end
        end
      
        %%
        % 
        % Methods to access data
        %
        
        
        % How many freqs are there?
        %
        function out = numFreqs(hObj)
            out = size(hObj.Ex, 4);
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

        %%
        function out = getdx(hObj)
            unique_x = unique(hObj.x);
            out = abs(unique_x(1) - unique_x(2));
        end
        
        function out = getdy(hObj)
            unique_y = unique(hObj.y);
            out = abs(unique_y(1) - unique_y(2));
        end
        
        function out = getdz(hObj)
            unique_z = unique(hObj.z);
            out = abs(unique_z(1) - unique_z(2));
        end
        
        % Only get a field at current frequency
        function out = getField(hObj, field)
            
            switch lower(field)
                case "ex"
                    out = squeeze(hObj.Ex(:,:,:,hObj.freq_num));
                case "ey"
                    out = squeeze(hObj.Ey(:,:,:,hObj.freq_num));
                case "ez"
                    out = squeeze(hObj.Ez(:,:,:,hObj.freq_num));
                case "relex"
                    out = squeeze(hObj.relEx(:,:,:,hObj.freq_num));
                case "reley"
                    out = squeeze(hObj.relEy(:,:,:,hObj.freq_num));
                case "relez"
                    out = squeeze(hObj.relEz(:,:,:,hObj.freq_num));
                case "hx"
                    out = squeeze(hObj.Hx(:,:,:,hObj.freq_num));
                case "hy"
                    out = squeeze(hObj.Hy(:,:,:,hObj.freq_num));
                case "hz"
                    out = squeeze(hObj.Hz(:,:,:,hObj.freq_num));
                case "relhx"
                    out = squeeze(hObj.relHx(:,:,:,hObj.freq_num));
                case "relhy"
                    out = squeeze(hObj.relHy(:,:,:,hObj.freq_num));
                case "relhz"
                    out = squeeze(hObj.relHz(:,:,:,hObj.freq_num));
                case "poynting" 
                    out = squeeze(hObj.Poynting(:,:,:,hObj.freq_num));
                case "relpoynting"
                    out = squeeze(hObj.relPoynting(:,:,:,hObj.freq_num));
                otherwise
                    error("Unknown field: %s", field);
            end
        end
        
        % Only get a field at current frequency
        function out = getFieldAllFreqs(hObj, field)
            
            switch lower(field)
                case "ex"
                    out = hObj.Ex;
                case "ey"
                    out = hObj.Ey;
                case "ez"
                    out = hObj.Ez;
                case "relex"
                    out = hObj.relEx;
                case "reley"
                    out = hObj.relEy;
                case "relez"
                    out = hObj.relEz;
                case "hx"
                    out = hObj.Hx;
                case "hy"
                    out = hObj.Hy;
                case "hz"
                    out = hObj.Hz;
                case "relhx"
                    out = hObj.relHx;
                case "relhy"
                    out = hObj.relHy;
                case "relhz"
                    out = hObj.relHz;
                case "poynting" 
                    out = hObj.Poynting;
                case "relpoynting"
                    out = hObj.relPoynting;
                otherwise
                    error("Unknown field: %s", field);
            end
        end
        
        % get a subsection of the field at current frequency
        function out = getPartField(hObj, field, x_range, y_range, z_range)
            switch lower(field)
                case "ex"
                    out = squeeze(hObj.Ex(x_range, y_range, z_range,hObj.freq_num));
                case "ey"
                    out = squeeze(hObj.Ey(x_range, y_range, z_range,hObj.freq_num));
                case "ez"
                    out = squeeze(hObj.Ez(x_range, y_range, z_range,hObj.freq_num));
                case "relex"
                    out = squeeze(hObj.relEx(x_range, y_range, z_range,hObj.freq_num));
                case "reley"
                    out = squeeze(hObj.relEy(x_range, y_range, z_range,hObj.freq_num));
                case "relez"
                    out = squeeze(hObj.relEz(x_range, y_range, z_range,hObj.freq_num));
                case "hx"
                    out = squeeze(hObj.Hx(x_range, y_range, z_range,hObj.freq_num));
                case "hy"
                    out = squeeze(hObj.Hy(x_range, y_range, z_range,hObj.freq_num));
                case "hz"
                    out = squeeze(hObj.Hz(x_range, y_range, z_range,hObj.freq_num));
                case "relhx"
                    out = squeeze(hObj.relHx(x_range, y_range, z_range,hObj.freq_num));
                case "relhy"
                    out = squeeze(hObj.relHy(x_range, y_range, z_range,hObj.freq_num));
                case "relhz"
                    out = squeeze(hObj.relHz(x_range, y_range, z_range,hObj.freq_num));
                case "poynting"
                    out = squeeze(hObj.Poynting(x_range, y_range, z_range,hObj.freq_num));
                case "relpoynting"
                    out = squeeze(hObj.relPoynting(x_range, y_range, z_range,hObj.freq_num));
                otherwise
                    error("Unknown field: %s", field);
            end
        end

        function out = createMaskedCutPlane(hObj, mask)
            out = COMSOLdCutPlane([]);
            for p =  properties(hObj).'  %copy all public properties
                try   %may fail if property is read-only
                    out.(p{1}) = hObj.(p{1});
                catch
                    warning('failed to copy property: %s', p{1});
                end
            end
            out.setMask(mask);
        end

        function setMask(hObj, mask)
            if ~isempty(hObj.Ex)
                hObj.Ex = hObj.Ex(:,:,:,mask);
            end
            if ~isempty(hObj.Ey)
                hObj.Ey = hObj.Ey(:,:,:,mask);
            end
            if ~isempty(hObj.Ez)
                hObj.Ez = hObj.Ez(:,:,:,mask);
            end
            if ~isempty(hObj.relEx)
                hObj.relEx = hObj.relEx(:,:,:,mask);
            end
            if ~isempty(hObj.relEy)
                hObj.relEy = hObj.relEy(:,:,:,mask);
            end
            if ~isempty(hObj.relEz)
                hObj.relEz = hObj.relEz(:,:,:,mask);
            end
            if ~isempty(hObj.Hx)
                hObj.Hx = hObj.Hx(:,:,:,mask);
            end
            if ~isempty(hObj.Hy)
                hObj.Hy = hObj.Hy(:,:,:,mask);
            end
            if ~isempty(hObj.Hz)
                hObj.Hz = hObj.Hz(:,:,:,mask);
            end
            if ~isempty(hObj.relHx)
                hObj.relHx = hObj.relHx(:,:,:,mask);
            end
            if ~isempty(hObj.relHy)
                hObj.relHy = hObj.relHy(:,:,:,mask);
            end
            if ~isempty(hObj.relHz)
                hObj.relHz = hObj.relHz(:,:,:,mask);
            end
            if ~isempty(hObj.Poynting)
                hObj.Poynting = hObj.Poynting(:,:,:,mask);
            end
            if ~isempty(hObj.relPoynting)
                hObj.relPoynting = hObj.relPoynting(:,:,:,mask);
            end

            % Which frequency are we looking at
            hObj.freq_num = 1;

            % Whether we are stepping through frequencies
            hObj.stepping_through_freqs = false;
        end
    end
end


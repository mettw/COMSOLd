classdef COMSOLdScalarCutPlane < handle
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
        
        fn;
        
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
        function hObj = COMSOLdScalarCutPlane(cut_plane_in)
            hObj.freq_num = 1;
            hObj.stepping_through_freqs = false;
            if isempty(cut_plane_in)
                hObj.x = [];
                hObj.y = [];

                hObj.fn = [];
            else

                hObj.x = cut_plane_in{1}.cut_plane.x;
                hObj.y = cut_plane_in{1}.cut_plane.y;

                % Assume that the fields come in the order of x, y, z.
                hObj.fn = reshape(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(1))), ...
                    [length(unique(hObj.x)) length(unique(hObj.y)) ...
                    size(cut_plane_in{1}.cut_plane.(matlab.lang.makeValidName(cut_plane_in{1}.cut_plane.fields(1))), 2)]);                

            end
        end
      
        %%
        % 
        % Methods to access data
        %
        
        
        % How many freqs are there?
        %
        function out = numFreqs(hObj)
            out = size(hObj.fn, 3);
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
        
        % Only get a field at current frequency
        function out = getField(hObj)
            
            out = squeeze(hObj.fn(:,:,hObj.freq_num));
        end
        
        % Only get a field at current frequency
        function out = getFieldAllFreqs(hObj)
            
            out = hObj.fn;
        end
        
        % get a subsection of the field at current frequency
        function out = getPartField(hObj, x_range, y_range)

            out = squeeze(hObj.fn(x_range, y_range,hObj.freq_num));
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
            if ~isempty(hObj.fn)
                hObj.fn = hObj.fn(:,:,mask);
            end

            % Which frequency are we looking at
            hObj.freq_num = 1;

            % Whether we are stepping through frequencies
            hObj.stepping_through_freqs = false;
        end
    end
end


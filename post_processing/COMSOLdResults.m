classdef COMSOLdResults < handle
    % COMSOLdResults - Front end to results from a COMSOLd job.
    %
    % The output from a COMSOLd job is spread across a number of files and
    % some of it, because of its size, is only converted into matlab files
    % when requested by the user.  This object is designed to make
    % accessing all of this data as convenient as possible.
    %
    % To use this you first need to change the properties:
    %
    % jobs_dir      Where completed job scripts are stored on your
    %               computer.  All subdirectories of this one are searched
    %               for the job script.
    % COMSOL_dir    All of the directories where these class files are, as
    %               well as any functions that they use.
    %
    % You then create a results object with
    %
    % > results = COMSOLdResults("some_job_script");
    %
    % NAVIGATING STUDIES
    % ------------------
    %
    % A sweep is made up of a number of different studies, and a non-sweep
    % job is treated like a sweep of just one study.  You can see a list of
    % all studies in a sweep by looking at the table
    %
    % results.showSweep()
    %
    % which is null for a non-sweep study.  At any given time the
    % results object is only presenting the data from a single study within
    % the sweep.  You can change which study is being presented with the
    % following methods:
    %
    % results.setStudy(study_num) - Move to study number study_num in the
    %                               sequence listed in results.sweep_data
    % results.firstStudy()
    % results.lastStudy()
    % results.nextStudy()
    % results.previousStudy()
    %
    % To avoid generating errors by trying to access a study that does not
    % exist you should make use of the following methods
    %
    % results.getStudyNum()    - The number of the current study
    % results.numStudies()     - The maximum value that can be passed to
    %                            setStudy()
    % results.moreStudies()    - Are there any more studies after the
    %                            current one? (Boolean)
    % results.earlierStudies() - Are there any studies before the current
    %                            one? (Boolean)
    %
    % In general though, you will want to step through the studies one at a
    % time, which you can do with the convenience method
    %
    % while results.stepThroughStudies()
    %   some code...
    % end
    %
    % This loop will start at the first study and then step through all of
    % them one at a time.
    %
    % ACCESSING DATA
    % --------------
    %
    % Output from any derived values nodes in your MPH file can be
    % accessed from the 'derived_values' property.  For example, if you
    % ouput a derived values node to the file 'my_parameters.txt' and it
    % containded the value `height', then all of the values for `height'
    % (one for each frequency in the study) can be accessed as an array
    % with:
    %
    % results.derived_values.my_parameters.height
    %
    % Cut planes and farfields have their own objects for handling the data
    % and these can be generated with:
    %
    % cut_plane = results.getCutPlane(study, direction)
    %
    % where study is either "sfg" or "signal" and direction is either "up"
    % or "down".  The code here is not perfectly general, but is designed
    % for how I happen to output the cut planes.  `cut_plane' is a
    % COMSOLdCutPlane object.  Likewise,
    %
    % farfield = results.getFarfield(study, direction)
    % 
    % produces a COMSOLdFarfield object.
    %
    % SUBSTUDIES
    % ----------
    %
    % With a large sweep you will only want to process a subset of the data
    % at a time and you can do this by creating a new COMSOLdResults object
    % from the current one with
    %
    % sub_results = results.getSubResults(parameter_name, parameter_value)
    %
    % For example, we might have a sweep of
    %
    % > results.showSweep()
    %
    %      theta       phi_pol     DerivedValues     CutPlanes       Farfield  
    %    _________    _________    _____________    ___________    ____________
    %
    %    "0[deg]"     "0[deg]"     {1×1 struct}     {4×7 table}    {1×1 struct}
    %    "0[deg]"     "90[deg]"    {1×1 struct}     {4×7 table}    {1×1 struct}
    %    "8[deg]"     "0[deg]"     {1×1 struct}     {4×7 table}    {1×1 struct}
    %    "8[deg]"     "90[deg]"    {1×1 struct}     {4×7 table}    {1×1 struct}
    %
    % where 'phi_pol' refers to the polarisation of the input beam.  We
    % only want to process one polarisation at a time, which we can do by
    % using the method
    %
    % > results_H = results.getSubResults('phi_pol', '0[deg]');
    %
    % which is a new COMSOLdResults object which only contains the studies
    % with 'phi_pol' equal to '0[deg]'.
    %
    % > results_H.showSweep()
    %
    %      theta      DerivedValues     CutPlanes       Farfield  
    %    _________    _____________    ___________    ____________
    %
    %    "0[deg]"     {1×1 struct}     {4×7 table}    {1×1 struct}
    %    "8[deg]"     {1×1 struct}     {4×7 table}    {1×1 struct}
    %
    % To avoid generating errors you will need to use the following
    % methods:
    %
    % results.getNumParams()
    % results.isParam(name)
    % results.getParamName(num)
    % results.getAllParamNames()
    % results.getParamValue(num)
    % results.getAllParamValues(num)
    %
    % OTHER METHODS
    % -------------
    %
    % results.getJobDir()       - Returns the directory where the data for
    %                             the whole job is stored.
    % results.getStudyDir()     - Returns the directory where the data for
    %                             the current study is stored.
    % results.getParamsString() - Returns all of the parameter values for
    %                             the current study as a sting like:
    %                             "theta = 10[deg] width = 200[nm]"
    %                             This is for giving titles to plots.
    %
    
    properties
        % Allow user to attatch random data to the object.
        extra_data;
    end
    
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
        
        % struct containing all of the derived values that were saved.
        derived_values;
        % derived_values that have been masked to return only those
        % corresponding to certain values for the inner sweep.
        mask = [];
        masked_derived_values;
        
        % cut planes 
        cut_planes;
        
        % Farfields calculated from the cut planes
        farfield;
        
        % The table specifying a sweep
        sweep_data;
    end
    
    properties (GetAccess='private', SetAccess='private')
        % Which study in the sweep we are accessing at the moment
        study_num;
        
        % Are we stepping through the studies with stepThroughStudies()?
        stepping_through_studies;
    end
    
    methods
        %%
        %
        % SETUP functions
        %
        function hObj = COMSOLdResults(job, varargin)
            % Check to see if the user is setting the jobs_dir or
            % COMSOLd_dir variables.
            sweep_num = 0;
            if nargin > 1 % nargin is the total num of arguments
                hObj.jobs_dir = varargin{1};
                if nargin > 2
                    hObj.COMSOL_dir = varargin{2};
                    if nargin > 3
                        sweep_num = varargin{3};
                    end
                end
            end
            
            % If the user wants an empty object
            if strlength(job) == 0
                hObj.study_num = 1;
                hObj.stepping_through_studies = false;
            else
                % Look for job scripts in any subdirectory of hObj.jobs_dir
                old_path = addpath(genpath(hObj.jobs_dir));
                % Where to look for functions used, including user supplied
                % functions.
                for i=1:length(hObj.COMSOL_dir)
                    addpath(hObj.COMSOL_dir{i});
                end

                % The job load the variable 'options'
                eval(job);
                %{
                if exist(strcat(options.output_dir_final, "\options.mat"), 'file') %#ok<NODEF>
                    load(strcat(options.output_dir_final, "\options.mat"), 'options_3');
                    options.parameters = options_3.parameters;
                    options.studies = options_3.studies;
                    options.derived_values = options_3.derived_values;
                    options.export = options_3.export;
                end
                %}
                hObj.options = options;

                hObj.study_num = 1;
                hObj.stepping_through_studies = false;

                if sweep_num ~= 0
                    % If we are still in the middle of a sweep and only
                    % want to load data for this study.
                    hObj.options.output_dir = options.sweep_output_dirs(sweep_num);
                    hObj.options.output_dir_final = options.sweep_output_dirs_final(sweep_num);
                    hObj.options.sweep_output_dirs = '';
                    hObj.options.sweep_output_dirs_final = '';
                    ParameterName = "";
                    Value = "";
                    hObj.options.sweep = table(ParameterName, Value);
                end    
                
                if ~isempty(hObj.options.sweep_output_dirs)  ...
                        && strlength(hObj.options.sweep_output_dirs) ~= 0
                    % If this is a sweep then load sweep_data
                    tmp = load(strcat(hObj.options.output_dir_final, 'sweep_data'));
                    hObj.sweep_data = tmp.sweep_data;
                    hObj.firstStudy();
                else
                    % else this is a single study.
                    tmp = load(strcat(hObj.options.output_dir_final, 'all_derived_values'));
                    hObj.derived_values = tmp.all_derived_values;
                    hObj.setMask(hObj.mask);
                    if exist(strcat(hObj.options.output_dir_final, 'cut_planes_tbl.mat'), 'file')
                        tmp = load(strcat(hObj.options.output_dir_final, 'cut_planes_tbl'));
                        hObj.cut_planes = tmp.cut_planes_tbl;
                    else
                        hObj.cut_planes = [];
                    end
                    if exist(strcat(hObj.options.output_dir_final, 'all_farfields.mat'), 'file')
                        tmp = load(strcat(hObj.options.output_dir_final, 'all_farfields'));
                        hObj.farfield = tmp.all_farfields;
                    else
                        hObj.farfield = [];
                    end
                end

                % Don't modify the user's path
                path(old_path);
            end
        end
      
        %%
        %
        % Navigating a sweep
        %
        
        % How many studies are there?
        %
        % I don't think that I should really treat sweeps and single
        % studies differently, as this just makes handling the data more
        % difficult.  I will therefore treat a single study as a sweep with
        % a single entry.
        function out = numStudies(hObj)
            % If it is not a sweep study
            if isempty(hObj.options.sweep_output_dirs)
                out = 1;
            else
                out = height(hObj.sweep_data);
            end
        end
        
        % What is the number of the current study?
        %
        function out = getStudyNum(hObj)
            out = hObj.study_num;
        end
        
        % Is there another study in the sweep?
        %
        function out = moreStudies(hObj)
            % If it is not a sweep study
            if isempty(hObj.options.sweep_output_dirs)
                out = false;
                return;
            end
            
            % If we are on the last study, so there is no next study
            if hObj.study_num == height(hObj.sweep_data)
                out = false;
            else
                out = true;
            end
        end
        
        % Is there a previous study in the sweep?
        %
        function out = earlierStudies(hObj)
            % If it is not a sweep study
            if isempty(hObj.options.sweep_output_dirs)
                out = false;
                return;
            end
            
            % If we are on the first study, so there is no previous study
            if hObj.study_num == 1
                out = false;
            else
                out = true;
            end
        end
        
        % Move a particular study
        %
        function setStudy(hObj, num)
            % num must be an integer
            if round(num) ~= num
                error("COMSOLdResults.setStudy(): Study number must be an integer.  You passed %g", num);
            end
            % If it is not a sweep study and asked for a study number other
            % than 1.
            if isempty(hObj.options.sweep_output_dirs)
                if num ~=1
                    error("COMSOLdResults.setStudy(): Requested study %d but there are only %d studies", num, hObj.numStudies());
                end
                % All of the values are already set correctly in this case
                % so there is nothing to do.
                return;
            end
            
            % The requested study does not exist
            if num < 1 || num > height(hObj.sweep_data)
                error("COMSOLdResults.setStudy(): Requested study %d but there are only %d studies", num, hObj.numStudies());
            else
                hObj.study_num = num;
            end
            
            hObj.derived_values = hObj.sweep_data(hObj.study_num,:).DerivedValues{1};
            hObj.setMask(hObj.mask);
            hObj.cut_planes = hObj.sweep_data(hObj.study_num,:).CutPlanes{1};
            hObj.farfield = hObj.sweep_data(hObj.study_num,:).Farfield{1};
        end
        
        % Move to the next study
        %
        function nextStudy(hObj)
            % If we are on the last study, so there is no next study
            if ~hObj.moreStudies()
                error("COMSOLdResults.nextStudy(): No next study");
            else
                hObj.setStudy(hObj.study_num + 1);
            end
        end
        
        % Move to the previous study
        %
        function previousStudy(hObj)
            if ~hObj.earlierStudies()
                error("COMSOLdResults.previousStudy(): No previous study");
            else
                hObj.setStudy(hObj.study_num - 1);
            end
        end
        
        % Move to the first study
        %
        function firstStudy(hObj)
            hObj.setStudy(1);
        end
        
        % Move to the last study
        %
        function lastStudy(hObj)
            hObj.setStudy(hObj.numStudies());
        end
        
        % Step through the studies one at a time
        %
        function out = stepThroughStudies(hObj)
            % If this is the first step
            if ~hObj.stepping_through_studies
                hObj.stepping_through_studies = true;
                hObj.firstStudy();
                out = true;
            else
                if hObj.moreStudies()
                    hObj.nextStudy();
                    out = true;
                else
                    hObj.stepping_through_studies = false;
                    out = false;
                end
            end
        end
        
        %%
        %
        % Methods for accessing data
        %
        
        function showSweep(hObj)
            if hObj.numStudies() ~= 1
                disp(hObj.sweep_data);
            else
                disp("Single study job.");
            end
        end
        
        function out = getCutPlane(hObj, field, direction)
            % Were any farfields calcualted for this study?
            if isempty(hObj.cut_planes)
                error("COMSOLdResults.getCutPlane(): No cut planes in results.");
            end
            
            % We don't want to modify the user's path, so store his value
            old_path = path;
            % Where to look for functions used, including user supplied
            % functions.
            for i=1:length(hObj.COMSOL_dir)
                addpath(hObj.COMSOL_dir{i});
            end
            
            switch lower(field)
                case "shg"
                    this_farfield = hObj.farfield.SHG;
                case "sfg"
                    this_farfield = hObj.farfield.SFG;
                case "signal"
                    this_farfield = hObj.farfield.Signal;
                otherwise
                    error("COMSOLdResults.getCutPlane(): Unknown field type: %s", field);
            end

            switch lower(direction)
                case "up"
                    this_farfield = this_farfield.up;
                case "down"
                    this_farfield = this_farfield.down;
                otherwise
                    error("COMSOLdResults.getCutPlane(): Unknown direction: %s", direction);
            end

            % If it is not a sweep study
            if isempty(hObj.options.sweep_output_dirs)
                cut_planes_tmp = load_cut_planes(hObj.options.output_dir_final, this_farfield.CutPlanes);
            else
                cut_planes_tmp = load_cut_planes(hObj.options.sweep_output_dirs_final(hObj.study_num), this_farfield.CutPlanes);
            end
            
            out = COMSOLdCutPlane(hObj.options, cut_planes_tmp);
            
            % Don't modify user's path
            path(old_path);
        end
        
        function out = getFarfield(hObj, study_type, direction)
            % Were any farfields calcualted for this study?
            if isempty(hObj.farfield)
                error("COMSOLdResults.getFarfield(): No farfield in results.");
            end
            
            % We don't want to modify the user's path, so store his value
            old_path = path;
            % Where to look for functions used, including user supplied
            % functions.
            for i=1:length(hObj.COMSOL_dir)
                addpath(hObj.COMSOL_dir{i});
            end
            
            switch lower(direction)
                case "up"
                    epsilon_r = sqrt(hObj.derived_values.parameters.n_air);
                case "down"
                    epsilon_r = sqrt(hObj.derived_values.parameters.n_sub);
            end

            % If this is a sweep then load sweep_data
            if ~isempty(hObj.options.sweep_output_dirs)
                out = COMSOLdFarfield(hObj.options, ...
                    load_farfield(hObj.options.sweep_output_dirs_final(hObj.study_num), hObj.farfield, study_type, direction),...
                     hObj.derived_values.parameters.freq,... 
                     ones(size(hObj.derived_values.parameters.n_air)), epsilon_r);
            else
                out = COMSOLdFarfield(hObj.options, ...
                    load_farfield(hObj.options.output_dir_final, hObj.farfield, study_type, direction),...
                     hObj.derived_values.parameters.freq,...
                     ones(size(hObj.derived_values.parameters.n_air)), epsilon_r);
            end
            
            % Don't modify user's path
            path(old_path);
        end
        
        function out = getFarfieldx(hObj, study_type, direction)
            % Were any farfields calcualted for this study?
            if isempty(hObj.farfield)
                error("COMSOLdResults.getFarfield(): No farfield in results.");
            end
            
            % We don't want to modify the user's path, so store his value
            old_path = path;
            % Where to look for functions used, including user supplied
            % functions.
            for i=1:length(hObj.COMSOL_dir)
                addpath(hObj.COMSOL_dir{i});
            end
            
            switch lower(direction)
                case "up"
                    epsilon_r = sqrt(hObj.derived_values.parameters.n_air);
                case "down"
                    epsilon_r = sqrt(hObj.derived_values.parameters.n_sub);
            end

            % If this is a sweep then load sweep_data
            if ~isempty(hObj.options.sweep_output_dirs)
                out = COMSOLdFarfield(hObj.options, ...
                    load_farfield_x(hObj.options.sweep_output_dirs_final(hObj.study_num), hObj.farfield, study_type, direction),...
                     hObj.derived_values.parameters.freq,... 
                     ones(size(hObj.derived_values.parameters.n_air)), epsilon_r);
            else
                out = COMSOLdFarfield(hObj.options, ...
                    load_farfield_x(hObj.options.output_dir_final, hObj.farfield, study_type, direction),...
                     hObj.derived_values.parameters.freq,...
                     ones(size(hObj.derived_values.parameters.n_air)), epsilon_r);
            end
            
            % Don't modify user's path
            path(old_path);
        end
        
        function out = getFarfieldy(hObj, study_type, direction)
            % Were any farfields calcualted for this study?
            if isempty(hObj.farfield)
                error("COMSOLdResults.getFarfield(): No farfield in results.");
            end
            
            % We don't want to modify the user's path, so store his value
            old_path = path;
            % Where to look for functions used, including user supplied
            % functions.
            for i=1:length(hObj.COMSOL_dir)
                addpath(hObj.COMSOL_dir{i});
            end
            
            switch lower(direction)
                case "up"
                    epsilon_r = sqrt(hObj.derived_values.parameters.n_air);
                case "down"
                    epsilon_r = sqrt(hObj.derived_values.parameters.n_sub);
            end

            % If this is a sweep then load sweep_data
            if ~isempty(hObj.options.sweep_output_dirs)
                out = COMSOLdFarfield(hObj.options, ...
                    load_farfield_y(hObj.options.sweep_output_dirs_final(hObj.study_num), hObj.farfield, study_type, direction),...
                     hObj.derived_values.parameters.freq,... 
                     ones(size(hObj.derived_values.parameters.n_air)), epsilon_r);
            else
                out = COMSOLdFarfield(hObj.options, ...
                    load_farfield_y(hObj.options.output_dir_final, hObj.farfield, study_type, direction),...
                     hObj.derived_values.parameters.freq,...
                     ones(size(hObj.derived_values.parameters.n_air)), epsilon_r);
            end
            
            % Don't modify user's path
            path(old_path);
        end
        
        
        %%
        %
        % Create subset of the results
        %
        
        function out = getParamValue(hObj, num)
            % if the number is out of bounds
            if num < 1 || num > hObj.getNumParams()
                error("COMSOLdResults.getParamValue(): Requested parameter number %d but there are only %d parameters", ...
                    num, hObj.numStudies());
            else
                out = hObj.sweep_data(hObj.study_num, num).Variables;
            end
        end
        
        function out = getAllParamValues(hObj, num)
            out = hObj.sweep_data.(hObj.getParamName(num));
        end
        
        function out = getParamName(hObj, num)
            % if the number is out of bounds
            if num < 1 || num > hObj.getNumParams()
                error("COMSOLdResults.getParamName(): Requested parameter number %d but there are only %d parameters", ...
                    num, hObj.numStudies());
            else
                out = hObj.sweep_data.Properties.VariableNames{num};
            end
        end
        
        function out = getNumParams(hObj)
            out = width(hObj.sweep_data) - 3;
        end
        
        function out = getAllParamNames(hObj)
            out = hObj.sweep_data.Properties.VariableNames(1:hObj.getNumParams());
        end
        
        function out = isParam(hObj, name)
            out = ~isempty(find(ismember(hObj.sweep_data.Properties.VariableNames(1:hObj.getNumParams()), name),1));
        end
        
        function out = getSubResults(hObj, variable_name, variable_value)
            if ~hObj.isParam(variable_name)
                error("COMSOLdResults.getSubResults(): Unknown variable name: %s", variable_name);
            end
            
            out = COMSOLdResults("");
            studies_to_keep = hObj.sweep_data.(variable_name) == variable_value;
            out.setSweepData(removevars(hObj.sweep_data(studies_to_keep,:), variable_name));
            options_tmp = hObj.options;
            options_tmp.sweep_output_dirs = options_tmp.sweep_output_dirs(studies_to_keep);
            options_tmp.sweep_output_dirs_final = options_tmp.sweep_output_dirs_final(studies_to_keep);
            options_tmp.sweep = options_tmp.sweep(options_tmp.sweep.ParameterName ~= variable_name,:);
            
            Value = [];
            for i=1:height(options_tmp.sweep)
                Value = [Value; options_tmp.sweep.Value(i,studies_to_keep)]; %#ok<AGROW>
            end
            ParameterName = options_tmp.sweep.ParameterName;
            options_tmp.sweep = table(ParameterName, Value);
            out.setOptions(options_tmp);
            out.firstStudy();
        end
        
        function setSweepData(hObj, sweep_data_in)
            hObj.sweep_data = sweep_data_in;
        end
        
        function setOptions(hObj, options_in)
            hObj.options = options_in;
        end
        
        % set hObj.masked_derived_values to a subset of hObj.derived_values
        % based on the value of mask
        function setMask(hObj, mask)
            if isempty(mask)
                % If the mask hasn't been set to any value yet.
                hObj.masked_derived_values = hObj.derived_values;
            else
                for nm = fieldnames(hObj.derived_values)'
                    for nm2 = fieldnames(hObj.derived_values.(nm{1}))'
                        % Don't try to mask the 'fields' field as it is of a
                        % different size to all other fields - which should all
                        % be of the same size as mask.
                        if strcmp(nm2{1}, 'fields')
                            hObj.masked_derived_values.(nm{1}).(nm2{1}) = ...
                                hObj.derived_values.(nm{1}).(nm2{1});
                        else
                            hObj.masked_derived_values.(nm{1}).(nm2{1}) = ...
                                hObj.derived_values.(nm{1}).(nm2{1})(mask);
                        end
                    end
                end
            end
        end

        % Mask derived_values by the value of a parameter of the inner
        % sweep.
        function setMaskByValue(hObj, param_name, param_value)
            field_names = fieldnames(hObj.derived_values)';
            hObj.mask = hObj.derived_values.(field_names{1}).(param_name) == param_value;

            hObj.setMask(hObj.mask);
        end

        % set hObj.mask to hObj.mask && extra_mask
        function andMask(hObj, extra_mask)
            hObj.mask = hObj.mask && extra_mask;
            hObj.setMask(hObj.mask);
        end

        % set hObj.mask to hObj.mask && extra_mask by the value of a 
        % parameter of the inner sweep.
        function andMaskByValue(hObj, param_name, param_value)
            field_names = fieldnames(hObj.derived_values)';
            extra_mask = hObj.derived_values.(field_names{1}).(param_name) == param_value;
            hObj.mask = hObj.mask && extra_mask;
            hObj.setMask(hObj.mask);
        end

        function clearMask(hObj)
            % If hObj.mask is empty then masked_derived_values is just a
            % copy of derived_values.
            hObj.mask = [];
            hObj.setMask(hObj.mask);
        end



        %%
        %
        % Utility functions
        
        % Get the directory of the current study
        function out = getStudyDir(hObj)
            % If it is not a sweep study
            if isempty(hObj.options.sweep_output_dirs)
                out = hObj.options.output_dir_final;
            else
                out = hObj.options.sweep_output_dirs_final(hObj.study_num);
            end
        end
        
        % Get the directory of the whole job
        function out = getJobDir(hObj)
            out = hObj.options.output_dir_final;
        end
        
        function out = getParamsString(hObj)
            out = [];
            for i=1:hObj.getNumParams
                out = strcat(out, hObj.getParamName(i), " = ", hObj.getParamValue(i), " ");
            end
        end
        
    end
end


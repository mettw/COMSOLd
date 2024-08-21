classdef COMSOLdStudyConfig < handle
    % COMSOLdStudyConfig
    %
    % Whenever I process a COMSOLd job file there are a lot of
    % configuration options for each job that are not contained within the
    % job file itself, such as which eigenmodes to do a symmetry analysis
    % on etc.  This class allows me to easily store all of these extra
    % options so that I can use the same LiveScript files for processing 
    % everything.
    %
    % Initalise the object with the name of the project. For example:
    %
    % > study_configuration = COMSOLdStudyConfig("DARPA");
    %
    % The function set_COMSOLdStudyConfig_project() then sets
    % which configuration file to load, such as
    %
    % MATLAB Drive/DARPA/configure_COMSOLdStudyConfig.m
    % 
    % An example version is supplied as
    % set_COMSOLdStudyConfig_project_example.m which you should configure
    % for your setup and rename.
    %
    % The code in the configuration file is executed in the constructor, 
    % so you can refer to the object properties and methods etc in it.
    %
    % See the file example_configure_COMSOLdStudyConfig.m for an example.

    properties
        project % Project name

        design_type % eg "waveguide", "resonators", etc
        study_type % "eigenfrequency', "linear", "SHG", etc
        design % "waveguide_thin" etc
        study % "M_Gamma_X_10deg", "M_Gamma_X_2deg", etc

        options % Extra options to be passed to the plotting functions etc
    end

    properties (Access = private)
        project_config_file % What the config file is named
        available % what design types, study types, designs and 
                  % studies are available

        opts_all; % options for every possible study
    end

    methods
        function obj = COMSOLdStudyConfig(project)
            obj.project = project;
            obj.project_config_file = set_COMSOLdStudyConfig_project(project);

            % Set the other properties in the object
            run(obj.project_config_file);
        end

        function out = get_available_design_types(obj)
            out = obj.available.design_types;
        end

        % Set obj.design_type and return the available study types so that
        % drop down menus can be cofigured to only offer those available.
        function out = set_design_type(obj, design_type)
            obj.design_type = design_type;
            out = obj.available.(design_type).study_types;
        end

        % Set obj.study_type and return the available designs so that
        % drop down menus can be cofigured to only offer those available.
        function out = set_study_type(obj, study_type)
            obj.study_type = study_type;
            out = obj.available.(obj.design_type).(obj.study_type).designs;
        end
            
        % Set obj.design and return the available studies so that
        % drop down menus can be cofigured to only offer those available.
        function out = set_design(obj, design)
            obj.design = design;
            out = obj.available.(obj.design_type).(obj.study_type).(obj.design).studies;
        end

        function set_study(obj, study)
            obj.study = study;
        end

        % modify the options struct that is used to control plotting and
        % other analysis functions to reflect the current study.  I am
        % returning the options structure to be compatible with my old
        % code.
        function options = set_more_options(obj, options)
            options_tmp = obj.opts_all.(obj.design_type).(obj.study_type).(obj.design).(obj.study);
            for fld = fieldnames(options_tmp).'
                options.(fld{1}) = options_tmp.(fld{1});
            end
            obj.options = options;
            
            options.design_type = obj.design_type;
            options.study_type = obj.study_type;
            options.design = obj.design;
            options.study = obj.study;
        end

        % used by the constructor to add the config for another study that
        % is available
        function add_study(obj, new_study)
            % If this is a new design_type etc then add to lists of
            % available.
            if ~isfield(obj.available, 'design_types')
                obj.available.design_types = new_study.design_type;
            elseif isempty(find(obj.available.design_types==new_study.design_type,1))
                obj.available.design_types = [obj.available.design_types new_study.design_type];
            end
            if ~isfield(obj.available, new_study.design_type)
                obj.available.(new_study.design_type).study_types = new_study.study_type;
            elseif isempty(find(obj.available.(new_study.design_type).study_types==new_study.study_type,1))
                obj.available.(new_study.design_type).study_types = ...
                    [obj.available.(new_study.design_type).study_types new_study.study_type];
            end
            if ~isfield(obj.available.(new_study.design_type), new_study.study_type)
                obj.available.(new_study.design_type).(new_study.study_type).designs = new_study.design;
            elseif isempty(find(obj.available.(new_study.design_type).(new_study.study_type).designs == ...
                    new_study.design,1))
                obj.available.(new_study.design_type).(new_study.study_type).designs = ...
                    [obj.available.(new_study.design_type).(new_study.study_type).designs new_study.design];
            end
            if ~isfield(obj.available.(new_study.design_type).(new_study.study_type), ...
                    new_study.design)
                obj.available.(new_study.design_type).(new_study.study_type).(new_study.design).studies = ...
                    new_study.study;
            elseif isempty(find(...
                    obj.available.(new_study.design_type).(new_study.study_type).(new_study.design).studies == ...
                    new_study.study,1))
                obj.available.(new_study.design_type).(new_study.study_type).(new_study.design).studies = ...
                    [obj.available.(new_study.design_type).(new_study.study_type).(new_study.design).studies ...
                    new_study.study];
            end

            obj.opts_all.(new_study.design_type).(new_study.study_type).(new_study.design).(new_study.study) = ...
                new_study.options;
            
        end

    end
end
Project__ = 'Giorgio';

% Resonators
% ==========

% Eigenfrequency
% --------------

% Design: res_D2

%       Study: MGX 10deg
if true % to allow code folding
new_study.design_type = "resonators";
new_study.study_type = "Eigenfrequency";
new_study.design = "res_D2";
new_study.study = "MGX_10deg";

new_study.options.job = "Giorgio_SFG_2mode_candidates_design_D2_1";
new_study.options.param_units = "[deg]";
new_study.options.MGX = true;
new_study.options.periodicity_scaling = 2;
new_study.options.inner_sweep = false;
new_study.options.mode_nums = 3:9;
new_study.options.shift_cut_planes = false;
new_study.options.shift = [-11, 11];

new_study.saved_data_file_name = strcat('E:/Matlab_data_files/', Project__, '_symmetry_data_', ...
                    new_study.design_type, '_', new_study.study_type, ...
                    '_',  new_study.design, '_', new_study.study,  '.mat');

new_study.vars_to_load.Pu_c4v_43x43 = 'E:\tmp\overvig\Pu_c4v_43x43.mat';
new_study.proj__original_name = 'Pu_c4v_43x43';

obj.add_study(new_study);
end

% Design: res_D3

%       Study: MGX 10deg
if true % to allow code folding
new_study.design_type = "resonators";
new_study.study_type = "Eigenfrequency";
new_study.design = "res_D3";
new_study.study = "MGX_10deg";

new_study.options.job = "Giorgio_SFG_2mode_candidates_design_D3_1";
new_study.options.param_units = "[deg]";
new_study.options.MGX = true;
new_study.options.periodicity_scaling = 2;
new_study.options.inner_sweep = false;
new_study.options.mode_nums = 3:9;
new_study.options.shift_cut_planes = false;
new_study.options.shift = [-11, 11];

new_study.saved_data_file_name = strcat('E:/Matlab_data_files/', Project__, '_symmetry_data_', ...
                    new_study.design_type, '_', new_study.study_type, ...
                    '_',  new_study.design, '_', new_study.study,  '.mat');

new_study.vars_to_load.Pu_c4v_43x43 = 'E:\tmp\overvig\Pu_c4v_43x43.mat';
new_study.proj__original_name = 'Pu_c4v_43x43';

obj.add_study(new_study);
end

% Linear
% ------

% Design: res_D2

%       Study: MGX 10deg
if true % to allow code folding
new_study.design_type = "resonators";
new_study.study_type = "Linear";
new_study.design = "res_D2";
new_study.study = "MGX_10deg_HV";

new_study.options.job = "Giorgio_SFG_2mode_candidates_design_D2_Signal_1";

new_study.saved_data_file_name = strcat('E:/Matlab_data_files/', Project__, '_symmetry_data_', ...
                    new_study.design_type, '_', new_study.study_type, ...
                    '_',  new_study.design, '_', new_study.study,  '.mat');

obj.add_study(new_study);
end

% Waveguide
% =========

% Eigenfrequency
% --------------

% Design: wg-E2

%       Study: MGX 10deg
if true % to allow code folding
new_study.design_type = "waveguide";
new_study.study_type = "Eigenfrequency";
new_study.design = "wg_E2";
new_study.study = "MGX_10deg";

new_study.options.job = "Giorgio_SFG_2mode_waveguide_candidates_design_E2_1";
new_study.options.param_units = "[deg]";
new_study.options.MGX = true;
new_study.options.periodicity_scaling = 1;
new_study.options.inner_sweep = false;
new_study.options.mode_nums = 3:9;
new_study.options.shift_cut_planes = false;
%new_study.options.shift = [-33, 33];

new_study.options.saved_data_file_name = strcat('E:/Matlab_data_files/', Project__, '_symmetry_data_', ...
                    new_study.design_type, '_', new_study.study_type, ...
                    '_',  new_study.design, '_', new_study.study,  '.mat');

new_study.options.vars_to_load.Pu_c4v_43x43 = 'E:\tmp\overvig\Pu_c4v_43x43.mat';
new_study.options.proj__original_name = 'Pu_c4v_43x43';

obj.add_study(new_study);
end

%       Study: MGX 2deg
if true % to allow code folding
new_study.design_type = "waveguide";
new_study.study_type = "Eigenfrequency";
new_study.design = "wg_E2";
new_study.study = "MGX_2deg";

new_study.options.job = "Giorgio_SFG_2mode_waveguide_candidates_design_E2_2";
new_study.options.param_units = "[deg]";
new_study.options.MGX = true;
new_study.options.periodicity_scaling = 1;
new_study.options.inner_sweep = false;
new_study.options.mode_nums = 3:6;
new_study.options.shift_cut_planes = false;
%new_study.options.shift = [-33, 33];

new_study.saved_data_file_name = strcat('E:/Matlab_data_files/', Project__, '_symmetry_data_', ...
                    new_study.design_type, '_', new_study.study_type, ...
                    '_',  new_study.design, '_', new_study.study,  '.mat');

new_study.vars_to_load.Pu_c4v_43x43 = 'E:\tmp\overvig\Pu_c4v_43x43.mat';
new_study.proj__original_name = 'Pu_c4v_43x43';

obj.add_study(new_study);
end

%       Study: MGX 2deg, new comsol file
if true % to allow code folding
new_study.design_type = "waveguide";
new_study.study_type = "Eigenfrequency";
new_study.design = "wg_E2";
new_study.study = "MGX_2deg_mph_v8";

new_study.options.job = "Giorgio_SFG_2mode_waveguide_candidates_design_E2_3";
new_study.options.param_units = "[deg]";
new_study.options.MGX = true;
new_study.options.periodicity_scaling = 1;
new_study.options.inner_sweep = false;
new_study.options.mode_nums = 3:6;
new_study.options.shift_cut_planes = false;
%new_study.options.shift = [-33, 33];

new_study.saved_data_file_name = strcat('E:/Matlab_data_files/', Project__, '_symmetry_data_', ...
                    new_study.design_type, '_', new_study.study_type, ...
                    '_',  new_study.design, '_', new_study.study,  '.mat');

new_study.vars_to_load.Pu_c4v_43x43 = 'E:\tmp\overvig\Pu_c4v_43x43.mat';
new_study.proj__original_name = 'Pu_c4v_43x43';

obj.add_study(new_study);
end

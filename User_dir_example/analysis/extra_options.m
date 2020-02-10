%
% Configuration for sweeps of the E and H field at the farfield planes so
% that we can derive the Fourier components of the field - ie, to look at
% what the zeroth component of the Poynting vector will be in the farfield
% etc.
function options_out = extra_options(options)
    
    % For information on each run look for the file __README in the relevant
    % directory specified in poptions.directory.

    options_out = set_defaults(options);

    %
    % Values specific to a particular run

    options_out.thetas = 0;
    options_out.peak_freq_nums = 1;
    options_out.plot_freq_nums = 1;
    options_out.infix = '';

    options_out = compute_values(options_out);

end

function options_ret = set_defaults(options)

    % Default values
    %
    % for v12 ([110] from air side)

    % Are we running EWFD or EMW studies?
    if strcmp(options.study, "EWFD: All")
        options_ret.ewfd = true;
        options_ret.signal_ran = options.studies("EWFD: Signal",:).Run;
        options_ret.idler_ran = options.studies("EWFD: Idler",:).Run;
        options_ret.sfg_ran = options.studies("EWFD: SFG",:).Run;
        % Do we process these cut planes for SFG?  Otherwise it is for Signal
        options_ret.sfg_cut_planes = options.studies("EWFD: SFG",:).Run;
    else
        options_ret.sfg_cut_planes = false;
    end
    % This is used for sweeps of any parameter, not just for theta
    options_ret.thetas = 0:0.2:1;
    % Indicies of poptions.thetas of which angles to plot
    options_ret.plot_theta_nums = 1;%1:length(poptions.thetas);

    options.D = options.parameters("D",:).Value;
    options_ret.lda_p = str2num(replace(options.parameters("lda_p",:).Value,...
        ["[nm]" "scale"],["" options.parameters("scale",:).Value])); % SFG wavelength
    options_ret.lda_min = str2num(replace(options.parameters("lda_s",:).Value,...
        ["[nm]" "scale"],["" options.parameters("scale",:).Value])); % Signal min wavelength
    options_ret.lda_max = str2num(replace(options.parameters("lda_s_max",:).Value,...
        ["[nm]" "scale"],["" options.parameters("scale",:).Value])); % Signal max wavelength
    options_ret.num_freqs = str2num(replace(options.parameters("ind_max",:).Value,...
        ["[nm]" "scale"],["" options.parameters("scale",:).Value])); % Number of signal wavelengths simulated

    % Indecies of poptions.freqs of which frequencies to plot
    options_ret.peak_freq_nums = [25 25 23 21 18 13];
    options_ret.plot_freq_nums = options_ret.peak_freq_nums(options_ret.plot_theta_nums);

    % Which cut plane in the model did we get the E and H values from?
    % NF - 5nm above/below surface/base of the resonator
    % FF - +/-0.8*H 
    options_ret.cut_plane = "FF";%["NF", "FF"];
    % In which direction to we want to processes the data?
    % up - cut plane(s) in the positive z direction
    % down - cut plane(s) in the negative z direction
    options_ret.direction = "down";%["up", "down"];
    % For greater flexibility
    options_ret.cut_plane_dir = 'cut_plane\';
    % In a sweep of, say, theta then COMSOL will
    % output files of the form "parameters_theta_0.txt" so we need to
    % specify the infix as "_theta_", "_phi_" or "" for no sweep.
    options_ret.infix = '_theta_';
    % Data directory
    options_ret.directory = options.output_dir;
    options_ret.load_relE = true;
    options_ret.load_relH = true;
    options_ret.load_pol = false;

    % Which first order peak to plot
    options_ret.first_order.xlabel = '1';
    options_ret.first_order.ylabel = '0';

    options_ret = compute_values(options_ret);

end

function options = compute_values(options)

    c = 299792458;

    % values recalculated below
    options.num_thetas = length(options.thetas); % Might not always want to use all theta values calculated
    options.freqs = c/options.lda_max:(c/(options.lda_min)-(c/(options.lda_max)))/(options.num_freqs-1):c/options.lda_min;
    options.wlengths = c./options.freqs;
    options.freqs_i = c./options.lda_p-options.freqs;
    options.wlengths_i = c./options.freqs_i;

    switch options.first_order.xlabel
        case '-1'
    options.first_order.x = 3;
        case '0'
    options.first_order.x = 2;
        case '1'
    options.first_order.x = 1;
    end

    switch options.first_order.ylabel
        case '-1'
    options.first_order.y = 3;
        case '0'
    options.first_order.y = 2;
        case '1'
    options.first_order.y = 1;
    end

end

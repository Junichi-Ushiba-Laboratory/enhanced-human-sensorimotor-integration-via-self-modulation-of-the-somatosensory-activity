%%% figure 1c (FOOOF)
local = Local;
is_load_raw = 0;

CSE = load(local.path_cse);
CSE = CSE.result_sub;
Fs = CSE(1).Fs;
util_fooof = UtilFOOOF();

range_rest = 1:Fs * 5;
num_sub = numel(CSE);
result_fooof_cse = [];

for i_sub = 1:num_sub
    signal_eeg_rest = CSE(i_sub).signal(range_rest, :, :);
    [result, trial_reject, result_pwelch] = util_fooof.main(singnal_eeg_rest, Fs, local.FOI);

    result_fooof = os.set_result(result, trial_reject, result_pwelch);
    substr = deblank(CSE(i_sub).name_sub);
    path_sub = fullfile(local.path_out_cse, 'FOOOF', sprintf('%s.mat', substr));
    save(path_sub, '-struct', 'result_fooof');
    result_fooof_cse = [result_fooof_cse; result_fooof];
end

%% representative FOOOF
target_sub = 11;
result_pwelch = result_fooof_cse(target_sub).result_pwelch;
psd_mean = result_pwelch.psd_mean;
freq = result_pwelch.freq;
util_fooof.fooof_group(freq, psd_mean);
result = util_fooof.get_result;
result_M1 = result(3);
result_S1 = result(1);

vi.is_mod_font_size = 0;
close all
vi.figure;
vi.sp(1, 2, 1);
util_fooof.plot(result_M1);
ylim([-2.5 -0.5]);
vi.set_fig(4, 8);
hold on;
vi.sp(1, 2, 2);
util_fooof.plot(result_S1);
ylim([-2.5 -0.5]);
vi.set_fig(4, 8);
vi.set_position([1 1 195 108]);
%% group analysis
close all
[idx_sham, idx_verum] = local.get_idx_sub();
num_sub = numel(result_fooof_cse);
result_gp = [];

for i_sub = 1:num_sub
    result = result_fooof_cse(i_sub).result;

    get_peak_params = @(x) x.peak_params;
    get_aperiodic_params = @(x) x.aperiodic_params(2);

    peak_params = arrayfun(get_peak_params, result, 'UniformOutput', false);
    aperiodic_exp = arrayfun(get_aperiodic_params, result, 'UniformOutput', true);

    select_IAF = @(x) x(x(:, 1) >= (local.FOI(1) - 1) & x(:, 1) <= (local.FOI(2) + 1), [1, 2]);
    peak_params = cellfun(select_IAF, peak_params, 'UniformOutput', false);
    peak_params(cellfun(@isempty, peak_params, 'UniformOutput', true)) = {[NaN, NaN]};
    get_freq = @(x) nanmedian(x(:, 1));
    peak_params_freq = cellfun(get_freq, peak_params, 'UniformOutput', true);
    get_peak_height = @(x) nanmedian(x(:, 2));
    peak_params_height = cellfun(get_peak_height, peak_params, 'UniformOutput', true);

    out = os.set_result(aperiodic_exp, peak_params_freq, peak_params_height);
    result_gp = [result_gp; out];
end

%%
plot_box_plot
%% control analysis
close all
list_freq_ctrl = [3, 7; 14, 30];
num_band = size(list_freq_ctrl, 1);
num_sub = numel(result_fooof_cse);
result_gp_ctrl = [];

for i_sub = 1:num_sub
    result = result_fooof_cse(i_sub).result;

    get_peak_params = @(x) x.peak_params;
    get_aperiodic_params = @(x) x.aperiodic_params(2);

    aperiodic_exp = arrayfun(get_aperiodic_params, result, 'UniformOutput', true);

    peak_params_freq_band = [];
    peak_params_height_band = [];

    for i_band = 1:num_band
        peak_params = arrayfun(get_peak_params, result, 'UniformOutput', false);

        select_band = @(x) x(x(:, 1) >= (list_freq_ctrl(i_band, 1) - 1) & x(:, 1) <= (list_freq_ctrl(i_band, 2) + 1), [1, 2]);
        peak_params = cellfun(select_band, peak_params, 'UniformOutput', false);
        peak_params(cellfun(@isempty, peak_params, 'UniformOutput', true)) = {[NaN, NaN]};

        get_freq = @(x) nanmedian(x(:, 1));
        peak_params_freq = cellfun(get_freq, peak_params, 'UniformOutput', true);

        get_peak_height = @(x) nanmedian(x(:, 2));
        peak_params_height = cellfun(get_peak_height, peak_params, 'UniformOutput', true);

        peak_params_freq_band = [peak_params_freq_band; {peak_params_freq}];
        peak_params_height_band = [peak_params_height_band; {peak_params_height}];
    end

    out = os.set_result(aperiodic_exp, peak_params_freq_band, peak_params_height_band);
    result_gp_ctrl = [result_gp_ctrl; out];
end

%%
plot_box_plot

fprintf('Time-Frequency Analysis start\n')
get_ch_reject = @(x) x.get_ch_reject;
ch_reject = arrayfun(get_ch_reject, data_egi, 'UniformOutput', false);
ch_reject = unique(os.dyncat(1, ch_reject{:}));
ch_reject(isnan(ch_reject)) = [];
close all

for i_run = 1:num_run
    fprintf('sub %02d run %02d\n', idx_sub(i_sub), i_run)
    list_ch = data_egi(i_run).get_list_ch();
    list_ch(ismember(list_ch, ch_reject)) = [];
    idx_coi = find(list_ch == local.COI);

    if isempty(idx_coi)
        [~, idx_coi] = min(abs(list_ch - local.COI));
    end

    is_tfa = 0;

    if ~exist('is_finish_proc', 'var')
        is_tfa = 1;
    elseif is_finish_proc == 0
        is_tfa = 1;
    elseif is_finish_proc == 2
        idx_coi = 1;
    end

    tfa = UtilTimeFrequencyAnalysis(data_egi(i_run).get_Fs);

    if is_tfa == 1
        data_eeg = data_egi(i_run).get_data_eeg;
        data_eeg = data_eeg(:, list_ch, :);
        % car
        data_eeg = data_eeg - mean(data_eeg, 2);
        data_eeg = UtilSEPBMI.cut_blank(data_eeg, data_egi(i_run).get_Fs);
        % fft
        result_fft = tfa.fft(data_eeg);
        % ERSP
        result_ersp = tfa.calc_ersp(result_fft, local.range_ref, local.type_ref);
    else
        result_ersp = data_egi(i_run).result.ersp;
    end

    % check_tf
    [tf_mean, list_idx_trl] = tfa.mean_trl(result_ersp, idx_coi, local.select_trl);

    if isempty(tf_mean)
        [tf_mean, list_idx_trl] = tfa.mean_trl(result_ersp, idx_coi, 0);
    end

    if is_plot
        tfa.tfmap(tf_mean);
        vi.set_title(sprintf('sub %02d run %02d', idx_sub(i_sub), i_run));
    end

    ISF = tfa.find_isf(tf_mean, local.range_task, local.FOI);
    data_egi(i_run).result.fft = result_fft;
    data_egi(i_run).result.ersp = result_ersp;
    data_egi(i_run).result.ISF = ISF;
    data_egi(i_run).result.tf_mean = tf_mean;
    data_egi(i_run).result.list_idx_trl = list_idx_trl;

end

fprintf('Time-Frequency Analysis finish\n')

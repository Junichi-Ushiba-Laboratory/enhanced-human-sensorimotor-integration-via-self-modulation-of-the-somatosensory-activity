local = Local();
file_fooof = dir(local.path_fooof_rest);
file_fooof = os.fullPath(file_fooof);
result_fooof_rest = cellfun(@load, file_fooof, 'Uniformoutput', false);
result_fooof_rest = [result_fooof_rest{:}]';

file_fooof = dir(local.path_fooof_task);
file_fooof = os.fullPath(file_fooof);
result_fooof_task = cellfun(@load, file_fooof, 'Uniformoutput', false);
result_fooof_task = [result_fooof_task{:}]';
%%
result_pwelch_task = [result_fooof_task.result_pwelch]';
result_pwelch_rest = [result_fooof_rest.result_pwelch]';
trl_reject_task = cat(3, result_fooof_task.trial_reject);
trl_reject_rest = cat(3, result_fooof_rest.trial_reject);

psd_task = cat(4, result_pwelch_task.psd);
psd_rest = cat(4, result_pwelch_rest.psd);
freq = result_pwelch_task(1).freq;

util_fooof = UtilFOOOF();
[idx_sham, idx_verum] = local.get_idx_sub();
idx_trl = local.get_idx_trl();
list_roi = [3, 1];
num_roi = numel(list_roi);

result_fooof_recalc = [];

for i_roi = 1:num_roi
    trl_reject_rest_ = sq(trl_reject_rest(list_roi(i_roi), idx_trl, :));
    trl_reject_task_ = sq(trl_reject_task(list_roi(i_roi), idx_trl, :));

    psd_rest_ = sq(psd_rest(:, list_roi(i_roi), idx_trl, :));
    psd_task_ = sq(psd_task(:, list_roi(i_roi), idx_trl, :));

    for i_sub = 1:size(psd_task_, 3)
        idx_trl_rest = find(trl_reject_rest_(:, i_sub) ~= 0);
        idx_trl_task = find(trl_reject_task_(:, i_sub) ~= 0);

        psd_rest_(:, idx_trl_rest, i_sub) = NaN;
        psd_task_(:, idx_trl_task, i_sub) = NaN;
    end

    psd_rest_ = sq(nanmedian(psd_rest_, 2));
    psd_task_ = sq(nanmedian(psd_task_, 2));

    util_fooof.fooof_group(freq, psd_rest_);
    result_rest = util_fooof.get_result;
    result_rest_IAF = util_fooof.get_list_foi();
    IAF_FOI = round(result_rest_IAF(:, 1, 1));
    IAF_FOI(isnan(IAF_FOI)) = 10;

    result_rest_theta = util_fooof.get_list_foi([3 7]);
    result_rest_beta = util_fooof.get_list_foi([14 30]);

    util_fooof.fooof_group(freq, psd_task_);
    result_task = util_fooof.get_result;
    result_task_IAF = util_fooof.get_list_foi();
    result_task_theta = util_fooof.get_list_foi([3 7]);
    result_task_beta = util_fooof.get_list_foi([14 30]);

    for i_sub = 1:size(psd_task_, 2)
        range_foi = find(freq >= (IAF_FOI(i_sub) - 1) & freq <= (IAF_FOI(i_sub) + 1));
        result_rest_IAF(i_sub, 1, 2) = nanmean(psd_rest_(range_foi, i_sub), 1);
        result_task_IAF(i_sub, 1, 2) = nanmean(psd_task_(range_foi, i_sub), 1);

        range_foi = find(freq >= (3) & freq <= (7));
        result_rest_theta(i_sub, 1, 2) = nanmean(psd_rest_(range_foi, i_sub), 1);
        result_task_theta(i_sub, 1, 2) = nanmean(psd_task_(range_foi, i_sub), 1);

        range_foi = find(freq >= (14) & freq <= (30));
        result_rest_beta(i_sub, 1, 2) = nanmean(psd_rest_(range_foi, i_sub), 1);
        result_task_beta(i_sub, 1, 2) = nanmean(psd_task_(range_foi, i_sub), 1);
    end

    out = os.set_result(result_rest, result_rest_IAF, ...
        result_rest_theta, result_rest_beta, ...
        result_task, result_task_IAF, ...
        result_task_theta, result_task_beta);
    result_fooof_recalc = [result_fooof_recalc; out];
end

%%
vi = VisualizeData;
vi.papermode;

close all
list_roi = [3, 1];
list_col = {"#CE00B1"; "#006BFF"};
list_col_sham = {"#6E1658"; "#0B2B5C"};

result_t_freq = [];

for i_type = 1:3

    if i_type == 1
        type_data = 'IAF';
    elseif i_type == 2
        type_data = 'Theta';
    elseif i_type == 3
        type_data = 'Beta';
    elseif i_type == 4
        type_data = 'aperiodic';
    end

    for i_roi = 1:2
        label_y = sprintf('Spectral power (%s)', type_data);

        switch lower(type_data)
            case 'iaf'
                out_data_rest = result_fooof_recalc(i_roi).result_rest_IAF(:, 1, 2);
                out_data_task = result_fooof_recalc(i_roi).result_task_IAF(:, 1, 2);
                yl = [0 2.5];
            case 'theta'
                out_data_rest = result_fooof_recalc(i_roi).result_rest_theta(:, 1, 2);
                out_data_task = result_fooof_recalc(i_roi).result_task_theta(:, 1, 2);
                yl = [0 0.45];
            case 'beta'
                out_data_rest = result_fooof_recalc(i_roi).result_rest_beta(:, 1, 2);
                out_data_task = result_fooof_recalc(i_roi).result_task_beta(:, 1, 2);
                yl = [0.1 0.5];
            case 'aperiodic'
                out_data_rest = [result_fooof_recalc(i_roi).result_rest];
                out_data_rest = cat(1, out_data_rest.aperiodic_params);
                out_data_rest = out_data_rest(:, 2);

                out_data_task = [result_fooof_recalc(i_roi).result_task];
                out_data_task = cat(1, out_data_task.aperiodic_params);
                out_data_task = out_data_task(:, 2);
                label_y = 'Aperiodic exponent';
                yl = [0.1 0.5];
        end

        out_data_ = [out_data_rest, out_data_task];
        out_data_(any(isnan(out_data_), 2), :) = NaN;

        data_verum = out_data_(idx_verum, :);
        data_sham = out_data_(idx_sham, :);

        rountine_boxplot(vi, data_verum, data_sham, list_col{i_roi}, list_col_sham{i_roi});
        vi.set_label('', label_y)

        data_out = [data_verum; data_sham];
        data_out(:, end + 1) = 0;
        data_out(size(data_verum, 1) + 1:end, end) = 1;
        data_out = array2table(data_out, 'VariableNames', {'Rest'; 'Task'; 'GP'});
        writetable(data_out, sprintf('FOOOF_%02d_%s.csv', list_roi(i_roi), type_data))
    end

end

function rountine_boxplot(vi, IAF_verum, IAF_sham, col, col_sham)
    pt = 2;
    vi.figure([100 100 122 100]);
    a = vi.notBoxPlot(IAF_verum, [1 2]);
    vi.moduBoxplot(a, pt, col);
    vi.pairwiseplot_nbp(a)
    hold on;
    b = vi.notBoxPlot(IAF_sham, [3 4]);
    vi.moduBoxplot(b, pt, col_sham);
    vi.pairwiseplot_nbp(b)
    xlim([0.5 4.5]);
    xticks([1:4]);
    xticklabels({'Rest'; 'Task'; 'Rest'; 'Task'})
    vi.set_fig(4, 8);
end

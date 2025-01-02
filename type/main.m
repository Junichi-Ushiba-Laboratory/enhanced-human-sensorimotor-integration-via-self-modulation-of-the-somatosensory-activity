vi = VisualizeData;
vi.papermode

local = Local;
file_acc = dir(fullfile(local.path_result, 'integrated_accuracy*.mat'));
file_acc = os.fullPath(file_acc);
load_acc = @(x)load(x, 'typingData');
data_acc = cellfun(load_acc, file_acc, 'Uniformoutput', false);
data_acc = [data_acc{:}]';

target_gp = 'verum';
% target_gp = 'sham';
idx_target = find(contains(lower(file_acc), target_gp));
typingData = data_acc(idx_target).typingData; %[cond time sub]

typingData = permute(typingData, [3, 2, 1]); %[sub,cond time]
idx_cond = 2:2:6;

%%
flag_model = 2; num_para = 3;
col_tradeoff = [142	170	217; 43	84	144; 28	53	91]' / 255;
close all

figure('Color', [1 1 1], 'Position', [584 306 210 81]);
vi.sp(1, 2, 1);
a = notBoxPlot(typingData(:, :, 1), idx_cond);
vi.moduBoxplot(a, 8, col_tradeoff);

vi.set_fig(4, 8);
ylabel('Success rate')
xlabel('Movement time [s]')
ylim([0 1.1]); yticks(0.2:0.2:1)
vi.sp(1, 2, 2);
b = notBoxPlot(typingData(:, :, 2), idx_cond);
vi.moduBoxplot(b, 8, col_tradeoff);

ylim([0 1.1]); yticks(0.2:0.2:1)
vi.set_fig(4, 8);
ylabel('Success rate')
xlabel('Movement time [s]')

%%s fit data
[num_sub, ~, num_time] = size(typingData);
list_fit_result = zeros(num_para, num_sub, num_time);
list_gof = cell(num_sub, num_time);

for i_sub = 1:num_sub

    for i_time = 1:num_time
        vi.sp(1, 2, i_time); hold on;

        [fitresult, gof] = local.createFit_exp(idx_cond, typingData(i_sub, :, i_time));
        list_fit_result(:, i_sub, i_time) = [fitresult.a, fitresult.b, fitresult.c];
        list_gof(i_sub, i_time) = {gof};

        [xData, yData] = prepareCurveData(idx_cond, typingData(i_sub, :, i_time));
        h = plot(fitresult, xData, yData);
        h(2).LineWidth = 1.5;
        h(2).Color = 0.3 + [0.2; 0.2; 0.2];
        h(1).delete;

        offLegend(h(2));
        ylabel('Success rate');
        xlabel('Movement time [s]')

    end

    legend off;
end

vi.sp(1, 2, 1);
title('Pre-evaluation')
legend off;

vi.sp(1, 2, 2);
legend off;
title('Post-evaluation')

data_pre = typingData(:, :, 1);
data_post = typingData(:, :, 2);
data_pre = list_fit_result(:, :, 1)';
data_post = list_fit_result(:, :, 2)';

for i_cond = 1:num_para
    figure('Color', [1 1 1], 'Position', [365 487 423 428]);

    dat = [data_pre(:, i_cond), data_post(:, i_cond)];

    a = notBoxPlot(dat);
    vi.moduBoxplot(a, 8, vi.get_color(1, [1, 2]));
    vi.pairwiseplot_nbp(a, 0.5);

    xticklabels({'Pre-eval'; 'Post-eval'})
    vi.set_fig(4, 10);
    ylabel(sprintf('coefficient value %c', char(96 + i_cond)))
end

%% result_fitting
result_fitting = [];
result_fitting.data_pre = data_pre;
result_fitting.data_post = data_post;
result_fitting.list_fit_result = list_fit_result;
result_fitting.typingData = typingData;

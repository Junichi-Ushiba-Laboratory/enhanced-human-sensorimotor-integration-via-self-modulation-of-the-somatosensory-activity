classdef SEPAnalysis < handle

    properties
        vi = VisualizeData;
        os = UtilGeneral;
        result
        data
        para = struct;
    end

    methods (Static)

        function window = get_window(idx_ch)
            window = [0.01, 0.03; 0.005, 0.03; 0.005, 0.03];
            window = window(idx_ch, :);
        end

    end

    methods (Access = public)

        function [result, name_comp] = compare_gp(self, idx_ch);

            if nargin < 2
                idx_ch = 1;
            end

            vi = self.vi;
            name_comp = self.get_name_comp(idx_ch);
            result_SEP = self.result.(name_comp);
            data_gp1 = result_SEP{1}(:, :, 1);
            data_gp2 = result_SEP{2}(:, :, 1);

            col_gp1 = [vi.get_color(1, 1) / 1.3, vi.get_color(1, 1)];
            col_gp2 = [vi.get_color(1, 2) / 1.3, vi.get_color(1, 2)];

            num_sub = self.data.num_sub;

            vi.figure;
            a = notBoxPlot(data_gp1, [1 2]);
            vi.moduBoxplot(a, 8, col_gp1);
            vi.pairwiseplot_nbp(a);

            b = notBoxPlot(data_gp2, [3 4]);
            vi.moduBoxplot(b, 8, col_gp2);
            vi.pairwiseplot_nbp(b);

            xlim([0.5 4.5]);
            xticks(1:4);
            xticklabels({'Pre-eval', 'Post-eval', 'Pre-eval', 'Post-eval'});

            vi.set_fig(-4, 10);
            vi.setLabel('', 'Normalized amplitude');

            is_verum = 2 - self.data.is_verum;
            result = [[data_gp1; data_gp2], is_verum];
        end

        function [result, name_comp] = compare_gp_formal(self, idx_ch);

            if nargin < 2
                idx_ch = 1;
            end

            pt = 2;
            vi = self.vi;
            vi.papermode;
            name_comp = self.get_name_comp(idx_ch);
            result_SEP = self.result.(name_comp);
            data_gp1 = result_SEP{1}(:, :, 1);
            data_gp2 = result_SEP{2}(:, :, 1);

            col_gp1 = [vi.get_color(1, 1), vi.get_color(1, 1) / 1.3];
            col_gp2 = [vi.get_color(1, 2), vi.get_color(1, 2) / 1.3];

            num_sub = self.data.num_sub;

            vi.figure([100 188 177 136]);
            a = notBoxPlot(data_gp1, [1 2]);
            vi.moduBoxplot(a, pt, col_gp1);
            vi.pairwiseplot_nbp(a, 0.5, 0.5);

            b = notBoxPlot(data_gp2, [3 4]);
            vi.moduBoxplot(b, pt, col_gp2);
            vi.pairwiseplot_nbp(b, 0.5, 0.5);

            xlim([0.5 4.5]);
            xticks(1:4);
            xticklabels({'Eval. 1', 'Eval. 2', 'Eval. 1', 'Eval. 2'});

            vi.set_fig(-4, 8);
            vi.setLabel('', 'Normalized amplitude');
            vi.set_title(name_comp);
            is_verum = 2 - self.data.is_verum;
            result = [[data_gp1; data_gp2], is_verum];
        end

    end

    methods (Access = public)

        function self = SEPAnalysis
            self.set_para()
            self.vi.is_mod_font_size = false;
        end

        function set_para(self)
            self.para.name_comp = {'N20'; 'N9'; 'N13'};
            self.para.name_run = {'sep_pre'; 'sep_post'};
            self.para.name_gp = {'verum'; 'sham'};
            self.para.Fs = 10000;
            self.para.length_segment_half = 0.3;
        end

        function load(self, path_data)

            if nargin < 2
                path_data = cd;
            end

            name_gp = self.para.name_gp;

            file_sep = dir(fullfile(path_data, '*.mat'));
            file_sep = self.os.fullPath(file_sep);

            is_verum = find(contains(file_sep, name_gp{1}));
            is_sham = find(contains(file_sep, name_gp{2}));

            file_sep = file_sep([is_verum; is_sham]);
            data_sep = cellfun(@load, file_sep, 'UniformOutput', false);
            data_sep = [data_sep{:}]';

            num_sub = @(x) numel([x.result_SEP_sub]);
            num_sub = arrayfun(num_sub, data_sep);
            is_verum = zeros(sum(num_sub), 1);
            is_verum(1:num_sub(1)) = 1;

            data_sep = [data_sep.result_SEP_sub]';
            self.data.num_sub = num_sub;
            self.data.is_verum = is_verum;
            self.data.sep = data_sep;
        end

        function range_segment = get_range_segment(self, idx_ch)
            Fs = self.para.Fs;
            length_segment = self.para.length_segment_half;
            window = self.get_window(idx_ch);
            range_segment = (length_segment + window(1)) * Fs + 1:length_segment * Fs + window(2) * Fs;
        end

        function name_comp = get_name_comp(self, idx_ch)
            name_comp = self.para.name_comp{idx_ch};
        end

        main(self, idx_ch, is_debug)
    end

end

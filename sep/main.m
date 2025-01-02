local = Local();
path_data = local.path_data;
sep_analysis = SEPAnalysis;
sep_analysis.load(path_data);
%%
close all

for idx_ch = 1:3
    is_debug = 0;
    sep_analysis.main(idx_ch, is_debug)
    sep_analysis.vi.is_mod_font_size = true;
    [data_out, name_comp] = sep_analysis.compare_gp_formal(idx_ch);

    %% export JASP
    data_out = array2table(data_out, 'VariableNames', {'Eval1'; 'Eval2'; 'GP'});
    writetable(data_out, sprintf('SEP_%s.csv', name_comp));

end

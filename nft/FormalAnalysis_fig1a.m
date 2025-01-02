%%% figure 1a
close all
open('fig1a_schema.fig');
drawnow;
f = gcf;
ch1 = get(f, 'Children');
ch2 = get(ch1, 'Children');
set(ch2(1), 'CData', zeros(8192, 1, 3));
saveas(gcf, 'Fig1a', 'pdf');

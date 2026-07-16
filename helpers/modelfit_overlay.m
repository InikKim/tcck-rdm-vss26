function gf = modelfit_overlay(df, condCol, condOrder, condLabels, colors, outPng)
% MODELFIT_OVERLAY  Plot group-pooled error histograms (31 bins, odd so
% one is centered on 0 deg) overlaid with the aggregate (group-MLE) model
% PDF and its R^2 against the binned histogram.
%
%   gf = modelfit_overlay(df, condCol, condOrder, condLabels, colors, outPng)
%
% Returns a table of group fits per condition.

DEGS  = -179:180;
nBins = 31;
edges = linspace(-180, 180, nBins+1);

nC = numel(condOrder);
fig = figure('Color','w','Position',[100 100 280*nC+200 360]);
gf  = table();

for j = 1:nC
    cnd = condOrder(j);
    e   = df.error(df.(condCol) == cnd);
    e   = e(~isnan(e));

    ax = subplot(1, nC, j); hold(ax,'on');
    histogram(ax, e, 'BinEdges', edges, 'Normalization','pdf', ...
        'FaceColor', hex2col(colors{j}), 'FaceAlpha', 0.55, 'EdgeColor','w');

    % Aggregate fit
    [k, d, nll] = fit_tcc_vm(e);
    pdf = tcc_vm_pdf(k, d);

    % R^2 against the displayed histogram
    counts = histcounts(e, edges);
    emp    = counts ./ (sum(counts) * (edges(2)-edges(1)));
    pred   = zeros(1, nBins);
    for b = 1:nBins
        m = DEGS >= edges(b) & DEGS < edges(b+1);
        if any(m), pred(b) = mean(pdf(m)); end
    end
    ss_res = sum((emp-pred).^2);
    ss_tot = sum((emp-mean(emp)).^2);
    r2 = 1 - ss_res/ss_tot;

    plot(ax, DEGS, pdf, 'k', 'LineWidth', 2);
    legend(ax, {'', sprintf('Model\n\\kappa=%.2f, d''=%.2f\nR^2=%.3f', ...
                            k, d, r2)}, 'Location','northeast','Box','on');
    xlabel(ax, 'Response error (°)');
    if j == 1, ylabel(ax, 'Probability density'); end
    xlim(ax, [-180 180]);
    ax.Box = 'off';
    title(ax, sprintf('%s = %s', condCol, condLabels{j}));

    gf = [gf; table(string(condCol), cnd, numel(e), k, d, nll, r2, ...
        'VariableNames', {'experiment','condition','n_trials','kappa','dprime','nll','r2'})]; %#ok<AGROW>
end

exportgraphics(fig, outPng, 'Resolution', 150);
exportgraphics(fig, strrep(outPng,'.png','.pdf'));
end

function c = hex2col(h)
h = strrep(h,'#','');
c = [hex2dec(h(1:2)) hex2dec(h(3:4)) hex2dec(h(5:6))] / 255;
end

function bar_swarm_plot(fits, condOrder, xticks, xlabelStr, colors, outPng, exp1Style)
% BAR_SWARM_PLOT  Bar plot of mean kappa and d' across conditions, with
% per-subject swarm dots and Bonferroni-corrected significance brackets
% (only drawn for p < 0.05).
%
%   bar_swarm_plot(fits, condOrder, xticks, xlabelStr, colors, outPng, exp1Style)
%
%   condOrder : numeric vector of condition values (e.g. [8 16 32])
%   xticks    : cell array of tick labels  (e.g. {'low','middle','high'})
%   colors    : cell array of hex strings, one per bar (matched to condOrder)
%   exp1Style : true -> Bonferroni across all C(n,2) pairs; otherwise raw paired-t

% Pivot fits to wide tables: rows = subject, cols = condition
subj  = unique(fits.subject);
nC    = numel(condOrder);
K     = nan(numel(subj), nC);
D     = K;
for i = 1:numel(subj)
    for j = 1:nC
        m = fits.subject == subj(i) & fits.condition == condOrder(j);
        if any(m)
            K(i,j) = fits.kappa(m);
            D(i,j) = fits.dprime(m);
        end
    end
end

% Drop subjects missing any condition
keep = ~any(isnan(K),2) & ~any(isnan(D),2);
K = K(keep,:); D = D(keep,:);
subj = subj(keep);

fig = figure('Color','w','Position',[100 100 950 450]);
panel(K, 'Precision (\kappa)',  subplot(1,2,1));
panel(D, "Strength (d')",        subplot(1,2,2));
exportgraphics(fig, outPng, 'Resolution', 150);
exportgraphics(fig, strrep(outPng,'.png','.pdf'));

    function panel(W, ylab, ax)
        axes(ax); hold(ax,'on');
        m   = mean(W, 1);
        sem = std(W,0,1) / sqrt(size(W,1));
        x   = 1:nC;
        for k = 1:nC
            bar(ax, k, m(k), 0.7, 'FaceColor', hex2col(colors{k}), ...
                'EdgeColor','k','FaceAlpha',0.6,'LineWidth',1);
        end
        errorbar(ax, x, m, sem, 'k.', 'CapSize', 8, 'LineWidth', 1.2);

        % subject swarm
        rng(0);
        for s = 1:size(W,1)
            jit = (rand(1,nC)-0.5)*0.16;
            scatter(ax, x+jit, W(s,:), 18, [0 0 0], 'filled', ...
                    'MarkerFaceAlpha',0.55);
        end
        ax.XTick = x;
        ax.XTickLabel = xticks;
        xlabel(ax, xlabelStr);
        ylabel(ax, ylab);
        ax.Box = 'off';

        % significance brackets
        pairs = nchoosek(1:nC, 2);
        m_corr = size(pairs,1);
        sigPairs = [];
        for r = 1:size(pairs,1)
            i = pairs(r,1); j = pairs(r,2);
            [~, ~, p] = paired_ttest(W(:,i), W(:,j));
            if exp1Style, p = min(1, p * m_corr); end
            if p < 0.05
                sigPairs(end+1,:) = [i j p]; %#ok<AGROW>
            end
        end
        if ~isempty(sigPairs)
            ymax = max(W(:));
            yl = ax.YLim;
            top = max(yl(2), ymax*1.15 + 0.3*size(sigPairs,1));
            ax.YLim = [yl(1) top];
            step = (top - ymax) / (size(sigPairs,1)+1);
            % shorter brackets first
            [~, ord] = sortrows([abs(sigPairs(:,2)-sigPairs(:,1)) sigPairs(:,1)]);
            sigPairs = sigPairs(ord,:);
            for r = 1:size(sigPairs,1)
                y = ymax + 0.4*step + (r-1)*step;
                a = sigPairs(r,1); b = sigPairs(r,2); p = sigPairs(r,3);
                h = (top-yl(1))*0.012;
                plot(ax,[a a b b],[y y+h y+h y],'k','LineWidth',1.2);
                text(ax,(a+b)/2, y+h, stars(p), 'HorizontalAlignment','center', ...
                     'VerticalAlignment','bottom','FontSize',12);
            end
        end
    end
end

function s = stars(p)
if p < 1e-4,  s = '****'; return; end
if p < 1e-3,  s = '***';  return; end
if p < 1e-2,  s = '**';   return; end
if p < 0.05,  s = '*';    return; end
s = 'ns';
end

function c = hex2col(h)
h = strrep(h,'#','');
c = [hex2dec(h(1:2)) hex2dec(h(3:4)) hex2dec(h(5:6))] / 255;
end

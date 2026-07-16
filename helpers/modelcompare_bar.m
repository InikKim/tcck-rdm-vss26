function modelcompare_bar(mc, pairs, expTitle, outPng)
% MODELCOMPARE_BAR  Count of subjects whose lowest-BIC model is each of
% A (fixed kappa, free d'), B (free kappa, fixed d'), Full.
%
%   modelcompare_bar(mc, {[8 16],'low vs middle'; ...}, 'Exp 1', outPng)

cmap = struct('A','#d35400','B','#3b7dd8','Full','#7f8c8d');
labels = {'A: fixed \kappa, free d''', 'B: free \kappa, fixed d''', ...
          'Full: free \kappa, free d'''};

nP = size(pairs,1);
fig = figure('Color','w','Position',[100 100 320*nP+100 380]);

barW = 0.25;
xc   = 1:nP;
counts = zeros(nP, 3);
N      = zeros(nP, 1);
for r = 1:nP
    pr = pairs{r,1};
    sub = mc(mc.cond_a == pr(1) & mc.cond_b == pr(2), :);
    [~, win] = min([sub.bic_A sub.bic_B sub.bic_full], [], 2);  % 1=A, 2=B, 3=Full
    counts(r,:) = [sum(win==1), sum(win==2), sum(win==3)];
    N(r) = height(sub);
end

ax = axes(fig); hold(ax,'on');
for m = 1:3
    h = bar(ax, xc + (m-2)*barW, counts(:,m), barW, ...
        'FaceColor', hex2col(cmap.(getModelKey(m))), ...
        'EdgeColor','k','LineWidth',0.8,'FaceAlpha',0.85);
    for r = 1:nP
        text(ax, xc(r)+(m-2)*barW, counts(r,m)+0.4, num2str(counts(r,m)), ...
            'HorizontalAlignment','center', 'FontWeight','bold','FontSize',10);
    end
end
ax.XTick = xc;
ax.XTickLabel = pairs(:,2);
xlabel(ax,'Condition pair'); ylabel(ax,'# subjects (lowest BIC)');
ylim(ax, [0, max(N)+5]);
title(ax, sprintf('%s — TCC+vonMises model comparison', expTitle));
legend(ax, labels, 'Location','northeast','Box','off');
ax.Box = 'off';

exportgraphics(fig, outPng, 'Resolution', 150);
exportgraphics(fig, strrep(outPng,'.png','.pdf'));
end

function k = getModelKey(i)
keys = {'A','B','Full'}; k = keys{i};
end

function c = hex2col(h)
h = strrep(h,'#','');
c = [hex2dec(h(1:2)) hex2dec(h(3:4)) hex2dec(h(5:6))] / 255;
end

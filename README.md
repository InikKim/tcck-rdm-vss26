# TCC_vonMises_rdm

Modeling visual working-memory recall errors for a moving-dot direction
task with the **Target Confusability Competition (TCC)** model
(Schurgin, Wixted & Brady, 2020), to ask whether degraded recall
reflects a weaker memory signal (d′), a wider similarity kernel
(precision, κ), or both.

| Experiment | Manipulation | Conditions | N |
|---|---|---|---|
| Exp 1 (`data_exp1.mat`) | motion-direction noise (SD) | 8° / 16° / 32° | 38 |
| Exp 2 (`data_exp2.mat`) | motion coherence | 0.6 / 1.0 | 36 |

Both datasets are already filtered to the subjects used in the reported
analysis; no further exclusion happens in the pipeline.

## Repo structure

```
run_all.m     single entry point -- runs the full pipeline
pipeline/     one function per analysis stage (step1..step6)
helpers/      underlying fitting, stats, and plotting functions
data/         data_exp1.mat, data_exp2.mat
output/       CSVs written by the pipeline
figure/       PNG/PDF figures written by the pipeline
docs/         project write-ups
```

## Usage

```matlab
run_all.m
```

Runs, in order: load data -> per-subject/condition TCC+vonMises fits ->
RM-ANOVA/paired t-tests on kappa & d' -> bar+swarm plots -> group fit
overlay -> 3-model (fixed-kappa / fixed-d' / full) BIC comparison. Each
`pipeline/step*.m` is also a standalone function if you want to run or
inspect one stage at a time.

**Requires:** MATLAB with the Statistics and Machine Learning Toolbox
and Optimization Toolbox (developed/tested on R2023b).

## Key finding

For the coherence manipulation (Exp 2), a reduced model with κ fixed
and only d′ free wins on BIC for most subjects — the apparent κ shift
in the full model reflects a κ↔d′ trade-off, not a real kernel-width
change. The motion-SD manipulation (Exp 1), by contrast, shifts both κ
and d′ genuinely.

## Reference

Schurgin, M. W., Wixted, J. T., & Brady, T. F. (2020). Psychophysical
scaling reveals a unified theory of visual memory strength. *Nature
Human Behaviour*, 4(11), 1156–1172.

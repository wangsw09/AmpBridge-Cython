Updated package structure

```text
AmpBridge/
  __init__.py
  linear_model.py           penalized lm, optimal tune, mse, amp, variable selection.
  amp_se.py                 amp-state-evolution related quantities, optimal-tuning, etc.
  mse_expand.py             included expansion of optimal mse in diff scenarios.
  two-stage.py              included afdp-atpp pair for 1 stage/2 stage/debaised/sis.
  cscalar/                  cython for scalar function;
    __init__.py
    proximal.pxd
    proximal.pyx            proximal function, derivatives for L_q, q >= 1
    gaussian.pxd
    gaussian.pyx            gaussian CDF, PDF, moments, expectation (not good to use)
    amp_mse.pxd
    amp_mse.pyx             mse, optimal tuning, etc for amp Lq
    wrapper.pyx             interface for outside python to access proximal and amp_mse
  coptimization/            plan to implement optimization algo for bridge regression
    __init__.py
    bridge_coord_desc.pyx   implement coordinate descent
  gaussian_tuning/
    __init__.py
    empirical_mse.py        calc empirical MSE and empirical tuning-mapping [wired result]
```

Timing

| functions   | regular cython | blas optimize |
| ---------   | ------- | ------ |
| prox_L1     | 281 ns | |
| prox_L2     | 273 ns | |
| prox_L1.5   | 263 ns | |
| prox_L1.2   | 4.2 us | |
| prox_L1.8   | 4.1 us | |
| prox_L2.2   | 1.5 us | |
| prox_L3.0   | 733 ns | |
| mse_L1      | 954 ns | |
| mse_L2      | 292 ns | |
| mse_L1.5    | 3.6 ms | |
| mse_L1.2    | 3.2 ms | |
| mse_L1.8    | 3.8 ms | |
| mse_L2.2    | 1.5 ms | |
| mse_L3.0    | 562 us | |
| optm_a_L1   | 723 us | |
| optm_a_L2   | 61  us | |
| optm_a_L1.5 | 4.0  s | |
| optm_a_L1.2 | 3.7  s | |
| optm_a_L1.8 | 5.0  s | |
| optm_a_L2.2 | 2.0  s | |
| optm_a_L3.0 | 688 ms | |
| lam_a_L1    | 22  us | |
| lam_a_L2    | 2.0 us | |
| lam_a_L1.5  | 119 ms | |
| lam_a_L1.2  | 107 ms | |
| lam_a_L1.8  | 154 ms | |
| lam_a_L2.2  | 68  ms | |
| lam_a_L3.0  | 22  ms | |
| a_lam_L1    | 933 us | |
| a_lam_L2    | 683 ns | |
| a_lam_L1.5  | 3.5  s | |
| a_lam_L1.2  | 3.6  s | |
| a_lam_L1.8  | 4.5  s | |
| a_lam_L2.2  | 2.4  s | |
| a_lam_L3.0  | 923 ms | |
| Bridge L1   (n=10K, p=2K)   | 3.1 s | 1.4 s |
| Bridge L2   (n=10K, p=2K)   | 3.1 s | 1.5 s |
| Bridge L1.5 (n=10K, p=2K)   | 3.2 s | 1.6 s |
| Bridge L1.2 (n=10K, p=2K)   | 3.4 s | 1.6 s |
| Bridge L1.8 (n=10K, p=2K)   | 3.6 s | 1.6 s |
| Bridge L2.2 (n=10K, p=2K)   | 3.0 s | 1.4 s |
| Bridge L3.0 (n=10K, p=2K)   | 3.3 s | 1.4 s |
| Bridge L1   (n=2K, p=10K)   | 6.4 m | 2.9 m |
| Bridge L2   (n=2K, p=10K)   | 12  m | 5.5 m |
| Bridge L1.5 (n=2K, p=10K)   | 12  m | 5.6 m |


8/30/2018
Finished a everything in a first version. Also finished the Examples.ipynb. Some issues remain:
1. The parameter order seems terrible for some of the functions. Should make them consistent; [fixed]
2. The result of empirical MSE seems not quite correct. Should double check whether there are some error in the coding, or it is purely the stability issues.
3. Should add more test cases. Also should add a way to benchmark the time: check if there are any online tables;
4. Optimize the bridge solver and the gaussian_tuning part with cython_blas
5. Rewrite the README.md [finished]
6. Add a flag which indicates the iter_max is reached;

The parameter order issues:
1. amp_se related functions: [fixed]
   * z, x, M, alpha, tau, epsilon, delta, sigma, q, tol
   * follow this order, skip if not presented
   * if one of the parameter is the main parameter, move it to beginning

The structure of the package:

```text
AmpBridge/
  __init__.py
  linear_model.py           penalized lm, optimal tune, mse, amp, variable selection.
  amp_se.py                 amp-state-evolution related quantities, optimal-tuning, etc.
  mse_expand.py             included expansion of optimal mse in diff scenarios.
  two-stage.py              included afdp-atpp pair for 1 stage/2 stage/debaised/sis.
  cscalar/                  cython for scalar function;
    __init__.py
    proximal.pxd
    proximal.pyx            proximal function, derivatives for L_q, q >= 1
    gaussian.pxd
    gaussian.pyx            gaussian CDF, PDF, moments, expectation (not good to use)
    amp_mse.pxd
    amp_mse.pyx             mse, optimal tuning, etc for amp Lq
    wrapper.pyx             interface for outside python to access proximal and amp_mse
  coptimization/            plan to implement optimization algo for bridge regression
    __init__.py
    bridge_coord_desc.pyx   implement coordinate descent
  gaussian_tuning/
    __init__.py
    empirical_mse.py        calc empirical MSE and empirical tuning-mapping [wired result]
'''

8/29/2018
Working on the SURE risk estimate and tuning part for bridge estimator. Trying to link blas/lapack. It seems that instead of compiling by ourself, scipy provides an interface for calling all the blas/lapack functions. We can just cimport them there. But we may have a requirement on the version of scipy (>=0.16?)

8/28/2018
We may want to put AFDP-ATPP just as function, but not class. The reason is people may have the need to change some of the parameters and to obtain a sequence of AFDP-ATPP pair. Putting them into one class seems tricky.

Finished the two-stage module.

Working on the optimal tuning for gaussian design problem. I think I will remove the AMP algorithm for now. I may add them in later.

To do:
1. Test mse-expand and two-stage
2. Copy the slope routine, then remove lib sub-modules;
3. Put useful components in clib.pyx into other files, remove clib.pyx
4. Re-check the linear_model.py, I don't like the current interface.
5. Implement AMP


8/27/2018
To do:
1. Finish the two-stage part
2. Test mse-expand and two-stage
3. Remove AMPtheory sub-module
4. Copy the slope routine, then remove lib sub-modules;
5. Put useful components in clib.pyx into other files, remove clib.pyx
6. Re-check the linear_model.py, I don't like the current interface.

8/26/2018
Switch back to work on this AmpBridge project, I want to finish it as soon as possible. Maybe in a week.

Previously I have already optimized the scalar part of the code in Cython, specifically: rewrote the proximal operators, and the function in amp mse for calculating the optimal tuning and optimal MSE;

Some components which can be further improved in the cscalar part include:
1. The Gaussian part can be implemented using the erf() function; no sure which is faster
   * Fixed, erf is much more accurate and 2 times faster;
2. Use c integration to replcae the scipy integration;
3. Use a better solver for the proximal operator of lq norm;


The next steps involve the following three main stages:
1. Write c optimized code for the Lq regression part;
   * Wrote one version with coordinate descent;
2. Merge the preivous optimized Amp c code into the current package;
3. Merge the new Lq regression part of c code into the current package.

Things to pay attention to:
1. The calculation of XTX is not memory-friendly. We may want to directly calculate its multiplication with a vector;

The structure of the package:

```text
AmpBridge/
  __init__.py
  linear_model.py       penalized lm, optimal tune, mse, amp, variable selection.
  amp_se.py             amp-state-evolution related quantities, optimal-tuning, etc.
  mse_expand.py         included expansion of optimal mse in diff scenarios.
  two-stage.py          included afdp-atpp pair for 1 stage/2 stage/debaised/sis.
  lib/                  [removed] supposed to be replaced by cscalar. to be removed.
    __init__.py
    base_class.py       [removed] contains discrete distribution class
    prox_func.py        [removed] except for lq, also contains SLOPE
    tools.py            [removed] bisect_search, multi-test, normalize
  cscalar/              cython for scalar function;
    __init__.py
    proximal.pxd
    proximal.pyx        proximal function, derivatives for L_q, q >= 1
    gaussian.pxd
    gaussian.pyx        gaussian CDF, PDF, moments, expectation (not good to use)
    amp_mse.pxd
    amp_mse.pyx         mse, optimal tuning, etc for amp Lq
    wrapper.pyx         interface for outside python to access proximal and amp_mse
    clib.pyx            [removed] old cython module; contains bridge optimizer
  coptimization/        plan to implement optimization algo for bridge regression
    __init__.py
    bridge_coord_desc.pyx   implement coordinate descent
  AMPtheory/            [removed]
    __init__.py         [removed]
    AMPbasic.py         [removed] class for amp mse fns;
    mseAnalysis.py      [removed] expansion of optimal mse in diff scenes.
'''


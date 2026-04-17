+++
title = "Modelling Mode Coupling Instability for Brake Noise"
description = ""
weight = 1
date = "2025-10-27"
_updated = "2025-10-27"

[taxonomies]
tags=["EN", "TUM", "Structural Dynamics", "BMW"]
[extra]
local_image = "/media/strukturdynamiktumbmw.png"
link_to = "./strukturdynamiktumbmw/"
read_time = true
comment = true
toc = true
_tldr = ""
banner = true
archive = false
+++

# Links
- <a href="/downloadables/strukturdynamiktumbmw/Modeling_Mode_Coupling_Instability_for_Brake_Noise.pdf" download="Modeling_Mode_Coupling_Instability_for_Brake_Noise.pdf">Download Full Report PDF</a>

# Modeling Mode Coupling Instability for Brake Noise

*Co-authored with Yago Bas Fernandez | Supervisor: Markus Sailer (BMW) | TUM*

This project investigates the **mode-coupling instability** mechanism behind brake moan using a minimal model approach. Starting from a 2DOF friction oscillator, the work spans theoretical stability analysis, experimental calibration, and TMD countermeasure design.

---

### The Problem

Brake moan (100–500 Hz) is a self-excited vibration caused by **dynamic instability** in the wheel brake system. Unlike stick-slip phenomena, mode-coupling instability can arise even with a *constant* friction coefficient — making it particularly insidious. The mechanism: friction forces introduce an asymmetric stiffness matrix, causing two structural eigenmodes to coalesce at a critical friction value μ_crit, after which one mode develops a positive growth rate (σ > 0) and vibrations amplify exponentially.

---

### Minimal Model & Stability Analysis

The core model is a 2DOF friction oscillator (Schroth, 2003) with orthogonal springs, dampers, and an angled coupling spring. Stability is assessed via eigenvalue analysis of the state-space matrix — the sign of the real part σ determines whether perturbations grow or decay.

For the baseline undamped system, the critical friction coefficient was found analytically: **μ_crit = 0.362**. Parameter studies showed that:

- Increasing coupling stiffness *k* or horizontal stiffness *k_x* drives the system toward coalescence
- Vertical stiffness *k_y* can **restore stability** by detuning the eigenfrequencies
- Viscous damping shifts the stability boundary to higher friction levels, delaying the onset of squeal

Time-domain simulations confirmed all three regimes — stable bounded oscillations, borderline coalescence, and exponentially diverging instability.

---

### Calibration to Real Data

The model was calibrated to match a **260 Hz brake moan** measured on a real brake caliper, targeting a growth rate of +12.8 s⁻¹. Nonlinear extensions (variable coupling angle β, time-harmonic stiffness variation) confirmed that parametric fluctuations crossing the stability boundary are sufficient to sustain and amplify instability even when stable intervals exist.

---

### Tuned Mass Damper Design

A passive **Tuned Mass Damper (TMD)** was added to the vertical DOF to counteract the instability. The TMD oscillates out of phase with the primary system, dissipating energy through its local damper. A parameter study over mass ratio μ_TMD and damping ratio ζ_TMD identified the optimal configuration:

| Parameter | Value |
|-----------|-------|
| Mass ratio μ_TMD | 5% |
| Damping ratio ζ_TMD | 10–15% |

This configuration places the system well within the stable region while minimising added weight. Robustness was validated under three transient scenarios — constant sinusoidal drift, progressive stiffness growth, and a full excursion-and-recovery cycle — confirming suppression even at stiffness ratio swings of ±30%.

---

### Nondimensional Framework

Using the Buckingham Pi theorem, two dimensionless groups were identified as governing the instability:

- **Π₁ = μ · K_N** — the friction-coupling parameter (drives asymmetry)
- **Π₂ = ω₁/ω₂** — the mode frequency ratio (instability peaks at Π₂ ≈ 1)

Stability maps in Π₁–Π₂ space and in the TMD design space (m_R vs ζ_TMD) generalise the results to any brake system with equivalent nondimensional parameters.
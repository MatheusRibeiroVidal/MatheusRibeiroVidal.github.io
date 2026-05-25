+++
title = "SIGMA model Validation in MGLET"
description = "Validation of LES Sub-Grid-Scale model SIGMA in MGLET"
weight = 1
date = "2025-10-09"
updated = "2025-04-20T10:54:17"
authors = ["Matheus"]
draft = false

[taxonomies]
tags=["EN", "CFD", "TUM", "LES"]
[extra]
local_image = "/media/hydromechanicstum.gif"
link_to = "./hydromechanicstum/"
read_time = true
comment = true
toc = true
_tldr = ""
banner = true
archive = false
+++
# Links
- [GitHub repo](https://github.com/tum-hydromechanics/tum-mglet-base)
- [Open Source MGLET WIKI](https://collab.dvb.bayern/spaces/TUMopensourcemgletwiki/pages/448366188/Open-source+MGLET+Wiki+Startseite) 

# SIGMA Model Validation in MGLET

*Chair of Hydromechanics, TUM | Supervisor: Yoshiyuki Sakai*

This project validates the **SIGMA Sub-Grid-Scale (SGS) model** for Large Eddy Simulation (LES) within the solver **MGLET**, using turbulent flow over a cylinder at Reynolds number **Re = 3,900** as the benchmark case. Predictions are compared against high-fidelity Direct Numerical Simulation (DNS) data from Ooi et al. (2022).

---

## The Problem

At Re = 3,900 the cylinder wake is fully turbulent, generating a von Kármán vortex street, dual shear layers, and a recirculation bubble, yet remains computationally tractable. This makes it an ideal case to assess how well an SGS model reproduces the small-scale dissipation that drives drag, lift fluctuations, and Reynolds stresses without resolving every scale directly.

---

## Approach

The study runs on two parallel tracks at matched conditions:

- **Mesh convergence (Smagorinsky):** three resolutions (N_D = 64, 96, 128) with CFL-consistent timesteps (dt ∝ Δx, CFL ≈ 0.96) to isolate grid effects.
- **SGS model comparison (high-res):** Smagorinsky vs. **SIGMA** vs. WALE at N_D = 128, ranking dissipation strategies for this geometry.

Simulations use the Ghostcell Immersed Boundary method (1 m cylinder STL), the SIP pressure solver, and collect 23 turbulence statistics over a 50 s window after a 350 s flow-development phase, plus transient snapshots over the final ~1.5 shedding cycles.

---

## Validation Targets (DNS, Ooi et al. 2022)

| Metric                           | DNS value |
| -------------------------------- | --------- |
| Drag coefficient C_D             | 0.996     |
| Lift RMS C'_L                    | 0.134     |
| Strouhal number St_v             | 0.21      |
| Recirculation length L_r/D       | 1.53      |
| Reynolds stress peak u'u'/U²_max | ~0.25     |

**Expected SGS ranking:** WALE ≥ SIGMA > Smagorinsky, with SIGMA better preserving coherent structures than the isotropic Smagorinsky baseline.

---

## Tools

MGLET (incompressible LES + IB) · Gridgen3 mesh generation · HDF5 checkpoints · Python (NumPy/SciPy/Matplotlib) post-processing · OpenMPI on the chair's compute nodes.


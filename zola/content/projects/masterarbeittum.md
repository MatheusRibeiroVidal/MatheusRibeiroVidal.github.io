+++
title = "Thermal Management of Laser Deflection Systems: A Parametric CFD Study Using LES"
description = "A high-fidelity LES study of convective cooling in laser deflection systems, developing a validated simulation framework for thermal design at RAYLASE GmbH."
weight = 1
date = "2026-05-26"
_updated = "2026-05-26"
draft = true

[taxonomies]
tags=["EN", "TUM", "RAYLASE", "CFD", "LES", "Heat Transfer", "Computational Mechanics", "Optomechanics", "Convection", "MGLET"]
[extra]
local_image = "/media/masterarbeittum.png"
link_to = "/projects/masterarbeittum/"
comment = true
read_time = true
banner = true
toc = true
mathjax = true
mathjax_dollar_inline_enable = true
+++

# Links
- <a href="/downloadables/masterarbeittum/masterarbeittum.pdf" download="masterarbeittum.pdf">Download PDF</a>
- [GitHub repo](https://github.com/MatheusRibeiroVidal)

# Thermal Management of Laser Deflection Systems

*Master's Thesis (in progress) | Associate Professorship of Hydromechanics, TUM — in partnership with RAYLASE GmbH | Examiner: Prof. Dr. Michael Manhart · Supervisor: Dr. Yoshiyuki Sakai (TUM) · Dr. Thomas Reimann (RAYLASE)*

This thesis develops a **physics-based simulation capability** for the thermal management of high-precision laser deflection systems. Using **large-eddy simulation (LES)** of convective cooling inside a representative optomechanical enclosure, the work establishes a validated, generalisable framework that lets RAYLASE explore the thermal design space systematically and at reduced cost.

---

## The Problem

RAYLASE GmbH develops high-precision laser deflection and beam-control systems for industrial and scientific use, where **thermal management is a core design challenge**. The temperature field affects performance through two coupled mechanisms:

1. Heat must be removed efficiently enough to keep components within safe operating bounds.
2. Thermal gradients in the surrounding air alter the local refractive index and deform optical surfaces, producing **laser beam jitter** that degrades pointing accuracy.

The work combines the LES expertise of the **TUM Associate Professorship of Hydromechanics** (via its in-house finite-volume solver **MGLET**) with the application knowledge and experimental infrastructure of RAYLASE.

---

## Research Objectives

Three core objectives, with two optional extensions if time permits:

- **RO 1 — Characterise the mixed convection regime.** Use LES in MGLET to resolve the time-averaged and instantaneous thermal-flow fields where jet-driven and buoyancy-driven flows are simultaneously active. Quantify local and area-averaged Nusselt numbers, mean mirror temperature rise $\Delta T$, and the Richardson number. This produces the **validated high-fidelity reference dataset** on which everything else builds.
- **RO 2 — Assess the thermal significance of mirror oscillation (a priori).** Use order-of-magnitude and time-scale arguments to decide whether scanning motion (frequencies $\sim 1\,\mathrm{kHz}$, amplitudes $\pm 11^{\circ}$) meaningfully alters the time-averaged field. If the air's thermal relaxation time greatly exceeds the mechanical period, **steady-boundary simulations suffice** — a major practical simplification.
- **RO 3 — Rank cooling sensitivity to design variables.** Run ~4 production-quality LES cases varying the most influential dimensionless groups, testing whether the a priori scaling holds and producing transferable design guidance. A variable shown to have *negligible* influence is treated as an equally valuable result.

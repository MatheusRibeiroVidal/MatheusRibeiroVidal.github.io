+++
title = "Next-gen Simulation: CAD-Integrated Isogeometric Analysis, Shell Structures, and Enhanced Visualization Frameworks"
description = "Software Lab Project at TUM"
weight = 2
date = "2025-03-23"
authors = ["Matheus"]

[taxonomies]
tags=["EN","TUM", "IGA", "Open Source"]
[extra]
local_image = "/media/softwarelab.png"
link_to = "./softwarelab/"
comment = true
read_time = true
banner = true
mathjax_dollar_inline_enable = true
mathjax = true
+++

# Links
- <a href="https://www.cee.ed.tum.de/fileadmin/w00cbe/ccbe/Softwarelab/2025/22_SL2025_Description_IGA.pdf">Official description</a>
- <a href="/downloadables/pg2/Software_Lab_Report.pdf" download="Software_Lab_Report.pdf">Download Full Report PDF</a>

# Third Medium Contact – Material Modeling for Contact Problems

*Software Lab 2025 | TUM School of Engineering and Design*

Self-contacting geometries in the IGAeasy framework produce non-physical deformation behavior under excessive loads. To address this, I implemented a **Third Medium Contact (TMC)** material model — a continuum-based approach that introduces a virtual "third medium" between potentially contacting surfaces, avoiding the computational overhead of traditional discrete contact detection algorithms.

---

## Formulation

The strain energy density is decomposed into isotropic and anisotropic contributions:

**Isotropic part** — a hyperelastic formulation in terms of the principal invariants of the right Cauchy-Green tensor, with a stress-free reference configuration enforced analytically.

**Anisotropic part** — provides directional stiffness aligned with the contact normal, governed by a pseudo-invariant J₄ = **n** · **C** · **n** and an exponent controlling sensitivity.

**Dynamic stiffness activation** — the key feature of the formulation. A compression-triggered stiffness cM activates only when det(**F**) falls below a prescribed threshold, following a power law cM = a₅ [det(**F**)]ⁱ. This creates a compressible cushion layer that offers negligible resistance under tension but rapidly stiffens under contact compression.

The full pipeline — strain energy, Second Piola-Kirchhoff stress, and material tangent stiffness — was derived and implemented in both 2D and 3D, with the tangent stored in Voigt notation (3×3 for plane problems, 6×6 for 3D) for direct use in element stiffness assembly.

---

## Implementation

The model was implemented as a Python class `ThirdContactMaterial` within the IGAeasy framework, exposing:

- `strain_energy(F, n)` — strain energy density evaluation
- `compute_stress_2D / 3D(F, n)` — Second Piola-Kirchhoff stress
- `get_C_voigt_cart_2D / 3D(F, n)` — material tangent in Voigt notation

If no fiber direction is provided, the model defaults to purely isotropic behavior.

---

## Results

A parameter sweep over det(**F**) confirmed the compression-triggered activation: stiffness remains zero above the threshold and follows the prescribed power law below it, verifying the intended behavior.

A 2D membrane example, a rectangular domain compressed against a fixed edge, demonstrated large deformations prior to stiffness activation, consistent with the expected soft-layer response.

**Convergence challenges** were encountered near the activation threshold, where the sudden stiffness jump ill-conditions the Newton-Raphson tangent matrix. Load stepping produced partial results through the pre-contact phase, but full convergence through activation remains an open problem with the current solver.

---

## Limitations & Future Work

- No tangential contact behavior — friction at the interface is not captured
- Nonlinear solver improvements needed: adaptive load stepping near the threshold would help
- A systematic parameter sensitivity study (a₁–a₅, exponent i, tolerance) would provide practical design guidelines
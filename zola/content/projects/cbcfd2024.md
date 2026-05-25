+++
title = "Numerical Exploration On The Effect Of The Hydrodynamic Drag Coefficient Upon Topside Loading In Steel Tube Umbilical Risers"
description = "CBCFD 2024 paper on how the drag coefficient drives topside tension in umbilical risers."
weight = 4
date = "2024-09-18"
authors = ["Matheus"]

[taxonomies]
tags=["EN","Marine Engineering", "CFD", "OrcaFlex", "Congress", "Offshore", "Hydrodynamics", "Risers", "Paper", "Subsea"]
[extra]
local_image = "/media/cbcfd2024.png"
link_to = "./cbcfd2024/"
comment = true
banner = true
+++


# Links
- [Brazilian Congress of Computational Fluid Dynamics 2024](https://www.cbcfd.com.br/cbcfd-2024/page/3730-home)
- <a href="/downloadables/cbcfd2024/CBCFD_100439.pdf" download="CBCFD_100439.pdf">Download CBCFD 2024 Paper PDF</a>
- DOI: <a href="https://doi.org/10.17648/cbcfd-2024-192052">10.17648/cbcfd-2024-192052</a>

# Numerical Exploration on the Effect of the Hydrodynamic Drag Coefficient upon Topside Loading in Steel Tube Umbilical Risers

*Co-authored with Filipe C. Coutinho (Prysmian) | Presented at the IV Brazilian Congress of Computational Fluid Dynamics (CBCFD 2024), Vitória-ES, 18–20 September 2024*

This paper investigates how the **hydrodynamic drag coefficient (C<sub>D</sub>)** influences the **topside effective tension** of a steel tube umbilical riser installed in Brazilian offshore ultra-deep waters. Using batches of finite element analysis structural simulations in **OrcaFlex**, the work maps the sensitivity of the system's critical design load to the drag input and assesses how conservative the industry-standard value of 1.2 really is.

---

## The Problem

Umbilicals are heterogeneous subsea cabling systems, bundling hoses, power and signal cables, fiber optics, steel tubes, armor wires and polymeric sheaths, that connect floating production units (FPUs) to subsea equipment. When subjected mainly to dynamic wave and current loading they are classified as **risers**.

The complex, mixed cross-section makes structural assessment dependent on extensive global dynamic analyses covering functional, environmental and accidental loads. Among these, the **topside effective tension** is frequently the critical design point (API 17E, 2017). The drag coefficient feeds directly into the current-induced load and displacement of the riser, yet it spans a wide range, so understanding its impact on topside loading is key to both safe and efficient cross-section design.

---

## Methodology

A representative **steel tube umbilical** was modelled and simulated in OrcaFlex under typical Brazilian ultra-deep-water conditions.

**Cross-section**, 13 × ½" steel tubes (1.2 mm wall thickness) inside an outer polymeric sheath:

| Umbilical technical parameter | Value |
|-------------------------------|-------|
| Outside diameter | 72.8 mm |
| Nominal mass (in air, tubes filled) | 9.17 kg/m |
| Operational minimum bending radius | 5.6 m |

**Global configuration**, catenary arrangement at a water depth of **2150 m**, with a calculated static topside effective tension of **112.14 kN**. A wave scatter table generated load cases covering all permutations of typical wave and current profiles.

**Parametric study**, **7 batches** of simulations were run with drag coefficients ranging from **0.28 to 1.5**, spanning the range expected for a circular cylinder in normal flow (0.28–1.2 per Orcina, 2024), where C<sub>D</sub> depends primarily on Reynolds number and surface finish.

---

## Results & Discussion

Plotting maximum topside effective tension against drag coefficient (normalised to the C<sub>D</sub> = 1.2 baseline) revealed a **roughly linear growth** of topside tension with C<sub>D</sub>.

Two practical implications follow:

- **Simulation correlation**, because the response is near-linear, refining the drag input is an effective lever for matching simulations to measured topside tension when predictions and field data diverge.
- **Design efficiency**, in the engineering phase, more accurate drag values allow structural capability checks while streamlining the cross-section design rather than over-building it.

Against industry standards, maximum values near **C<sub>D</sub> = 1.1** for rough unshielded circular cylinders (API, 2007) and **1.0–1.2** for spiral wire with sheathing over a cylinder (DNV-RP-C205, 2017), the results indicate that a drag coefficient of **1.2 can be interpreted as a conservative choice** for umbilical design and dynamic analysis.

---

## Key Takeaways

- Topside effective tension scales approximately **linearly** with the hydrodynamic drag coefficient.
- Drag accuracy is a meaningful tuning parameter for correlating global dynamic analyses with real-world behaviour.
- **C<sub>D</sub> = 1.2** is a defensibly conservative value for steel tube umbilical riser design.



# Amber Protocol for Complexed Protein Simulation and PBSA Evaluation 
<img src="https://github.com/user-attachments/assets/41cbbb8f-83e7-4fe9-b25a-1a5d1019caa7" width=900 height=500>

This repository is for running a complexed simulation of a protein and its ligand. It uses the HMG-CoA Reductase docked with NAP and HMG as a reference example. The PDF instructions relate to running amber through job submission on a TARA HPC server. A plethora of files are available and utilized largely from a core 'qm_protocols' directory. These scripts encompass running parameterization of the complexed system, NVT and NPT equilibration, and production runs. In addition, there are a variety of scripts for running standard RMSD/RMSF analyses through python and/or R. Finally, there are methods for running a PBSA analysis using the MMPBSA.py program within Amber. 

For an example: 

Examining pt1_input-parameterization_2024.sh will reveal the methodology employed to parameterize the initial system using an optimized PDB file of the complexed structure. It will run through the complex, the solitary protein, and the solitary ligand files to craft amber-ready inputs for subsequent steps. This method also uses Gaussian to acquire various rep charges, although I have supplied these within the <ligfiles> directory of <qm_protocol>.  

These scripts require a large number of dependencies that were curated on the job submission server. While these protocols work 'out-of-the-box' on that system, they will likely need a series of tweaks in order to effectively run on non-specific HPCs or local environments. Nonetheless, I hope these serve as a strong springboard for those who may be struggling to fine-tune simulation runs and analysis strategies of complexed systems. 

# TOOLS INSTALLATION

## ABOUT THIS DOCUMENT 

This document is intended for persons who want to install part or all of the tools provided with the PHYEX package.
   
This document is written using the markdown language. With pandoc, it can be converted to HTML (pandoc -s \<filename\>.md -o \<filename\>.html) or PDF (pandoc -s \<filename\>.md -o \<filename\>.pdf).

## INSTALLATIONS

1. IAL REFERENCE PACK
   The check\_commit\_ial.sh script, by default, build a pack on top of a precompiled pack.
   This precompiled pack must be build beforehand. Instructions can be found in
   [INSTALL\_pack\_ial](./INSTALL_pack_ial.md)

2. MESONH REFERENCE PACK
   The reference pack for Meso-NH must be installed. Instructions can be found in
   [INSTALL\_pack\_mesonh](./INSTALL_pack_mesonh.md)

3. AUTOMATIC INSTALLATION
   The script INSTALL.sh (INSTALL.sh -h for help) handles the installation of:

     - the pyfortool tool needed by the different check\_commit\_\*.sh scripts, depending on options used at execution.
     - the testprogs reference data which are needed by the script check\_commit\_testprogs.sh. The manual
       generation of these data is explained in [INSTALL\_testprogs](./INSTALL_testprogs.md)

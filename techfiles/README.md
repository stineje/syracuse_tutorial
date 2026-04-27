# GF180MCU Open-Source PDK Setup

This repository provides guidance and supporting files for working with the **GF180MCU Process Design Kit (PDK)** in open-source VLSI design flows.

The GF180MCU platform is a 180nm mixed-signal CMOS technology developed for open-source semiconductor design and education. It is widely used for analog, digital, mixed-signal, and educational chip design projects, including open-source tapeout programs and academic research.

---

## Official GF180MCU PDK Source

The official Google-supported GF180MCU PDK repository is located here:

https://github.com/google/gf180mcu-pdk

This repository contains:

- Technology files
- Standard-cell support
- Design rules
- Documentation
- SPICE models
- Layout support files
- Process information for open-source design flows

Please refer to the official repository for the latest updates and technology documentation.

---

## Recommended Installation Method

The recommended installation flow for the GF180MCU PDK is through **Open_PDKs**, maintained by Tim Edwards.

Open_PDKs provides:

- Proper installation flow
- Magic support
- Netgen LVS support
- Xschem integration
- Ngspice support
- PDK configuration for open-source toolchains
- Standardized installation for reproducible research and education

Official Open_PDKs repository:

https://github.com/rtimothyedwards/open_pdks

---

## Installation Recommendation

Rather than manually copying files from the GF180MCU repository, install the PDK using the Open_PDKs flow.

Typical flow:

```bash
git clone https://github.com/rtimothyedwards/open_pdks.git
cd open_pdks
./configure --enable-gf180mcu-pdk
make
sudo make install

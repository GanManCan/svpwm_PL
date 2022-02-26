## SVPWM_PL

The ZYNQ based state vector pulse width modulation (SVPWM) three-phase induction motor controller.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

<!-- Evaluate using doctoc to generate TOC -->

## Introduction

SVPWM_PL is still under initial development and does not have a working release. 

Open-loop control for three-phase motor controller using a Zynq-7000 based System On Chip.  

This project on contains the programmable-logic for the FPGA portion of the Zynq.


## Features

The features of SVPWM_PL: 
* Three-phase output State Vector Pulse Width Modulation SVPWM
* VHDL unit test - testbench

## Project Structure 

The [source folder](https://github.com/GanManCan/svpwm_PL/tree/main/svpwm_PL.srcs/sources_1/new) contains the custom VHDL files. 

The [diagrams folder](https://github.com/GanManCan/svpwm_PL/tree/main/docs/Diagrams) contains various state diagrams used in the SVPWM code. 


## Version Information 
* Xilinx Vivado 2020.1
* Xilinx Vitis 2020.1

## Build Process

To build the Xilinx Project: 

- Install [Vivado 2020.1](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html)
- Clone or download the repository


To run the testbenches: 

- Install [ModelSim v2]
- Install [VUnit](https://vunit.github.io/index.html#), an open source VHDL compatible unit testing frame work.  Follow this [guide](https://vhdlwhiz.com/getting-started-with-vunit/) for additional installation and usage instructions. 


## References
* SVPWM Algorithm Design 
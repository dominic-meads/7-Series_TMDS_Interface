# 7-Series_TMDS_Interface

This project is based off XAP495 "Implementing a TMDS Video Interface in the Spartan-6 FPGA"
available: https://www.xilinx.com/support/documentation/application_notes/xapp495_S6TMDS_Video_Interface.pdf

Although this application guide is for the Spartan-6, I will try and use 7-series resources to update it. 

The version 1.0 goal is to use the Rx and Tx modules described in the application to design a 480p HDMI passthrough (video only)
on an ARTY Z7 board from Digilent. In version 2.0, I would like to increase resolution to 720p or 1080p and use the Genesys 2 
Kintex-7 board. 

Version 1.0 
480p @ 60 Hz requires:
- 25 MHz pixel clock
- Serial data rate of 250 Mb/s 

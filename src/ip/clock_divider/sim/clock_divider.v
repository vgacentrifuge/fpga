//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
//Date        : Thu Nov  3 12:23:01 2022
//Host        : dmpro-Aspire-A515-41G running 64-bit Linux Mint 20.1
//Command     : generate_target clock_divider.bd
//Design      : clock_divider
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "clock_divider,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=clock_divider,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "clock_divider.hwdef" *) 
module clock_divider
   (clk100,
    clk25);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK100 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK100, CLK_DOMAIN clock_divider_clk100, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input clk100;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK25 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK25, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output clk25;

  wire clk100_1;
  wire clk_wiz_0_clk_out1;

  assign clk100_1 = clk100;
  assign clk25 = clk_wiz_0_clk_out1;
  clock_divider_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(clk100_1),
        .clk_out1(clk_wiz_0_clk_out1));
endmodule

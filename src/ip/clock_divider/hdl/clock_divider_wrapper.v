//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
//Date        : Thu Nov  3 12:23:01 2022
//Host        : dmpro-Aspire-A515-41G running 64-bit Linux Mint 20.1
//Command     : generate_target clock_divider_wrapper.bd
//Design      : clock_divider_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module clock_divider_wrapper
   (clk100,
    clk25);
  input clk100;
  output clk25;

  wire clk100;
  wire clk25;

  clock_divider clock_divider_i
       (.clk100(clk100),
        .clk25(clk25));
endmodule

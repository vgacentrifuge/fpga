//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
//Date        : Thu Nov 10 11:16:27 2022
//Host        : dmpro-Aspire-A515-41G running 64-bit Linux Mint 21
//Command     : generate_target pixel_FIFO_dac_wrapper.bd
//Design      : pixel_FIFO_dac_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module pixel_FIFO_dac_wrapper
   (FIFO_READ_0_empty,
    FIFO_READ_0_rd_data,
    FIFO_READ_0_rd_en,
    FIFO_WRITE_0_full,
    FIFO_WRITE_0_wr_data,
    FIFO_WRITE_0_wr_en,
    rd_clk_0,
    rst_0,
    wr_clk_0);
  output FIFO_READ_0_empty;
  output [37:0]FIFO_READ_0_rd_data;
  input FIFO_READ_0_rd_en;
  output FIFO_WRITE_0_full;
  input [37:0]FIFO_WRITE_0_wr_data;
  input FIFO_WRITE_0_wr_en;
  input rd_clk_0;
  input rst_0;
  input wr_clk_0;

  wire FIFO_READ_0_empty;
  wire [37:0]FIFO_READ_0_rd_data;
  wire FIFO_READ_0_rd_en;
  wire FIFO_WRITE_0_full;
  wire [37:0]FIFO_WRITE_0_wr_data;
  wire FIFO_WRITE_0_wr_en;
  wire rd_clk_0;
  wire rst_0;
  wire wr_clk_0;

  pixel_FIFO_dac pixel_FIFO_dac_i
       (.FIFO_READ_0_empty(FIFO_READ_0_empty),
        .FIFO_READ_0_rd_data(FIFO_READ_0_rd_data),
        .FIFO_READ_0_rd_en(FIFO_READ_0_rd_en),
        .FIFO_WRITE_0_full(FIFO_WRITE_0_full),
        .FIFO_WRITE_0_wr_data(FIFO_WRITE_0_wr_data),
        .FIFO_WRITE_0_wr_en(FIFO_WRITE_0_wr_en),
        .rd_clk_0(rd_clk_0),
        .rst_0(rst_0),
        .wr_clk_0(wr_clk_0));
endmodule

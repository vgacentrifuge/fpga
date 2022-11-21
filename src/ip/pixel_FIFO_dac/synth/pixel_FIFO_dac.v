//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
//Date        : Mon Nov 21 16:52:04 2022
//Host        : dmpro-Aspire-A515-41G running 64-bit Linux Mint 21
//Command     : generate_target pixel_FIFO_dac.bd
//Design      : pixel_FIFO_dac
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "pixel_FIFO_dac,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=pixel_FIFO_dac,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "pixel_FIFO_dac.hwdef" *) 
module pixel_FIFO_dac
   (FIFO_READ_0_empty,
    FIFO_READ_0_rd_data,
    FIFO_READ_0_rd_en,
    FIFO_WRITE_0_full,
    FIFO_WRITE_0_wr_data,
    FIFO_WRITE_0_wr_en,
    rd_clk_0,
    rst_0,
    wr_clk_0);
  (* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 FIFO_READ_0 EMPTY" *) output FIFO_READ_0_empty;
  (* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 FIFO_READ_0 RD_DATA" *) output [37:0]FIFO_READ_0_rd_data;
  (* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 FIFO_READ_0 RD_EN" *) input FIFO_READ_0_rd_en;
  (* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE_0 FULL" *) output FIFO_WRITE_0_full;
  (* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE_0 WR_DATA" *) input [37:0]FIFO_WRITE_0_wr_data;
  (* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE_0 WR_EN" *) input FIFO_WRITE_0_wr_en;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.RD_CLK_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.RD_CLK_0, CLK_DOMAIN pixel_FIFO_dac_rd_clk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input rd_clk_0;
  input rst_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.WR_CLK_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.WR_CLK_0, CLK_DOMAIN pixel_FIFO_dac_wr_clk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input wr_clk_0;

  wire FIFO_READ_0_1_EMPTY;
  wire [37:0]FIFO_READ_0_1_RD_DATA;
  wire FIFO_READ_0_1_RD_EN;
  wire FIFO_WRITE_0_1_FULL;
  wire [37:0]FIFO_WRITE_0_1_WR_DATA;
  wire FIFO_WRITE_0_1_WR_EN;
  wire rd_clk_0_1;
  wire rst_0_1;
  wire wr_clk_0_1;

  assign FIFO_READ_0_1_RD_EN = FIFO_READ_0_rd_en;
  assign FIFO_READ_0_empty = FIFO_READ_0_1_EMPTY;
  assign FIFO_READ_0_rd_data[37:0] = FIFO_READ_0_1_RD_DATA;
  assign FIFO_WRITE_0_1_WR_DATA = FIFO_WRITE_0_wr_data[37:0];
  assign FIFO_WRITE_0_1_WR_EN = FIFO_WRITE_0_wr_en;
  assign FIFO_WRITE_0_full = FIFO_WRITE_0_1_FULL;
  assign rd_clk_0_1 = rd_clk_0;
  assign rst_0_1 = rst_0;
  assign wr_clk_0_1 = wr_clk_0;
  pixel_FIFO_dac_fifo_generator_0_0 fifo_generator_0
       (.din(FIFO_WRITE_0_1_WR_DATA),
        .dout(FIFO_READ_0_1_RD_DATA),
        .empty(FIFO_READ_0_1_EMPTY),
        .full(FIFO_WRITE_0_1_FULL),
        .rd_clk(rd_clk_0_1),
        .rd_en(FIFO_READ_0_1_RD_EN),
        .rst(rst_0_1),
        .wr_clk(wr_clk_0_1),
        .wr_en(FIFO_WRITE_0_1_WR_EN));
endmodule

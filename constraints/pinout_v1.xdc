set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33 DIRECTION IN} [get_ports gclk100]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {dataclkin_2_IBUF}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {clk_wiz/inst/clk_in1_clk_wiz_160}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {dacclk_out_0_OBUF}]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports gclk100]

#create_interface adc_tvp7002_2
#set_property INTERFACE adc_tvp7002_2 [get_ports { colour_bus_2[0] colour_bus_2[1] colour_bus_2[2] colour_bus_2[3] colour_bus_2[4] colour_bus_2[5] colour_bus_2[6] colour_bus_2[7] colour_bus_2[8] colour_bus_2[9] colour_bus_2[10] colour_bus_2[11] colour_bus_2[12] colour_bus_2[13] colour_bus_2[14] colour_bus_2[15] dataclkin_2 vsin_2 hsin_2 }]
#set_property -dict { PACKAGE_PIN A2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[0]}]
#set_property -dict { PACKAGE_PIN B2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[1]}]
#set_property -dict { PACKAGE_PIN B1 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[2]}]
#set_property -dict { PACKAGE_PIN C2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[3]}]
#set_property -dict { PACKAGE_PIN C1 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[4]}]
#set_property -dict { PACKAGE_PIN D3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[5]}]
#set_propset_property -dict { PACKAGE_PIN D3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[5]}]
#erty -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[6]}]
#set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[7]}]
#set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[8]}]
#set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[9]}]
#set_property -dict { PACKAGE_PIN C3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[10]}]
#set_property -dict { PACKAGE_PIN B7 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[11]}]
#set_property -dict { PACKAGE_PIN A7 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[12]}]
#set_property -dict { PACKAGE_PIN B6 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[13]}]
#set_property -dict { PACKAGE_PIN B5 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[14]}]
#set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_2[15]}]
#set_property -dict { PACKAGE_PIN E5 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports dataclkin_2]
#set_property -dict { PACKAGE_PIN E2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports vsin_2]
#set_property -dict { PACKAGE_PIN D1 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports hsin_2]
# set_property -dict { PACKAGE_PIN E1 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports fidin_2]

create_interface adc_tvp7002_1
set_property INTERFACE adc_tvp7002_1 [get_ports { colour_bus_1[0] colour_bus_1[1] colour_bus_1[2] colour_bus_1[3] colour_bus_1[4] colour_bus_1[5] colour_bus_1[6] colour_bus_1[7] colour_bus_1[8] colour_bus_1[9] colour_bus_1[10] colour_bus_1[11] colour_bus_1[12] colour_bus_1[13] colour_bus_1[14] colour_bus_1[15] dataclkin_1 vsin_1 hsin_1 }]
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[0]}]
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[1]}]
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[2]}]
set_property -dict { PACKAGE_PIN L3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[3]}]
set_property -dict { PACKAGE_PIN L2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[4]}]
set_property -dict { PACKAGE_PIN F2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[5]}]
set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[6]}]
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[7]}]
set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[8]}]
set_property -dict { PACKAGE_PIN H1 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[9]}]
set_property -dict { PACKAGE_PIN J3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[10]}]
set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[11]}]
set_property -dict { PACKAGE_PIN H5 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[12]}]
set_property -dict { PACKAGE_PIN H3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[13]}]
set_property -dict { PACKAGE_PIN G4 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[14]}]
set_property -dict { PACKAGE_PIN F4 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports {colour_bus_1[15]}]
set_property -dict { PACKAGE_PIN F5 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports dataclkin_1]
set_property -dict { PACKAGE_PIN J5 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports vsin_1]
set_property -dict { PACKAGE_PIN K3 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports hsin_1]
# set_property -dict { PACKAGE_PIN J4 IOSTANDARD LVCMOS33 DIRECTION IN } [get_ports fidin_1]

create_interface dac_ths8136_0
set_property INTERFACE dac_ths8136_0 [get_ports { colour_bus_0[0] colour_bus_0[1] colour_bus_0[2] colour_bus_0[3] colour_bus_0[4] colour_bus_0[5] colour_bus_0[6] colour_bus_0[7] colour_bus_0[8] colour_bus_0[9] colour_bus_0[10] colour_bus_0[11] colour_bus_0[12] colour_bus_0[13] colour_bus_0[14] colour_bus_0[15] hsync_out_0 vsync_out_0 dacclk_out_0 }]
set_property -dict { PACKAGE_PIN R1 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[0]}]
set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[1]}]
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[2]}]
set_property -dict { PACKAGE_PIN R3 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[3]}]
set_property -dict { PACKAGE_PIN T3 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[4]}]
set_property -dict { PACKAGE_PIN M5 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[5]}]
set_property -dict { PACKAGE_PIN P4 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[6]}]
set_property -dict { PACKAGE_PIN N4 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[7]}]
set_property -dict { PACKAGE_PIN P3 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[8]}]
set_property -dict { PACKAGE_PIN M4 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[9]}]
set_property -dict { PACKAGE_PIN N3 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[10]}]
set_property -dict { PACKAGE_PIN P1 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[11]}]
set_property -dict { PACKAGE_PIN N2 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[12]}]
set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[13]}]
set_property -dict { PACKAGE_PIN M2 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[14]}]
set_property -dict { PACKAGE_PIN M1 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports {colour_bus_0[15]}]
set_property -dict { PACKAGE_PIN L5 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports vsync_out_0]
set_property -dict { PACKAGE_PIN T4 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports hsync_out_0]
set_property -dict { PACKAGE_PIN L4 IOSTANDARD LVCMOS18 DIRECTION OUT } [get_ports dacclk_out_0]

create_interface sram_cy7c_0
set_property INTERFACE sram_cy7c_0 [get_ports { sram_data_bus_0[0] sram_data_bus_0[1] sram_data_bus_0[2] sram_data_bus_0[3] sram_data_bus_0[4] sram_data_bus_0[5] sram_data_bus_0[6] sram_data_bus_0[7] sram_data_bus_0[8] sram_data_bus_0[9] sram_data_bus_0[10] sram_data_bus_0[11] sram_data_bus_0[12] sram_data_bus_0[13] sram_data_bus_0[14] sram_data_bus_0[15] sram_data_bus_0[16] sram_data_bus_0[17] sram_data_bus_0[18] sram_data_bus_0[19] sram_data_bus_0[20] sram_data_bus_0[21] sram_data_bus_0[22] sram_data_bus_0[23] sram_data_bus_0[24] sram_data_bus_0[25] sram_data_bus_0[26] sram_data_bus_0[27] sram_data_bus_0[28] sram_data_bus_0[29] sram_data_bus_0[30] sram_data_bus_0[31] sram_data_bus_0[33] sram_data_bus_0[34] sram_data_bus_0[35] sram_addr_bus_0[0] sram_addr_bus_0[1] sram_addr_bus_0[2] sram_addr_bus_0[3] sram_addr_bus_0[4] sram_addr_bus_0[5] sram_addr_bus_0[6] sram_addr_bus_0[7] sram_addr_bus_0[8] sram_addr_bus_0[9] sram_addr_bus_0[10] sram_addr_bus_0[11] sram_addr_bus_0[12] sram_addr_bus_0[13] sram_addr_bus_0[14] sram_addr_bus_0[15] sram_addr_bus_0[16] sram_addr_bus_0[17] sram_addr_bus_0[18] sram_addr_bus_0[19] sram_ce1p3_0 sram_ce2_0 sram_cen_0 sram_we_0 sram_clk_0 sram_oe_0 sram_adv_ld_0 }]
set_property DRIVE 4 [get_ports { sram_data_bus_0[0] sram_data_bus_0[1] sram_data_bus_0[2] sram_data_bus_0[3] sram_data_bus_0[4] sram_data_bus_0[5] sram_data_bus_0[6] sram_data_bus_0[7] sram_data_bus_0[8] sram_data_bus_0[9] sram_data_bus_0[10] sram_data_bus_0[11] sram_data_bus_0[12] sram_data_bus_0[13] sram_data_bus_0[14] sram_data_bus_0[15] sram_data_bus_0[16] sram_data_bus_0[17] sram_data_bus_0[18] sram_data_bus_0[19] sram_data_bus_0[20] sram_data_bus_0[21] sram_data_bus_0[22] sram_data_bus_0[23] sram_data_bus_0[24] sram_data_bus_0[25] sram_data_bus_0[26] sram_data_bus_0[27] sram_data_bus_0[28] sram_data_bus_0[29] sram_data_bus_0[30] sram_data_bus_0[31] sram_data_bus_0[33] sram_data_bus_0[34] sram_data_bus_0[35] }]
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[0]}]
set_property -dict { PACKAGE_PIN G15 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[1]}]
set_property -dict { PACKAGE_PIN G16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[2]}]
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[3]}]
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[4]}]
set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[5]}]
set_property -dict { PACKAGE_PIN D16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[6]}]
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[7]}]
set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[8]}]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[9]}]
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[10]}]
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[11]}]
set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[12]}]
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[13]}]
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[14]}]
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[15]}]
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[16]}]
set_property -dict { PACKAGE_PIN H13 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[17]}]
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[18]}]
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[19]}]
set_property -dict { PACKAGE_PIN N13 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[20]}]
set_property -dict { PACKAGE_PIN P13 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[21]}]
set_property -dict { PACKAGE_PIN R6 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[22]}]
set_property -dict { PACKAGE_PIN T7 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[23]}]
set_property -dict { PACKAGE_PIN R7 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[24]}]
set_property -dict { PACKAGE_PIN R8 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[25]}]
set_property -dict { PACKAGE_PIN T8 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[26]}]
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[27]}]
set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[28]}]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[29]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[30]}]
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[31]}]
# SRAM_D32 is not connected to the FPGA at all sadly
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[33]}]
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[34]}]
set_property -dict { PACKAGE_PIN J16 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {sram_data_bus_0[35]}]
set_property -dict { PACKAGE_PIN B10 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[0]}]
set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[1]}]
set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[2]}]
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[3]}]
set_property -dict { PACKAGE_PIN D11 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[4]}]
set_property -dict { PACKAGE_PIN E12 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[5]}]
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[6]}]
set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[7]}]
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[8]}]
set_property -dict { PACKAGE_PIN B14 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[9]}]
set_property -dict { PACKAGE_PIN A15 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[10]}]
set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[11]}]
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[12]}]
set_property -dict { PACKAGE_PIN T9 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[13]}]
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[14]}]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[15]}]
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[16]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[17]}]
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[18]}]
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports {sram_addr_bus_0[19]}]
set_property -dict { PACKAGE_PIN P8 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports sram_ce1p3_0]
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports sram_ce2_0]
set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports sram_cen_0]
set_property -dict { PACKAGE_PIN T12 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports sram_we_0]
set_property -dict { PACKAGE_PIN R11 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports sram_clk_0]
set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports sram_oe_0]
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 DIRECTION OUT } [get_ports sram_adv_ld_0]

#create_interface auxio_0
#set_property INTERFACE auxio_0 [get_ports { auxio_bus_0[0] auxio_bus_0[1] auxio_bus_0[2] auxio_bus_0[3] auxio_bus_0[4] auxio_bus_0[5] auxio_bus_0[6] auxio_bus_0[7] auxio_bus_0[8] auxio_bus_0[9] auxio_bus_0[10] auxio_bus_0[11] auxio_bus_0[12] auxio_bus_0[13] auxio_bus_0[14] auxio_bus_0[15] }]
## in the schematic it's 1-indexed, here 0-indexed so auxio1=auxio_bus_0[0] and auxio<i>=auxio_bus_0[i-1]
#set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[0]}]
#set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[1]}]
#set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[2]}]
#set_property -dict { PACKAGE_PIN M12 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[3]}]
#set_property -dict { PACKAGE_PIN P10 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[4]}]
#set_property -dict { PACKAGE_PIN P11 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[5]}]
#set_property -dict { PACKAGE_PIN N9 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[6]}]
#set_property -dict { PACKAGE_PIN P9 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[7]}]
#set_property -dict { PACKAGE_PIN R5 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[8]}]
#set_property -dict { PACKAGE_PIN T5 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[9]}]
#set_property -dict { PACKAGE_PIN P6 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[10]}]
#set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[11]}]
#set_property -dict { PACKAGE_PIN B9 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[12]}]
#set_property -dict { PACKAGE_PIN A9 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[13]}]
#set_property -dict { PACKAGE_PIN A8 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[14]}]
#set_property -dict { PACKAGE_PIN C9 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[15]}]
#set_property -dict { PACKAGE_PIN P5 IOSTANDARD LVCMOS18 DIRECTION INOUT } [get_ports {auxio_bus_0[16]}]
#set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[17]}]
#set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[18]}]
#set_property -dict { PACKAGE_PIN D5 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[19]}]
#set_property -dict { PACKAGE_PIN D6 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[20]}]
#set_property -dict { PACKAGE_PIN C6 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[21]}]
#set_property -dict { PACKAGE_PIN C7 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[22]}]
#set_property -dict { PACKAGE_PIN E6 IOSTANDARD LVCMOS33 DIRECTION INOUT } [get_ports {auxio_bus_0[23]}]

#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

#revert back to original instance
current_instance -quiet

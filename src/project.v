/*
 * Copyright (c) 2024 Eduardo Holguin
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
//`include "top_general.v"

module tt_um_top_general (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (1=output)
    input  wire       ena,      
    input  wire       clk,      // not used
    input  wire       rst_n     // not used
);

  // ----------------------------
  // Pin mapping (change if needed)
  // ----------------------------
  // ui_in[0] -> CLK_g
  // ui_in[1] -> SCLK_g
  // ui_in[2] -> MOSI_g
  // ui_in[3] -> SS_g
  // ui_in[4] -> RESET_g (active high)

  wire senial_1g, senial_1gn, senial_2g, senial_2gn;

  // ----------------------------
  // Instantiate top_general
  // ----------------------------
  top_general chip (
    .CLK_g      (ui_in[0]),
    .SCLK_g     (ui_in[1]),
    .MOSI_g     (ui_in[2]),
    .SS_g       (ui_in[3]),
    .RESET_g    (ui_in[4]),
    .senial_1g  (senial_1g),
    .senial_1gn (senial_1gn),
    .senial_2g  (senial_2g),
    .senial_2gn (senial_2gn)
  );

  // ----------------------------
  // Outputs
  // ----------------------------
  assign uo_out[0] = senial_1g;
  assign uo_out[1] = senial_1gn;
  assign uo_out[2] = senial_2g;
  assign uo_out[3] = senial_2gn;
  assign uo_out[7:4] = 4'b0000;

  assign uio_out = 8'h00;
  assign uio_oe  = 8'h00;

  // Mark unused signals to avoid warnings
  wire _unused = &{ena, clk, rst_n, uio_in, ui_in[7:5], 1'b0};

endmodule

`default_nettype wire

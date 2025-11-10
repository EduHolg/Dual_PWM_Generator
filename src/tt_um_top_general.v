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
    input  wire       clk,      // now routed to a pin and used for a divider
    input  wire       rst_n
);

  // ----------------------------
  // Pin mapping (unchanged for chip)
  // ----------------------------
  // ui_in[0] -> CLK_g    
  // ui_in[1] -> SCLK_g
  // ui_in[2] -> MOSI_g
  // ui_in[3] -> SS_g
  // ui_in[4] -> RESET_g
  //
  // Free user inputs for logic tests:
  // ui_in[5] -> A
  // ui_in[6] -> B
  // ui_in[7] -> C (spare, currently unused here but kept in _unused tie)

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
  // Simple logic-gate playground
  // ----------------------------
  wire A = ui_in[5];
  wire B = ui_in[6];

  wire and_ab  = A & B;
  wire or_ab   = A | B;
  wire xor_ab  = A ^ B;
  wire nand_ab = ~(A & B);
  wire nor_ab  = ~(A | B);
  wire xnor_ab = ~(A ^ B);
  wire not_a   = ~A;
  wire not_b   = ~B;
  wire a_and_n_b =  A & ~B;
  wire n_a_and_b = ~A &  B;

  // ----------------------------
  // Clock visibility
  //  - Raw clk on uo_out[7]
  //  - Divided clock on uio_out[7] (slow for LEDs/logic probe)
  // ----------------------------
  reg [23:0] clk_div;  // adjust width as needed for your board
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      clk_div <= 24'd0;
    else
      clk_div <= clk_div + 1'b1;
  end
  wire slow_clk = clk_div[23]; // very slow tap

  // ----------------------------
  // Dedicated outputs
  // ----------------------------
  assign uo_out[0] = senial_1g;
  assign uo_out[1] = senial_1gn;
  assign uo_out[2] = senial_2g;
  assign uo_out[3] = senial_2gn;

  // Gate demos on the remaining uo_out bits
  assign uo_out[4] = and_ab;     // AND(A,B)
  assign uo_out[5] = or_ab;      // OR(A,B)
  assign uo_out[6] = xor_ab;     // XOR(A,B)
  assign uo_out[7] = clk;        // raw clock out for probing

  // ----------------------------
  // Bidirectional IOs used as outputs for more tests
  // ----------------------------
  assign uio_out[0] = nand_ab;     // NAND(A,B)
  assign uio_out[1] = nor_ab;      // NOR(A,B)
  assign uio_out[2] = xnor_ab;     // XNOR(A,B)
  assign uio_out[3] = not_a;       // NOT A
  assign uio_out[4] = not_b;       // NOT B
  assign uio_out[5] = a_and_n_b;   // A & ~B
  assign uio_out[6] = n_a_and_b;   // ~A & B
  assign uio_out[7] = slow_clk;    // divided clock

  // Drive all uio as outputs
  assign uio_oe = 8'hFF;

  // Mark remaining unused to avoid warnings (leave C, ena, uio_in tied)
  wire _unused = &{ena, uio_in, ui_in[7], 1'b0};

endmodule


`default_nettype wire

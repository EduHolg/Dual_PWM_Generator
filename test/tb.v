`default_nettype none
`timescale 1ns / 1ps

module tb ();

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // clock
  reg clk = 0;
  always #5 clk = ~clk;   // 100 MHz

  // inputs / init
  reg rst_n = 0;
  reg ena   = 0;
  reg [7:0] ui_in  = 8'h00;
  reg [7:0] uio_in = 8'h00;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  tt_um_top_general user_project (
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  initial begin
    // hold reset low for a bit
    rst_n = 0;
    ena   = 0;
    #100;         // 100ns reset
    rst_n = 1;    // release reset
  end

endmodule

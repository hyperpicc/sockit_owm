`timescale 1ns / 1ps

module stopwatch_tb;

//localparam FRQ = 24_000_000;  // 24MHz // realistic optiony
localparam FRQ = 24_0;  // 240Hz // option for faster simulation
localparam SPN = FRQ;
localparam real CP = 1000000000/FRQ;  // clock period

// list of local signals
reg        clk;       // clock
reg        rst;      // reset (asynchronous)
// buttons (should be debuunced)
reg        b_run;     // run/stop    button
reg        b_clr;     // clear/split button
// 7 segment time outputs
wire [6:0] sec_0;     //     seconds
wire [6:0] sec_1;     // ten seconds
wire [6:0] min_0;     //     minutes
wire [6:0] min_1;     // ten minutes
// screen status and hold status indicators
wire       s_run;     // run status
wire       s_hld;     // hold status

// request for a dumpfile
initial begin
  $dumpfile("stopwatch.vcd");
  $dumpvars(0, stopwatch_tb);
end

// clock generation
initial        clk = 1'b1;
always #(CP/2) clk = ~clk;

// test signal generation
initial begin
  $display ("SPN = ", SPN);
  // buttons are initially not active
  b_run = 1'b0;
  b_clr = 1'b0;
  // reset sequence
  rst = 1'b1;
  repeat (2) @(posedge clk);
  rst <= 1'b0;
  repeat (10) @(posedge clk);
  // start stopwatch and run it for some time 31s
  b_run <= 1'b1;
  repeat (10) @(posedge clk);
  b_run <= 1'b0;
  repeat (SPN*(31)-10) @(posedge clk);
  // push the leap button to hold the time for 13s
  b_clr <= 1'b1;
  repeat (10) @(posedge clk);
  b_clr <= 1'b0;
  repeat (SPN*(13)-10) @(posedge clk);
  // push the leap button to release the time for 7s
  b_clr <= 1'b1;
  repeat (10) @(posedge clk);
  b_clr <= 1'b0;
  repeat (SPN*(7)-10) @(posedge clk);
  // stop stopwatch and wait for 8s
  b_run <= 1'b1;
  repeat (10) @(posedge clk);
  b_run <= 1'b0;
  repeat (SPN*(7)-10) @(posedge clk);
  // clear the stopwatch and wait for 5s
  b_clr <= 1'b1;
  repeat (10) @(posedge clk);
  b_clr <= 1'b0;
  repeat (SPN*(5)-10) @(posedge clk);
  // restart the stopwatch and run to 13:13
  b_run <= 1'b1;
  repeat (10) @(posedge clk);
  b_run <= 1'b0;
  repeat (SPN*(13*60+13)-10) @(posedge clk);
  $finish(); 
end

// instantiate counter RTL
stopwatch #(
  // timing parameters
  .SPN    (SPN)
) stopwatch_i (
  // system signals
  .clk    (clk),
  .rst    (rst),
  // buttons
  .b_run  (b_run),
  .b_clr  (b_clr),
  // time outputs
  .sec_0  (sec_0),
  .sec_1  (sec_1),
  .min_0  (min_0),
  .min_1  (min_1),
  // screen status and hold status indicators
  .s_run  (s_run),
  .s_hld  (s_hld)
);

endmodule

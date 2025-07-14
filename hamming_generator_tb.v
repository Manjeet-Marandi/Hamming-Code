`timescale 1ps/1ps
`include "hamming_generator.v"

module hamming_generator_tb ();
    
reg [3:0] data_in;
reg rst_n;
reg clk = 0;
reg enable;
reg mode;
wire [6:0] data_out;

hamming_generator uut(
    .data_in(data_in),
    .rst_n(rst_n),
    .clk(clk),
    .enable(enable),
    .mode(mode),
    .data_out(data_out)
);

//clk
always begin
    #0.5; clk = ~clk;
end

initial begin
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1; 
    @(posedge clk) enable = 1; mode = 1; data_in = 4'b1010;
    @(posedge clk) enable = 0;
    repeat (4) @(posedge clk); $display("data_out=%0b", data_out);

    @(posedge clk) enable = 1; mode = 0; data_in = 4'b1010;
    @(posedge clk) enable = 0;
    repeat (4) @(posedge clk); $display("data_out=%0b", data_out);
    $finish;
end

endmodule
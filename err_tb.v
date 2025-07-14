`timescale 1ps/1ps
`include "err_det&cor.v"

module error_tb ();
    
reg [6:0] data_in;
reg rst_n;
reg clk = 0;
reg enable;
reg mode;
wire [6:0] data_out;

error_detection_correction uut(
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

task load_data (input [6:0] entry_data);
begin
    @(posedge clk) rst_n = 0;data_in = entry_data;
    @(posedge clk) rst_n = 1; 
    @(posedge clk) enable = 1; mode = 0; 
    @(posedge clk) enable = 0;

    repeat (4) @(posedge clk); $display("\ndata_in= %b, data_out=%b", data_in,data_out);

    @(posedge clk) rst_n = 0;data_in = entry_data;
    @(posedge clk) rst_n = 1; 
    @(posedge clk) enable = 1; mode = 1; 
    @(posedge clk) enable = 0;

    repeat (4) @(posedge clk); $display("data_in= %b, data_out=%b", data_in,data_out);
end
endtask

initial begin
    $dumpfile("err.vcd");
    $dumpvars(0,error_tb);
    
    load_data(7'b1101110);
    @(posedge clk);
    load_data(7'b1111111);
    @(posedge clk);
    load_data(7'b1001100);
    $finish;
end

endmodule
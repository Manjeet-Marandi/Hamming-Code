module hamming_generator #(
    parameter IDLE = 3'b000,
    parameter P1 = 3'b001 ,
    parameter P2 = 3'b010,
    parameter P4 = 3'b100 ,
    parameter DONE = 3'b111
) (
    input [3:0] data_in,
    input rst_n,
    input clk,
    input enable,
    input mode, //1 for even, 0 for odd
    output reg [6:0] data_out
);
    
reg [2:0] parity;
reg p1;
reg p2;
reg p4;

wire p1_even = data_in[0] ^ data_in[1] ^ data_in[3];
wire p2_even = data_in[0] ^ data_in[2] ^ data_in[3];
wire p4_even = data_in[1] ^ data_in[2] ^ data_in[3];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_out <= 0;
        p1 <= 0;
        p2 <= 0;
        p4 <= 0;
        parity <= IDLE;
    end
    else begin
        case (parity)
            
            IDLE : if (enable) begin
                parity <= P1;
            end 
            else parity <= IDLE;

            P1 : begin
                if (mode) begin
                    p1 <= p1_even;
                    parity <= P2;
                end
                else begin
                    p1 <= ~p1_even;
                    parity <= P2;
                end
            end

            P2 : begin
                if (mode) begin
                    p2 <= p2_even;
                    parity <= P4;
                end
                else begin
                    p2 <= ~p2_even;
                    parity <= P4;
                end
            end    

            P4 : begin
                if (mode) begin
                    p4 <= p4_even;
                    parity <= DONE;
                end
                else begin
                    p4 <= ~p4_even;
                    parity <= DONE;
                end
            end        

            DONE : begin
                data_out <= {data_in[3], data_in[2], data_in[1], p4, data_in[0], p2, p1};
                parity <= IDLE;
            end
            
            default: begin
                parity <= IDLE;
                p1 <= 0;
                p2 <= 0;
                p4 <= 0;
            end
        endcase
    end
end
endmodule
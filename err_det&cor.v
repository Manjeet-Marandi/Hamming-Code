module error_detection_correction #(
    parameter IDLE = 3'b000,
    parameter P1 = 3'b001 ,
    parameter P2 = 3'b010,
    parameter P4 = 3'b100,
    parameter DONE = 3'b111
)(
    input [6:0] data_in,
    input rst_n,
    input mode,//1 for even parity, 0 for odd parity
    input enable,
    input clk,
    output reg [6:0] data_out
);

reg [2:0] parity;
reg p1 ;
reg p2 ;
reg p4 ;
wire [2:0] correction = {p4,p2,p1};

wire p1_even = data_in[2] ^ data_in[4] ^ data_in[6];
wire p2_even = data_in[2] ^ data_in[5] ^ data_in[6];
wire p4_even = data_in[4] ^ data_in [5] ^ data_in[6];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_out <= 0;
        p1 <= data_in[0];
        p2 <= data_in[1];
        p4 <= data_in[3];
        data_out <= data_in;
        parity <= IDLE;
    end
    else begin
        case (parity)
            
            IDLE :  if(enable) begin
                        parity <=P1;
                    end 
                    else parity <= IDLE;

            P1 : begin
                if(mode) begin
                    if(p1 == p1_even) begin
                        p1 <= 0;
                        parity <= P2;

                    end
                    else begin
                        p1 <= 1;
                        parity <= P2;                     
                    end
                end
                else if(!mode) begin
                    if(p1 == ~p1_even) begin
                        p1 <= 0;
                        parity <= P2;
                    end
                    else begin
                        p1 <= 1;
                        parity <= P2;
                    end
                end
            end

            P2 : begin
                if(mode) begin
                    if(p2 == p2_even) begin
                        p2 <= 0;
                        parity <= P4;
                    end
                    else begin
                        p2 <= 1;
                        parity <= P4;
                    end
                end
                else if(!mode) begin
                    if(p2 == ~p2_even) begin
                        p1 <= 0;
                        parity <= P4;
                    end
                    else begin
                        p2 <= 1;
                        parity <= P4;
                    end
                end
            end

            P4 : begin
                if(mode) begin
                    if(p4 == p4_even) begin
                        p4 <= 0;
                        parity <= DONE;
                    end
                    else begin
                        p4 <= 1;
                        parity <= DONE;
                    end
                end
                else if(!mode) begin
                    if(p4 == ~p4_even) begin
                        p4 <= 0;
                        parity <= DONE;
                    end
                    else begin
                        p4 <= 1;
                        parity <= DONE;
                    end
                end
            end    

            DONE : begin
                if(p4 == data_in[3] & p2 == data_in[1] & p1 == data_in[0])begin
                    data_out <= data_in;
                    parity <= IDLE;
                end
                else begin
                    data_out[correction - 1'b1] <= ~data_out[correction - 1'b1];
                    parity <= IDLE;
                end
                
            end        

            default:begin
                parity <=IDLE;
                p1 <= data_in[0];
                p2 <= data_in[1];
                p4 <= data_in[3];
            end
        endcase
    end
end
endmodule
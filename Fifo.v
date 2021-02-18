`default_nettype none
module Fifo(input wire clk,
            input wire reset_n,
            input wire flush,
            // Write port
            input wire wr_en,
            input wire [data_width-1:0] wr_data,
            // Read port
            input wire rd_en,
            output wire [data_width-1:0] rd_data,
            output wire empty,
            output wire full);

parameter data_width = 32;
parameter depth = 6;
localparam ptr_bits = $clog2(depth);

reg [data_width-1:0] mem[depth-1:0];
reg [ptr_bits-1:0] rd_ptr;
reg [ptr_bits-1:0] wr_ptr;
reg [ptr_bits:0] count;

assign empty = count == 0;
assign full = count == depth;
assign rd_data = mem[rd_ptr];

wire [ptr_bits-1:0] next_wr_ptr = flush ? {ptr_bits{1'b0}} :
    full || !wr_en ? wr_ptr :
    wr_ptr == depth[ptr_bits-1:0] - 1'b1 ? {ptr_bits{1'b0}} :
    wr_ptr + 1'b1;
wire [ptr_bits-1:0] next_rd_ptr = flush ? {ptr_bits{1'b0}} :
    empty || !rd_en ? rd_ptr :
    rd_ptr == depth[ptr_bits-1:0] - 1'b1 ? {ptr_bits{1'b0}} :
    rd_ptr + 1'b1;
wire [ptr_bits:0] next_count = flush ? {ptr_bits + 1{1'b0}} :
    wr_en && !full && rd_en && !empty ? count :
    wr_en && !full ? count + 1'b1 :
    rd_en && !empty ? count - 1'b1 :
    count;

always @(posedge clk)
    if (wr_en && !full)
        mem[wr_ptr] <= wr_data;

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        wr_ptr <= {ptr_bits{1'b0}};
    else
        wr_ptr <= next_wr_ptr;

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        rd_ptr <= {ptr_bits{1'b0}};
    else
        rd_ptr <= next_rd_ptr;

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        count <= {ptr_bits + 1{1'b0}};
    else
        count <= next_count;

endmodule

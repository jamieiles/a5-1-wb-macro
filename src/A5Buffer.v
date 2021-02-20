module A5Buffer (
    input wire clk,
    input wire reset_n,
    input wire load,
    output wire [31:0] data_out,
    output wire empty,
    input wire rd_en,
    input wire [63:0] key,
    input wire [21:0] frame
);

wire fifo_full;
reg fifo_wr_en;
reg [31:0] shift_reg;
wire a5_out;
wire lfsr_stall = fifo_full | fifo_wr_en;
wire lfsr_valid;

A5Generator A5Generator(
    .clk(clk),
    .reset_n(reset_n),
    .load(load),
    .stall(lfsr_stall),
    .q(a5_out),
    .valid(lfsr_valid),
    .key(key),
    .frame(frame)
);

Fifo #(
    .data_width(32),
    .depth(4)
) Fifo (
    .clk(clk),
    .reset_n(reset_n),
    .flush(load),
    .wr_en(fifo_wr_en),
    .wr_data(shift_reg),
    .rd_en(rd_en),
    .rd_data(data_out),
    .empty(empty),
    .full(fifo_full)
);

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        {shift_reg, fifo_wr_en} <= {1'b1, 32'b0};
    else
        {shift_reg, fifo_wr_en} <=
            !lfsr_valid || load || fifo_wr_en ? {1'b1, 32'b0} :
            lfsr_stall ? {shift_reg, fifo_wr_en} :
            {a5_out, shift_reg};

endmodule
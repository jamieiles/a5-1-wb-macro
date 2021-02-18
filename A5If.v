`default_nettype none
module A5If (
    // interface as user_proj_example.v
    input wire clk,
    input wire reset_n,
    input wire wbs_stb_i,
    input wire wbs_cyc_i,
    input wire wbs_we_i,
    input wire [3:0] wbs_sel_i,
    input wire [31:0] wbs_dat_i,
    input wire [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o
);

wire l0_q, l1_q, l2_q;
wire lfsr_clk_en = ~fifo_full;

a5lfsr #(
    .num_bits(19),
    .num_taps(4),
    .tap_bits(19'b111_0010_0000_0000_0000),
    .clock_bit(19'b000_0000_0001_0000_0000)
) l0 (
    .clk(clk),
    .reset_n(reset_n),
    .clk_en(lfsr_clk_en),
    .d(clk),
    .q(l0_q)
);

a5lfsr #(
    .num_bits(22),
    .num_taps(4),
    .tap_bits(22'b11_0000_0000_0000_0000_0000),
    .clock_bit(22'b00_0000_0000_0100_0000_0000)
) l1 (
    .clk(clk),
    .reset_n(reset_n),
    .clk_en(lfsr_clk_en),
    .d(clk),
    .q(l1_q)
);

a5lfsr #(
    .num_bits(23),
    .num_taps(4),
    .tap_bits(23'b000_0000_0000_0000_1000_0000),
    .clock_bit(23'b111_0000_0000_0100_0000_0000)
) l2 (
    .clk(clk),
    .reset_n(reset_n),
    .clk_en(lfsr_clk_en),
    .d(clk),
    .q(l2_q)
);

reg fifo_rd_en;
wire [31:0] fifo_rd_data;
wire fifo_empty;
wire fifo_full;

wire [31:0] fifo_wr_data = a5_sr;

reg fifo_wr_en;
reg [31:0] a5_sr;

wire a5_out = l0_q ^ l1_q ^ l2_q;

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        {fifo_wr_en, a5_sr} <= 33'b1;
    else
        {fifo_wr_en, a5_sr} <= fifo_wr_en ? 33'b1 :
            lfsr_clk_en ? {a5_sr[31:0], a5_out} : {fifo_wr_en, a5_sr};

Fifo #(
    .data_width(32),
    .depth(4)
) Fifo (
    .clk(clk),
    .reset_n(reset_n),
    .flush(1'b0),
    .wr_en(fifo_wr_en),
    .wr_data(fifo_wr_data),
    .rd_en(fifo_rd_en),
    .rd_data(fifo_rd_data),
    .empty(fifo_empty),
    .full(fifo_full)
);

wire wb_access = wbs_stb_i & wbs_cyc_i;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        wbs_ack_o <= 1'b0;
        wbs_dat_o <= 32'b0;
        fifo_rd_en <= 1'b0;
    end else begin
        wbs_ack_o <= 1'b0;
        wbs_dat_o <= 32'b0;
        fifo_rd_en <= 1'b0;

        if (wb_access && !wbs_ack_o) begin
            wbs_ack_o <= 1'b1;
            wbs_dat_o <= ~|wbs_adr_i ? fifo_rd_data : 32'b0;

            if (~|wbs_adr_i && !fifo_empty)
                fifo_rd_en <= 1'b1;
        end
    end
end

endmodule

module a5lfsr #(
    parameter num_bits = 8,
    parameter num_taps = 3,
    parameter tap_bits = 8'h80,
    parameter clock_bit = 8'h80
)(
    input wire clk,
    input wire reset_n,
    input wire clk_en,
    input wire d,
    output wire q
);

reg [num_bits-1:0] sr;
reg feedback;

integer i;

assign q = sr[num_bits-1];

always @(*) begin
    feedback = 1'b0;
    for (i = 0; i < num_bits; i = i + 1) begin
        if (tap_bits[i])
            feedback ^= sr[i];
    end
end

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        sr <= {num_bits{1'b0}};
    else if (clk_en)
        sr <= {sr[num_bits-2:0], d ^ feedback};

endmodule
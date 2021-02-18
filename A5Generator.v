module A5Generator(
    input wire clk,
    input wire reset_n,
    input wire lfsr_clk_en,
    output wire d
);

wire l0_q;
wire l1_q;
wire l2_q;

assign d = l0_q ^ l1_q ^ l2_q;

AFLFSR #(
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

AFLFSR #(
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

AFLFSR #(
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

endmodule
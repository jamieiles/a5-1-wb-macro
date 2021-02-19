module A5Generator(
    input wire clk,
    input wire reset_n,
    input wire load,
    input wire lfsr_clk_en,
    output wire d,
    input wire [63:0] key,
    input wire [21:0] frame
);

wire l0_q;
wire l1_q;
wire l2_q;
reg [95:0] init_sr;
wire lfsr_in = init_sr[0];

assign d = l0_q ^ l1_q ^ l2_q;

always @(posedge clk)
    if (load)
        init_sr <= {frame, key};
    else
        init_sr <= {1'b0, init_sr[95:1]};

AFLFSR #(
    .num_bits(19),
    .num_taps(4),
    .tap_bits(19'b111_0010_0000_0000_0000),
    .clock_bit(19'b000_0000_0001_0000_0000)
) l0 (
    .clk(clk),
    .reset_n(reset_n),
    .load(load),
    .clk_en(lfsr_clk_en),
    .d(lfsr_in),
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
    .load(load),
    .clk_en(lfsr_clk_en),
    .d(lfsr_in),
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
    .load(load),
    .clk_en(lfsr_clk_en),
    .d(lfsr_in),
    .q(l2_q)
);

endmodule
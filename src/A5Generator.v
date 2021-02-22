module A5Generator(
    input wire clk,
    input wire reset_n,
    input wire load,
    input wire stall,
    output wire q,
    output reg valid,
    output wire busy,
    input wire [63:0] key,
    input wire [21:0] frame
);

wire l0_q;
wire l1_q;
wire l2_q;
reg [85:0] init_sr;
wire lfsr_in = init_sr[0];
wire [2:0] lfsr_clk_en = ({3{~stall}} & {lfsr_clk_bits[2] == clk_bit_majority,
    lfsr_clk_bits[1] == clk_bit_majority,
    lfsr_clk_bits[0] == clk_bit_majority}) | {3{clock_unconditional}};
wire [2:0] lfsr_clk_bits;
wire clock_unconditional = init_cycle_count > 99;
reg clk_bit_majority;

// 64 key bits + 22 frame number bits + 100 mix 0's
localparam init_cycles = 64 + 22 + 100;
localparam init_bits = $clog2(init_cycles);

reg [init_bits-1:0] init_cycle_count;
reg init_done;

assign q = l0_q ^ l1_q ^ l2_q;
assign busy = |init_cycle_count | valid | init_done;

always @(posedge clk)
    if (load)
        init_sr <= {frame, key};
    else
        init_sr <= {1'b0, init_sr[85:1]};

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        init_done <= 1'b0;
    else
        init_done <= load ? 1'b0 : ~|init_cycle_count;

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        valid <= 1'b0;
    else
        valid <= load ? 1'b0 : init_done;

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        init_cycle_count <= init_cycles - 1'b1;
    else begin
        if (load)
            init_cycle_count <= init_cycles - 1'b1;
        else if (|init_cycle_count)
            init_cycle_count <= init_cycle_count - 1'b1;
    end

always @(*) begin
    case (lfsr_clk_bits)
    3'b000: clk_bit_majority = 1'b0;
    3'b001: clk_bit_majority = 1'b0;
    3'b010: clk_bit_majority = 1'b0;
    3'b011: clk_bit_majority = 1'b1;
    3'b100: clk_bit_majority = 1'b0;
    3'b101: clk_bit_majority = 1'b1;
    3'b110: clk_bit_majority = 1'b1;
    3'b111: clk_bit_majority = 1'b1;
    endcase
end

A5LFSR #(
    .num_bits(19),
    .num_taps(4),
    .tap_bits(19'b111_0010_0000_0000_0000),
    .clock_bit(8)
) l0 (
    .clk(clk),
    .reset_n(reset_n),
    .load(load),
    .clk_en(lfsr_clk_en[0]),
    .d(lfsr_in),
    .q(l0_q),
    .clk_bit_o(lfsr_clk_bits[0])
);

A5LFSR #(
    .num_bits(22),
    .num_taps(4),
    .tap_bits(22'b11_0000_0000_0000_0000_0000),
    .clock_bit(10)
) l1 (
    .clk(clk),
    .reset_n(reset_n),
    .load(load),
    .clk_en(lfsr_clk_en[1]),
    .d(lfsr_in),
    .q(l1_q),
    .clk_bit_o(lfsr_clk_bits[1])
);

A5LFSR #(
    .num_bits(23),
    .num_taps(4),
    .tap_bits(23'b111_0000_0000_0000_1000_0000),
    .clock_bit(10)
) l2 (
    .clk(clk),
    .reset_n(reset_n),
    .load(load),
    .clk_en(lfsr_clk_en[2]),
    .d(lfsr_in),
    .q(l2_q),
    .clk_bit_o(lfsr_clk_bits[2])
);

endmodule
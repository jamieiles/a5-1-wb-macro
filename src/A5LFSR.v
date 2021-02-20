module AFLFSR #(
    parameter num_bits = 8,
    parameter num_taps = 3,
    parameter tap_bits = 8'h80,
    parameter clock_bit = 0
)(
    input wire clk,
    input wire reset_n,
    input wire load,
    input wire clk_en,
    input wire d,
    output wire q,
    output wire clk_bit_o
);

reg [num_bits-1:0] sr;
reg feedback;
wire [num_bits-1:0] next_sr = load ? {num_bits{1'b0}} :
    clk_en ? {sr[num_bits-2:0], d ^ feedback} :
    sr;
integer i;

assign q = sr[num_bits-1];
assign clk_bit_o = sr[clock_bit];

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
    else
        sr <= next_sr;

endmodule
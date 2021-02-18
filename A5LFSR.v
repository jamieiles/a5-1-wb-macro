module AFLFSR #(
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
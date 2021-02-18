`default_nettype none
module A5If (
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

wire [31:0] keystream_data;
wire keystream_empty;
reg keystream_read;

A5Buffer A5Buffer (
    .clk(clk),
    .reset_n(reset_n),
    .data_out(keystream_data),
    .empty(keystream_empty),
    .rd_en(keystream_read)
);

wire wb_access = wbs_stb_i & wbs_cyc_i;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        wbs_ack_o <= 1'b0;
        wbs_dat_o <= 32'b0;
        keystream_read <= 1'b0;
    end else begin
        wbs_ack_o <= 1'b0;
        wbs_dat_o <= 32'b0;
        keystream_read <= 1'b0;

        if (wb_access && !wbs_ack_o) begin
            wbs_ack_o <= 1'b1;
            wbs_dat_o <= ~|wbs_adr_i ? keystream_data : 32'b0;

            if (~|wbs_adr_i && !keystream_empty)
                keystream_read <= 1'b1;
        end
    end
end

endmodule
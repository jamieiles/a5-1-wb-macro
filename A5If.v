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

/*
Register map:

00: ID register
04: status
   [0]: empty
   [1]: full
08: control
   [0]: initialize
0C: data out
10: key [31:0]
14: key [63:32]
18: frame number ([21:0])
*/

wire [31:0] keystream_data;
wire keystream_empty;
reg keystream_read;
reg keystream_load;

reg [63:0] key;
reg [21:0] frame;

A5Buffer A5Buffer (
    .clk(clk),
    .reset_n(reset_n),
    .load(keystream_load),
    .data_out(keystream_data),
    .empty(keystream_empty),
    .rd_en(keystream_read),
    .key(key),
    .frame(frame)
);

wire wb_access = wbs_stb_i & wbs_cyc_i;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        wbs_ack_o <= 1'b0;
        wbs_dat_o <= 32'b0;
        keystream_read <= 1'b0;
        keystream_load <= 1'b0;
        key <= 64'b0;
        frame <= 22'b0;
    end else begin
        wbs_ack_o <= 1'b0;
        wbs_dat_o <= 32'b0;
        keystream_read <= 1'b0;
        keystream_load <= 1'b0;

        if (wb_access && !wbs_ack_o) begin
            wbs_ack_o <= 1'b1;
            wbs_dat_o <= ~|wbs_adr_i ? keystream_data : 32'b0;

            if (~|wbs_adr_i && !keystream_empty)
                keystream_read <= 1'b1;

            if (wbs_adr_i == 32'd4)
                keystream_load <= 1'b1;

            if (wbs_we_i && wbs_adr_i == 32'h10 && wbs_sel_i == 4'b1111)
                key[31:0] <= wbs_dat_i;
            if (wbs_we_i && wbs_adr_i == 32'h14 && wbs_sel_i == 4'b1111)
                key[63:32] <= wbs_dat_i;
            if (wbs_we_i && wbs_adr_i == 32'h18 && wbs_sel_i == 4'b1111)
                frame <= wbs_dat_i[21:0];
        end
    end
end

endmodule
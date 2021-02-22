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

localparam REG_ID_OFFS      = 'h00;
localparam REG_STATUS_OFFS  = 'h04;
localparam REG_CONTROL_OFFS = 'h08;
localparam REG_DATA_OFFS    = 'h0c;
localparam REG_KEY_LO_OFFS  = 'h10;
localparam REG_KEY_HI_OFFS  = 'h14;
localparam REG_FRAME_OFFS   = 'h18;

wire access             = wbs_stb_i & wbs_cyc_i & ~wbs_ack_o;
wire reg_access_id      = access && wbs_adr_i[4:0] == REG_ID_OFFS;
wire reg_access_status  = access && wbs_adr_i[4:0] == REG_STATUS_OFFS;
wire reg_access_control = access && wbs_adr_i[4:0] == REG_CONTROL_OFFS;
wire reg_access_data    = access && wbs_adr_i[4:0] == REG_DATA_OFFS;
wire reg_access_key_lo  = access && wbs_adr_i[4:0] == REG_KEY_LO_OFFS;
wire reg_access_key_hi  = access && wbs_adr_i[4:0] == REG_KEY_HI_OFFS;
wire reg_access_frame   = access && wbs_adr_i[4:0] == REG_FRAME_OFFS;

wire [31:0] id_o        = 32'h41354135;
wire [31:0] status_o    = {29'b0, keystream_busy, keystream_full, ~keystream_empty};
wire [31:0] control_o   = 32'b0;
wire [31:0] data_o      = keystream_data;
wire [31:0] key_lo_o    = key[31:0];
wire [31:0] key_hi_o    = key[63:32];
wire [31:0] frame_o     = {10'b0, frame};
reg [31:0]  wb_data_o;

wire [31:0] keystream_data;
wire keystream_empty;
wire keystream_full;
wire keystream_busy;
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
    .full(keystream_full),
    .busy(keystream_busy),
    .rd_en(keystream_read),
    .key(key),
    .frame(frame)
);

always @(*) begin
    case (wbs_adr_i[5:0])
    REG_ID_OFFS:        wb_data_o = id_o;
    REG_STATUS_OFFS:    wb_data_o = status_o;
    REG_CONTROL_OFFS:   wb_data_o = control_o;
    REG_DATA_OFFS:      wb_data_o = data_o;
    REG_KEY_LO_OFFS:    wb_data_o = key_lo_o;
    REG_KEY_HI_OFFS:    wb_data_o = key_hi_o;
    REG_FRAME_OFFS:     wb_data_o = frame_o;
    default:            wb_data_o = 32'b0;
    endcase
end

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        key <= 64'b0;
    else begin
        if (reg_access_key_lo && wbs_we_i && &wbs_sel_i)
            key[31:0] <= wbs_dat_i;
        if (reg_access_key_hi && wbs_we_i && &wbs_sel_i)
            key[63:32] <= wbs_dat_i;
    end

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        frame <= 22'b0;
    else if (reg_access_frame && wbs_we_i && &wbs_sel_i)
        frame <= wbs_dat_i[21:0];

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        keystream_load <= 1'b0;
    else begin
        keystream_load <= 1'b0;
        if (reg_access_control && wbs_we_i && &wbs_sel_i)
            keystream_load <= wbs_dat_i[0];
    end

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        keystream_read <= 1'b0;
    else
        keystream_read <= reg_access_data & ~wbs_we_i & ~keystream_empty;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        wbs_ack_o <= 1'b0;
        wbs_dat_o <= 32'b0;
    end else begin
        wbs_ack_o <= access;
        wbs_dat_o <= access ? wb_data_o : 32'b0;
    end
end

endmodule
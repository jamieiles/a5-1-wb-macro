always @(*) begin
    if(active) begin
        assert(wbs_ack_o == buf_wbs_ack_o);
        assert(wbs_dat_o == buf_wbs_dat_o);
        assert(la_data_out == buf_la_data_out);
        assert(io_out == buf_io_out);
        assert(io_oeb == buf_io_oeb);
	assert(irq == buf_irq);
    end
    if(!active) begin
        assert(~wbs_ack_o);
        assert(~|wbs_dat_o);
        assert(~|la_data_out);
        assert(~|io_out);
        assert(~|io_oeb);
	assert(~|irq);
    end
end

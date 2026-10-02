module RX_TOP #(
    parameter DATA_WIDTH = 8,
    parameter num_bits = $clog2(DATA_WIDTH)

)(
    input CLK , RST ,
    input RX_IN , Parity_Type, Parity_Enable ,
    input [5:0] prescale,
    output data_valid, par_err , stp_err,
    output [DATA_WIDTH-1:0] P_Data
);

wire par_err_comb , stp_err_comb, strt_glitch_comb;
wire stp_chk_en, par_chk_en , strt_chk_en;
wire edge_cnt_en , data_sample_en , deser_en;
wire sampled_bit;
wire [7:0] edge_cnt;
wire [num_bits : 0]bit_cnt;
wire data_valid_comp;
wire [DATA_WIDTH-1:0] shift_reg;
wire smpl_pulse;                       // NEW: 1-cycle pulse at the sample instant

RX_DES #(
    .DATA_WIDTH(DATA_WIDTH)
) deser_inst (
    .CLK(CLK),
    .RST(RST),
    .sampled_bit(sampled_bit),
    .deser_en(deser_en),
    .bit_cnt(bit_cnt),
    .P_Data(P_Data),
    .shift_reg(shift_reg),
    .data_valid(data_valid_comp)
);

RX_EDGE_CNT #(
    .DATA_WIDTH(DATA_WIDTH)
) edge_counter_inst(
    .CLK(CLK),
    .RST(RST),
    .edge_cnt_en(edge_cnt_en),
    .edge_cnt(edge_cnt),
    .prescale(prescale),
    .bit_cnt(bit_cnt)
);

RX_SAMPLER  #(
    .DATA_WIDTH(DATA_WIDTH) 
) sampler_inst (
    .CLK(CLK),
    .RST(RST),
    .RX_IN(RX_IN),
    .data_sample_en(data_sample_en),
    .prescale(prescale),
    .edge_cnt(edge_cnt),
    .sampled_bit(sampled_bit)
);

RX_STP_CHK #(
    .DATA_WIDTH(DATA_WIDTH)
) stp_checker_inst(
    .CLK(CLK),
    .RST(RST),
    .stop_chk_en(stp_chk_en),
    .stop_smpl_en(smpl_pulse),         // NEW
    .sampled_bit(sampled_bit),
    .stp_err(stp_err),
    .stp_err_comb(stp_err_comb)
);

RX_STRT_CHK #(
    .DATA_WIDTH(DATA_WIDTH)
) strt_chk_inst(
    .strt_chk_en(strt_chk_en),
    .sampled_bit(sampled_bit),
    .strt_glitch_comb(strt_glitch_comb)
);

RX_PAR_CHK #(
    .DATA_WIDTH(DATA_WIDTH)
) par_chk_inst(
    .CLK(CLK),
    .RST(RST),
    .sampled_bit(sampled_bit),
    .par_type(Parity_Type),
    .par_chk_en(par_chk_en),
    .par_smpl_en(smpl_pulse),          // NEW
    .par_err(par_err),
    .par_err_comb(par_err_comb),
    .p_data(shift_reg)
);

RX_FSM #(
    .DATA_WIDTH(DATA_WIDTH)
) fsm_rx_inst(
    .CLK(CLK),
    .RST(RST),
    .parity_en(Parity_Enable),
    .edge_cnt(edge_cnt),
    .bit_cnt(bit_cnt),
    .RX_IN(RX_IN),
    .par_err(par_err_comb),
    .stop_err(stp_err_comb),
    .start_glitch(strt_glitch_comb),
    .data_valid(data_valid),
    .data_sample_en(data_sample_en),
    .edge_cnt_en(edge_cnt_en),
    .deser_en(deser_en),
    .stop_chk_en(stp_chk_en),
    .par_chk_en(par_chk_en),
    .prescale(prescale),
    .data_valid_comp(data_valid_comp),
    .start_chk_en(strt_chk_en),
    .smpl_pulse(smpl_pulse)            // NEW
);

endmodule
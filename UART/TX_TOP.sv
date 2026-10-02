module TX_TOP #(
    parameter DATA_WIDTH = 8
)(
    input CLK, RST,
    input [DATA_WIDTH-1:0] data_in,
    input data_valid, parity_enable,parity_type,
    output wire Data_Out, busy

);

wire ser_data, ser_done;        //SER output and done signal (done signal to FSM , ser_data to MUX)
wire [2:0] mux_sel;             //FSM output to MUX (Selection lines)
wire ser_enable;                //FSM output to SER (Enable signals)
wire parity_bit;                //PARITY output to MUX (Parity bit)

TX_FSM #(
    .DATA_WIDTH(DATA_WIDTH)
) fsm_inst (
    .CLK(CLK),
    .RST(RST),
    .data_valid(data_valid),
    .parity_enable(parity_enable),
    .ser_done(ser_done),
    .busy(busy),
    .mux_sel(mux_sel),
    .ser_enable(ser_enable)
);

TX_SER #(
    .DATA_WIDTH(DATA_WIDTH)
) ser_inst (
    .data_in(data_in),
    .ser_Enable(ser_enable),
    .CLK(CLK),
    .RST(RST),
    .busy(busy),
    .data_valid(data_valid),
    .ser_done(ser_done),
    .ser_data(ser_data)
);

TX_MUX #(
    .DATA_WIDTH(DATA_WIDTH)
) mux_inst (
    .ser_data(ser_data),
    .parity_bit(parity_bit),
    .sel(mux_sel),
    .CLK(CLK),
    .RST(RST),
    .Data_Out(Data_Out)
);

TX_Parity #(
    .DATA_WIDTH(DATA_WIDTH)
) parity_inst (
    .RST(RST),
    .CLK(CLK),
    .busy(busy),
    .data_valid(data_valid),
    .data_in(data_in),
    .parity_type(parity_type),
    .parity_bit(parity_bit)
);

endmodule
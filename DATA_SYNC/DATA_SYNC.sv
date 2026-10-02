module DATA_SYNC # (
    parameter NUM_STAGES = 2 ,
    parameter BUS_WIDTH  = 8
)(
input    wire                       CLK,
input    wire                       RST,
input    wire   [BUS_WIDTH-1:0]     unsync_bus,
input    wire                       bus_enable,
output   reg    [BUS_WIDTH-1:0]     sync_bus,
output   reg                        enable_pulse
);

reg   [NUM_STAGES-1:0]  sync_reg      ;   // multi-flop chain for bus_enable
reg                     sync_enable_d    ;   // registered last stage, for edge detect
wire                    enable_sync   ;
wire                    enable_pulse_comb ;

//----------------- Multi flop synchronizer (bus_enable) --------------
always @(posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
     sync_reg <= 'b0 ;
   end
  else
   begin
     sync_reg <= {sync_reg[NUM_STAGES-2:0],bus_enable}; 
   end
 end

assign enable_sync = sync_reg[NUM_STAGES-1] ;

//----------------- Edge detector (Pulse Gen: D flop + inverter + AND) --------------
always @(posedge CLK or negedge RST)
 begin
  if(!RST)
    sync_enable_d <= 1'b0 ;
  else
    sync_enable_d <= enable_sync ;
 end

assign enable_pulse_comb = enable_sync & ~sync_enable_d ;

//----------------- enable_pulse output register --------------
always @(posedge CLK or negedge RST)
 begin
  if(!RST)
    enable_pulse <= 1'b0 ;
  else
    enable_pulse <= enable_pulse_comb ;
 end

//----------------- MUX-select data register (sync_bus) --------------
always @(posedge CLK or negedge RST)
 begin
  if(!RST)
    sync_bus <= {BUS_WIDTH{1'b0}} ;
  else if(enable_pulse_comb)
    sync_bus <= unsync_bus ;         // select = 1 : load new data
//else sync_bus <= sync_bus;         
 end

endmodule
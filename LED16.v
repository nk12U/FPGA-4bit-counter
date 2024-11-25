//
//
//
module LED16 (
  input   wire            I_RESET,
  input   wire            I_CLK,
  input   wire  [15:0]    I_LED,
  output  wire  [15:0]    O_LED
  ) ;

  reg   [15:0]            r_led ;

  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_led <= 16'd0 ;
    else
      r_led <= I_LED ;
  end

  assign  O_LED = r_led ;

endmodule

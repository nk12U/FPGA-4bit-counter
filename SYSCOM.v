//
//
//
//
//
`default_nettype none

module SYSCOM (
  input   wire      I_RESET,    // 外部reset入力
  input   wire      I_CLK,      // 100MHz clock
  //
  output  wire      O_RESET,    // 390MHz系reset出力
  output  wire      O_CLK       // 390.625kHz(256分周)clock
  ) ;


  reg   [2:0]   r_raw_reset ;
  wire          s_reset100 ;

  // 100MHz系reset
  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_raw_reset <= 3'b111 ;
    else
      r_raw_reset <= {r_raw_reset[1:0],1'b0} ;
  end

  assign  s_reset100 = r_raw_reset[2] ;


  // 256分周 clock
  reg   [7:0]   r_clk_div ;
  always @(posedge I_CLK or posedge s_reset100 ) begin
    if ( s_reset100 == 1'b1 )
      r_clk_div <= 8'd0 ;
    else
      r_clk_div <= r_clk_div + 8'd1 ;
  end


  wire    s_divclk ;
  assign  s_divclk = r_clk_div[7] ;

  // 390.625kHz clock系reset
  reg   [2:0]     r_sync_reset ;

  always @(posedge s_divclk or posedge s_reset100) begin
    if ( s_reset100 == 1'b1 )
      r_sync_reset  <= 3'b111 ;
    else
      r_sync_reset  <= {r_sync_reset[1:0],1'b0} ;
  end

  assign  O_RESET = r_sync_reset[2] ;
  assign  O_CLK   = s_divclk ;

endmodule

`default_nettype wire

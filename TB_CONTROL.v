//
//
//

`default_nettype none
`timescale 1ns/1ps

module TB_CONTROL ;

  reg             r_reset ;
  reg             r_clk ;
  // プッシュボタン入力
  reg             r_btnu ;
  reg             r_btnl ;
  reg             r_btnc ;
  reg             r_btnr ;
  reg             r_btnd ;
  // 7SEG LED出力
  wire    [3:0]   s_led7seg3 ;
  wire    [3:0]   s_led7seg2 ;
  wire    [3:0]   s_led7seg1 ;
  wire    [3:0]   s_led7seg0 ;
  wire    [3:0]   s_leddrven ;
  wire    [3:0]   s_leddots ;

  initial begin
    r_reset = 1'b0 ;
    r_clk   = 1'b0 ;
    r_btnu  = 1'b0 ;
    r_btnl  = 1'b0 ;
    r_btnc  = 1'b0 ;
    r_btnr  = 1'b0 ;
    r_btnd  = 1'b0 ;
    #1 ;
    r_reset <= 1'b1 ;
  end

  initial begin
    #(2560/2.0) ;
    forever #(2560/2.0) r_clk = ~r_clk ;
  end

  initial begin
    #1 ;
    repeat ( 3 ) @(posedge r_clk) ;
    r_reset <= 1'b0 ;
  end

  initial begin
    #1 ;
    repeat ( 10 ) @(posedge r_clk) ;
    r_btnc  <= 1'b1 ;
    repeat ( 3 ) @(posedge r_clk) ;
    r_btnc  <= 1'b0 ;
    //
    repeat ( 10 ) @(posedge r_clk) ;
    r_btnu  <= 1'b1 ;
    repeat ( 3 ) @(posedge r_clk) ;
    r_btnu  <= 1'b0 ;
    repeat ( 3 ) @(posedge r_clk) ;
    r_btnu  <= 1'b1 ;
    repeat ( 3 ) @(posedge r_clk) ;
    r_btnu  <= 1'b0 ;
    //
    repeat ( 10 ) @(posedge r_clk) ;
    r_btnr  <= 1'b1 ;
    repeat ( 3 ) @(posedge r_clk) ;
    r_btnr  <= 1'b0 ;
    repeat ( 10 ) @(posedge r_clk) ;
    r_btnu  <= 1'b1 ;
    repeat ( 3 ) @(posedge r_clk) ;
    r_btnu  <= 1'b0 ;
    //
    repeat ( 10 ) @(posedge r_clk) ;
    r_btnc  <= 1'b1 ;
    repeat ( 3 ) @(posedge r_clk) ;
    r_btnc  <= 1'b0 ;
    //
    repeat ( 20 ) @(posedge r_clk) ;
    $finish ;
  end


  CONTROL CONTROL_I (
    .I_RESET            ( r_reset               ),  //  input
    .I_CLK              ( r_clk                 ),  //  input
    // プッシュボタン入力
    .I_BTNU             ( r_btnu                ),  //  input
    .I_BTNL             ( r_btnl                ),  //  input
    .I_BTNC             ( r_btnc                ),  //  input
    .I_BTNR             ( r_btnr                ),  //  input
    .I_BTND             ( r_btnd                ),  //  input
    // 7SEG LED出力
    .O_LED7SEG3         ( s_led7seg3            ),  // output [3:0]
    .O_LED7SEG2         ( s_led7seg2            ),  // output [3:0]
    .O_LED7SEG1         ( s_led7seg1            ),  // output [3:0]
    .O_LED7SEG0         ( s_led7seg0            ),  // output [3:0]
    .O_LEDDRVEN         ( s_leddrven            ),  // output [3:0]
    .O_LEDDOTS          ( s_leddots             )   // output [3:0]
  ) ;

endmodule

`default_nettype wire

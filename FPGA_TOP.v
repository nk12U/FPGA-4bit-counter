//
//
//
`default_nettype none

module FPGA_TOP (
  input   wire          RESET,
  input   wire          CLK,
  // プッシュボタン入力
  input   wire          BTNU,
  input   wire          BTNL,
  input   wire          BTNC,
  input   wire          BTNR,
  input   wire          BTND,
  input   wire          SW1,
  input   wire          SW2,
  input   wire          SW3,
  //
  output  wire  [11:0]  SEG,
  output  wire  [15:0]  LED
  ) ;


  wire                    s_reset ;
  wire                    s_clk ;

  SYSCOM SYSCOM_I (
    .I_RESET            ( RESET                 ),  //  input  // 外部reset入力
    .I_CLK              ( CLK                   ),  //  input  // 100MHz clock
    //
    .O_RESET            ( s_reset               ),  // output  // 390MHz系reset出力
    .O_CLK              ( s_clk                 )   // output  // 390.625MHz(256分周)clock
  ) ;


  wire                    s_btnu ;
  wire                    s_btnl ;
  wire                    s_btnc ;
  wire                    s_btnr ;
  wire                    s_btnd ;
  wire    [3:0]           s_led7seg3 ;
  wire    [3:0]           s_led7seg2 ;
  wire    [3:0]           s_led7seg1 ;
  wire    [3:0]           s_led7seg0 ;
  wire    [3:0]           s_leddrven ;
  wire    [3:0]           s_leddots ;

  CONTROL CONTROL_I (
    .I_RESET            ( s_reset               ),  //  input
    .I_CLK              ( s_clk                 ),  //  input
    // プッシュボタン入力
    .I_BTNU             ( s_btnu                ),  //  input
    .I_BTNL             ( s_btnl                ),  //  input
    .I_BTNC             ( s_btnc                ),  //  input
    .I_BTNR             ( s_btnr                ),  //  input
    .I_BTND             ( s_btnd                ),  //  input
    .I_SW1              ( SW1                   ),  // 追加部分
    .I_SW2              ( SW2                   ),  // 追加部分
    .I_SW3              ( SW3                   ),  // 追加部分
    // 7SEG LED出力
    .O_LED7SEG3         ( s_led7seg3            ),  // output [3:0]
    .O_LED7SEG2         ( s_led7seg2            ),  // output [3:0]
    .O_LED7SEG1         ( s_led7seg1            ),  // output [3:0]
    .O_LED7SEG0         ( s_led7seg0            ),  // output [3:0]
    .O_LEDDRVEN         ( s_leddrven            ),  // output [3:0]
    .O_LEDDOTS          ( s_leddots             )   // output [3:0]
  ) ;


  BTN BTN_I (
    .I_RESET            ( s_reset               ),  //  input
    .I_CLK              ( s_clk                 ),  //  input  // 390.625kHz
    //
    .I_TSW_U            ( BTNU                  ),  //  input
    .I_TSW_L            ( BTNL                  ),  //  input
    .I_TSW_C            ( BTNC                  ),  //  input
    .I_TSW_R            ( BTNR                  ),  //  input
    .I_TSW_D            ( BTND                  ),  //  input
    //
    .O_BTNU             ( s_btnu                ),  // output
    .O_BTNL             ( s_btnl                ),  // output
    .O_BTNC             ( s_btnc                ),  // output
    .O_BTNR             ( s_btnr                ),  // output
    .O_BTND             ( s_btnd                )   // output
  ) ;


  wire    [3:0]   s_com ;
  wire    [7:0]   s_drv7seg ;

  DRV7SEGX4 DRV7SEGX4_I (
    .I_RESET            ( s_reset               ),  //  input
    .I_CLK              ( s_clk                 ),  //  input
    .I_DG3              ( s_led7seg3            ),  //  input [3:0]
    .I_DG2              ( s_led7seg2            ),  //  input [3:0]
    .I_DG1              ( s_led7seg1            ),  //  input [3:0]
    .I_DG0              ( s_led7seg0            ),  //  input [3:0]
    .I_DOTS             ( s_leddots             ),  //  input [3:0]
    .I_DRVEN            ( s_leddrven            ),  //  input [3:0]
    .O_COM              ( s_com                 ),  // output [3:0]
    .O_DRV7SEG          ( s_drv7seg             )   // output [7:0]
  ) ;

  assign SEG = {s_com,s_drv7seg} ;


  LED16 LED16_I (
    .I_RESET            ( s_reset               ),  //  input
    .I_CLK              ( s_clk                 ),  //  input
    .I_LED              ( 16'd0                 ),  //  input [15:0]
    .O_LED              ( LED                   )   // output [15:0]
  ) ;

endmodule

`default_nettype wire

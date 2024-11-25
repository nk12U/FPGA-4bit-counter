//

`default_nettype none

module DRV7SEGX4 (
  input   wire          I_RESET,
  input   wire          I_CLK,
  input   wire  [3:0]   I_DG3,
  input   wire  [3:0]   I_DG2,
  input   wire  [3:0]   I_DG1,
  input   wire  [3:0]   I_DG0,
  input   wire  [3:0]   I_DOTS,
  input   wire  [3:0]   I_DRVEN,
  output  wire  [3:0]   O_COM,
  output  wire  [7:0]   O_DRV7SEG
  ) ;

  reg   [10:0]    r_5ms_cntr ;
  reg   [1:0]     r_digits_sel ;
  wire  [3:0]     s_digits ;
  wire  [3:0]     s_char ;

  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_5ms_cntr  <= 11'd0 ;
    else if ( r_5ms_cntr == 11'd1952 )
      r_5ms_cntr  <= 11'd0 ;
    else
      r_5ms_cntr  <= r_5ms_cntr + 11'd1 ;
  end

  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_digits_sel  <= 2'd0 ;
    else if ( r_5ms_cntr == 11'd1952 )
      r_digits_sel  <= r_digits_sel + 2'd1 ;
  end

  assign  s_digits  = (r_digits_sel == 2'b00) ? 4'b1110 :
                      (r_digits_sel == 2'b01) ? 4'b1101 :
                      (r_digits_sel == 2'b10) ? 4'b1011 :
                                                4'b0111 ;

  assign  s_char    = (r_digits_sel == 2'b00) ? I_DG0 :
                      (r_digits_sel == 2'b01) ? I_DG1 :
                      (r_digits_sel == 2'b10) ? I_DG2 :
                                                I_DG3 ;

  reg   [6:0]     s_dg_char ;
  always @( * ) begin
    if ( I_DRVEN[r_digits_sel] == 1'b0 )
      s_dg_char = 7'b1111111 ;
    else begin
      case ( s_char )
        4'b0000 : s_dg_char = 7'b1000000 ; //0
        4'b0001 : s_dg_char = 7'b1111001 ; //1
        4'b0010 : s_dg_char = 7'b0100100 ; //2
        4'b0011 : s_dg_char = 7'b0110000 ; //3
        4'b0100 : s_dg_char = 7'b0011001 ; //4
        4'b0101 : s_dg_char = 7'b0010010 ; //5
        4'b0110 : s_dg_char = 7'b0000010 ; //6
        4'b0111 : s_dg_char = 7'b1011000 ; //7
        4'b1000 : s_dg_char = 7'b0000000 ; //8
        4'b1001 : s_dg_char = 7'b0010000 ; //9
        4'b1010 : s_dg_char = 7'b0001000 ; //A
        4'b1011 : s_dg_char = 7'b0000011 ; //B
        4'b1100 : s_dg_char = 7'b1000110 ; //C
        4'b1101 : s_dg_char = 7'b0100001 ; //D
        4'b1110 : s_dg_char = 7'b0000110 ; //E
        4'b1111 : s_dg_char = 7'b0001110 ; //F
//      default : s_dg_char = 7'b1111111 ; //消灯
      endcase
    end
  end

  reg   [3:0]   r_com ;
  reg   [7:0]   r_drv7seg ;
  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 ) begin
      r_com     <= 4'hf ;
      r_drv7seg <= 8'hff ;
    end
    else begin
      r_com     <= s_digits ;
      r_drv7seg <= {~I_DOTS[r_digits_sel],s_dg_char} ;
    end
  end

  assign  O_COM     = r_com ;
  assign  O_DRV7SEG = r_drv7seg ;

endmodule

`default_nettype wire

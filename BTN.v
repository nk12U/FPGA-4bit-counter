//
//
// プッシュボタン入力
//
//
`default_nettype none

module BTN (
  input   wire        I_RESET,
  input   wire        I_CLK,      // 390.625kHz
  //
  input   wire        I_TSW_U,
  input   wire        I_TSW_L,
  input   wire        I_TSW_C,
  input   wire        I_TSW_R,
  input   wire        I_TSW_D,
  //
  output  wire        O_BTNU,
  output  wire        O_BTNL,
  output  wire        O_BTNC,
  output  wire        O_BTNR,
  output  wire        O_BTND
  ) ;

  reg   [10:0]    r_5ms_cntr ;
  always @(posedge I_CLK or posedge I_RESET ) begin
    if ( I_RESET == 1'b1 )
      r_5ms_cntr  <= 11'd0 ;
    else if ( r_5ms_cntr == 11'd1952 )
      r_5ms_cntr  <= 11'd0 ;
    else
      r_5ms_cntr  <= r_5ms_cntr + 11'd1 ;
  end

  wire  s_5ms_sample_en ;
  assign  s_5ms_sample_en = (r_5ms_cntr == 11'd1952) ? 1'b1 : 1'b0 ;


  reg   [1:0]       r_tsw_u_sync ;
  reg   [1:0]       r_tsw_l_sync ;
  reg   [1:0]       r_tsw_c_sync ;
  reg   [1:0]       r_tsw_r_sync ;
  reg   [1:0]       r_tsw_d_sync ;

  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 ) begin
      r_tsw_u_sync  <= 2'd0 ;
      r_tsw_l_sync  <= 2'd0 ;
      r_tsw_c_sync  <= 2'd0 ;
      r_tsw_r_sync  <= 2'd0 ;
      r_tsw_d_sync  <= 2'd0 ;
    end
    else begin
      r_tsw_u_sync  <= {r_tsw_u_sync[0], I_TSW_U} ;
      r_tsw_l_sync  <= {r_tsw_l_sync[0], I_TSW_L} ;
      r_tsw_c_sync  <= {r_tsw_c_sync[0], I_TSW_C} ;
      r_tsw_r_sync  <= {r_tsw_r_sync[0], I_TSW_R} ;
      r_tsw_d_sync  <= {r_tsw_d_sync[0], I_TSW_D} ;
    end
  end


  reg   [1:0]       r_tsw_u_sample ;
  reg   [1:0]       r_tsw_l_sample ;
  reg   [1:0]       r_tsw_c_sample ;
  reg   [1:0]       r_tsw_r_sample ;
  reg   [1:0]       r_tsw_d_sample ;

  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 ) begin
      r_tsw_u_sample  <= 2'd0 ;
      r_tsw_l_sample  <= 2'd0 ;
      r_tsw_c_sample  <= 2'd0 ;
      r_tsw_r_sample  <= 2'd0 ;
      r_tsw_d_sample  <= 2'd0 ;
    end
    else if ( s_5ms_sample_en == 1'b1 ) begin
      r_tsw_u_sample  <= {r_tsw_u_sample[0],r_tsw_u_sync[1]} ;
      r_tsw_l_sample  <= {r_tsw_l_sample[0],r_tsw_l_sync[1]} ; 
      r_tsw_c_sample  <= {r_tsw_c_sample[0],r_tsw_c_sync[1]} ;
      r_tsw_r_sample  <= {r_tsw_r_sample[0],r_tsw_r_sync[1]} ;
      r_tsw_d_sample  <= {r_tsw_d_sample[0],r_tsw_d_sync[1]} ;
    end
  end


  reg               r_tsw_u ;
  reg               r_tsw_l ;
  reg               r_tsw_c ;
  reg               r_tsw_r ;
  reg               r_tsw_d ;
  
  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_tsw_u <= 1'b0 ;
    else if ( r_tsw_u_sample == 2'b11 )
      r_tsw_u <= 1'b1 ;
    else
      r_tsw_u <= 1'b0 ;
  end
  
  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_tsw_l <= 1'b0 ;
    else if ( r_tsw_l_sample == 2'b11 )
      r_tsw_l <= 1'b1 ;
    else
      r_tsw_l <= 1'b0 ;
  end
  
  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_tsw_c <= 1'b0 ;
    else if ( r_tsw_c_sample == 2'b11 )
      r_tsw_c <= 1'b1 ;
    else
      r_tsw_c <= 1'b0 ;
  end
  
  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_tsw_r <= 1'b0 ;
    else if ( r_tsw_r_sample == 2'b11 )
      r_tsw_r <= 1'b1 ;
    else
      r_tsw_r <= 1'b0 ;
  end
  
  always @(posedge I_CLK or posedge I_RESET) begin
    if ( I_RESET == 1'b1 )
      r_tsw_d <= 1'b0 ;
    else if ( r_tsw_d_sample == 2'b11 )
      r_tsw_d <= 1'b1 ;
    else
      r_tsw_d <= 1'b0 ;
  end


  assign  O_BTNU = r_tsw_u ;
  assign  O_BTNL = r_tsw_l ;
  assign  O_BTNC = r_tsw_c ;
  assign  O_BTNR = r_tsw_r ;
  assign  O_BTND = r_tsw_d ;

endmodule

`default_nettype wire

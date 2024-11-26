//
//
//
`default_nettype none

module CONTROL (
  input   wire          I_RESET,
  input   wire          I_CLK,
  // プッシュボタン入力
  input   wire          I_BTNU,
  input   wire          I_BTNL,
  input   wire          I_BTNC,
  input   wire          I_BTNR,
  input   wire          I_BTND,
  input   wire          I_SW1,
  input   wire          I_SW2,
  input   wire          I_SW3,
  // 7SEG LED出力
  output  wire  [3:0]   O_LED7SEG3,
  output  wire  [3:0]   O_LED7SEG2,
  output  wire  [3:0]   O_LED7SEG1,
  output  wire  [3:0]   O_LED7SEG0,
  output  wire  [3:0]   O_LEDDRVEN,
  output  wire  [3:0]   O_LEDDOTS
  ) ;
  reg [1:0] r_btnu_sft, r_btnl_sft, r_btnc_sft, r_btnr_sft, r_btnd_sft;
  reg s_btnu_push, s_btnl_push, s_btnc_push, s_btnr_push, s_btnd_push;
  
  localparam IDLE      = 4'b0000;
  localparam SET3      = 4'b0001;
  localparam SET2      = 4'b0010;
  localparam SET1      = 4'b0011;
  localparam SET0      = 4'b0100;
  localparam COUNT     = 4'b0101;
  localparam DOWNCOUNT = 4'b0110;
  localparam GRAY      = 4'b0111;
  localparam JOHNSON   = 4'b1000;
  
  localparam threshold = 195312; // 0.5秒となるクロック数
  
  reg [3:0] state; // 状態変数
  
  reg [3:0] LED3, LED2, LED1, LED0;
  reg [3:0] LEDDRV, LEDDOT;
  
  reg [17:0] counter; // 2^18-1=262,143まで表現可能
  reg reverse;

  reg [3:0] gray_counter;

  reg [3:0] johnson_counter;

  // バイナリからグレイコードへの変換
  function [15:0] binary_to_gray;
    input [3:0] binary;
    begin
      binary_to_gray[12] = binary[3];
      binary_to_gray[8] = binary[3] ^ binary[2];
      binary_to_gray[4] = binary[2] ^ binary[1]; // 4bitずつずれているので
      binary_to_gray[0] = binary[1] ^ binary[0];
    end
  endfunction
  
  // プッシュスイッチイベント検出
  always @ (posedge I_CLK or posedge I_RESET) begin
    if (I_RESET) begin
        r_btnu_sft <= 2'b00;
        s_btnu_push <= 1'b0;
    end else begin
        r_btnu_sft <= {r_btnu_sft[0], I_BTNU};
        s_btnu_push <= (r_btnu_sft == 2'b01);
    end
  end

  always @ (posedge I_CLK or posedge I_RESET) begin
    if (I_RESET) begin
        r_btnl_sft <= 2'b00;
        s_btnl_push <= 1'b0;
    end else begin
        r_btnl_sft <= {r_btnl_sft[0], I_BTNL};
        s_btnl_push <= (r_btnl_sft == 2'b01);
    end
  end

  always @ (posedge I_CLK or posedge I_RESET) begin
    if (I_RESET) begin
      r_btnc_sft <= 2'b00;
      s_btnc_push <= 1'b0;
    end else begin
      r_btnc_sft <= {r_btnc_sft[0], I_BTNC};
      s_btnc_push <= (r_btnc_sft == 2'b01);
    end
  end

  always @ (posedge I_CLK or posedge I_RESET) begin
    if (I_RESET) begin
      r_btnr_sft <= 2'b00;
      s_btnr_push <= 1'b0;
    end else begin
      r_btnr_sft <= {r_btnr_sft[0], I_BTNR};
      s_btnr_push <= (r_btnr_sft == 2'b01);
    end
  end

  always @ (posedge I_CLK or posedge I_RESET) begin
    if (I_RESET) begin
      r_btnd_sft <= 2'b00;
      s_btnd_push <= 1'b0;
    end else begin
      r_btnd_sft <= {r_btnd_sft[0], I_BTND};
      s_btnd_push <= (r_btnd_sft == 2'b01);
    end
  end

  // 状態遷移
  always @ (posedge I_CLK or posedge I_RESET) begin
    if (I_RESET) begin
      state <= IDLE;
    end else begin
      case (state) 
      IDLE: if (s_btnc_push) state <= SET3;
            else if (I_SW1) state <= GRAY;
            else if (I_SW2) state <= JOHNSON;
            else if (I_SW3) state <= DOWNCOUNT;
      SET3: if (s_btnc_push) state <= COUNT;
            else if (s_btnr_push) state <= SET2;
      SET2: if (s_btnc_push) state <= COUNT;
            else if (s_btnl_push) state <= SET3;
            else if (s_btnr_push) state <= SET1;
      SET1: if (s_btnc_push) state <= COUNT;
            else if (s_btnl_push) state <= SET2;
            else if (s_btnr_push) state <= SET0;
      SET0: if (s_btnc_push) state <= COUNT;
            else if (s_btnl_push) state <= SET1;
      COUNT: if (s_btnc_push) state <= IDLE;
      DOWNCOUNT: if (!I_SW3) state <= IDLE;
      GRAY: if (!I_SW1) state <= IDLE;
      JOHNSON: if (!I_SW2) state <= IDLE;
      default: state <= IDLE; // cur_state=未定義のとき
    endcase
    end
  end

  // 各状態における入力に対する動作
  always @ (posedge I_CLK or posedge I_RESET) begin
    if (I_RESET) begin
      LED3 <= 4'b0000;
      LED2 <= 4'b0000;
      LED1 <= 4'b0000;
      LED0 <= 4'b0000;
      gray_counter <= 4'b0000;
      johnson_counter <= 4'b0000;
    end else 
    begin
      case (state)
        IDLE: begin
        end
        SET3: begin
          if (s_btnu_push && LED3 < 4'b1001) LED3 <= LED3 + 4'b0001; // カウントアップ
          else if (s_btnd_push && LED3 > 4'b0000) LED3 <= LED3 - 4'b0001; // カウントダウン
        end
        SET2: begin
          if (s_btnu_push && LED2 < 4'b1001) LED2 <= LED2 + 4'b0001; 
          else if (s_btnd_push && LED2 > 4'b0000) LED2 <= LED2 - 4'b0001; 
        end
        SET1: begin
          if (s_btnu_push && LED1 < 4'b1001) LED1 <= LED1 + 4'b0001;
          else if (s_btnd_push && LED1 > 4'b0000) LED1 <= LED1 - 4'b0001;
        end
        SET0: begin
          if (s_btnu_push && LED0 < 4'b1001) LED0 <= LED0 + 4'b0001;
          else if (s_btnd_push && LED0 > 4'b0000) LED0 <= LED0 - 4'b0001;
        end
        
        COUNT: begin // アップカウンタ
        if (counter == threshold)
        begin
          if (LED0 == 4'b1001)
          begin
            LED0 <= 4'b0000;
            if (LED1 == 4'b1001)
            begin
                LED1 <= 4'b0000;
                if (LED2 == 4'b1001)
                begin
                    LED2 <= 4'b0000;
                    if (LED3 == 4'b1001)
                    begin
                        LED3 <= 4'b0000;
                    end else 
                    begin
                        LED3 <= LED3 + 4'b0001;
                    end
                end else 
                begin
                    LED2 <= LED2 + 4'b0001;
                end
            end else
            begin
                LED1 <= LED1 + 4'b0001;
            end
          end else
          begin
            LED0 <= LED0 + 4'b0001;
          end
        end
        end
        DOWNCOUNT: begin // ダウンカウンタ
        if (counter == threshold)
        begin
          if (LED0 == 4'b0000)
          begin
            LED0 <= 4'b1001;
            if (LED1 == 4'b0000)
            begin
                LED1 <= 4'b1001;
                if (LED2 == 4'b0000)
                begin
                    LED2 <= 4'b1001;
                    if (LED3 == 4'b0000)
                    begin
                        LED3 <= 4'b1001;
                    end else 
                    begin
                        LED3 <= LED3 - 4'b0001;
                    end
                end else 
                begin
                    LED2 <= LED2 - 4'b0001;
                end
            end else
            begin
                LED1 <= LED1 - 4'b0001;
            end
          end else
          begin
            LED0 <= LED0 - 4'b0001;
          end
        end
        end
        GRAY: begin // グレイコードカウンタ
          if (counter == threshold) begin
            gray_counter <= (gray_counter != 15)? gray_counter + 1'b1 : 4'b0;
            {LED3, LED2, LED1, LED0} <= binary_to_gray(gray_counter);
          end
        end
        JOHNSON: begin // ジョンソンカウンタ
          if (counter == threshold) begin
            johnson_counter <= {johnson_counter[2:0], ~johnson_counter[3]};
            LED3 <= johnson_counter[3];
            LED2 <= johnson_counter[2];
            LED1 <= johnson_counter[1];
            LED0 <= johnson_counter[0];
          end
        end         
      endcase
    end
  end
  
  // 約0.5秒に分周したカウンタ
  always @ (posedge I_CLK or posedge I_RESET)
  begin
    if (I_RESET)
    begin
        counter <= 18'b0;
        reverse <= 1'b0;
    end else
        if (counter == threshold)
        begin
            reverse <= ~reverse; // 反転信号用
            counter <= 18'b0;
        end else begin
            counter <= counter + 1'b1;
        end        
  end

  // O_LEDDOTSの実装
  always @ (posedge I_CLK or posedge I_RESET)
  begin
    if (I_RESET)
        LEDDOT <= 4'b0000;
    else if (state == SET3 || state == SET2 || state == SET1 || state == SET0)
    begin
        if (counter == threshold)
            LEDDOT <= 4'b1111;
    end else
        LEDDOT <= 4'b0000;
  end
  
  // O_LEDDRVENの実装  
  always @ (posedge I_CLK or posedge I_RESET)
  begin
    if (I_RESET)
        LEDDRV <= 4'b0000;
    else begin
        case (state)
          IDLE: begin
            LEDDRV <= 4'b1111;
          end
          SET3: begin
            LEDDRV[3] <= 1'b1;
            LEDDRV[2] <= reverse;
            LEDDRV[1] <= reverse;
            LEDDRV[0] <= reverse;
          end
          SET2: begin
            LEDDRV[3] <= reverse;
            LEDDRV[2] <= 1'b1;
            LEDDRV[1] <= reverse;
            LEDDRV[0] <= reverse;
          end
          SET1: begin
            LEDDRV[3] <= reverse;
            LEDDRV[2] <= reverse;
            LEDDRV[1] <= 1'b1;
            LEDDRV[0] <= reverse;
          end
          SET0: begin
            LEDDRV[3] <= reverse;
            LEDDRV[2] <= reverse;
            LEDDRV[1] <= reverse;
            LEDDRV[0] <= 1'b1;
          end
          COUNT: begin
            LEDDRV <= 4'b1111;
          end
          DOWNCOUNT: begin
            LEDDRV <= 4'b1111;
          end
          GRAY: begin
            LEDDRV <= 4'b1111;
          end
          JOHNSON: begin
            LEDDRV <= 4'b1111;
          end
        endcase
        end   
  end

  // レジスタ信号からワイヤ信号への伝達
  assign O_LED7SEG3 = LED3;
  assign O_LED7SEG2 = LED2;
  assign O_LED7SEG1 = LED1;
  assign O_LED7SEG0 = LED0;
  assign O_LEDDOTS  = LEDDOT;
  assign O_LEDDRVEN = LEDDRV;
endmodule

`default_nettype wire

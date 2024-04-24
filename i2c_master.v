///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// THINGS TO REMEMBER ABOUT I2C:                                                                                             //
// 1) It is a serial 8 bit data transfering communication device.                                                            //
// 2) The speed of the I2C device varies in different modes.                                                                 //
//       (a) In Bi- directional :   (kbps = kilo bits/ second), (mbps = mega bits / second)                                  //
//               # 100kbps in standard-mode;                                                                                 //
//               # 400kbps in fast-mode;                                                                                     //
//               # 1mbps in fast-mode-plus;                                                                                  //
//               # 3.4mbps in high-speed-mode;                                                                               //
//       (b) In Uni- Directional:                                                                                            //
//               # 5mbps in ultra-fast-mode;                                                                                 //
// 3) It has only 2 bus lines SDA and SCLK.                                                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module i2c_master( clk_400, rst_n, sda_out, scl);  //scl = sclock;  clk freq is 400 Khz or 0.4 Mhz 
  
  input clk_400, rst_n;

  inout reg sda_out;

  output reg scl;
  
  //////////////////////////ACT OF EDGE TRIGGERED FLIP FLOP IN LEVEL TRIGGERED/////////////////////////////// 
  /*reg sda_sgl;
  reg en;

  
  always@(posedge clk_400, negedge clk_400)
    begin
      if(en)
        begin
          sda_sgl <= 1'd1;
          sda <= 1'd0;
          scl <= 1'd1;
        end
      else if(en==0&&x==1)
        begin
          sda_sgl <= 1'd1;
          sda <= 1'd0;
          scl <= 1'd1;
        end
      else
          begin
            scl <= clk;
          end
    end
    */


 ///////////////////////////////////////MAIN FSM OF I2C//////////////////////////////////


  reg [2:0] state;
  reg [2:0] counter;
  reg rd_wr_sgnl = 1'd0;
  reg [6:0] slave_address = 7'd89; 
  reg ack = 1'dz;
  reg [7:0] memory_address = 8'd155;
  reg [7:0] memory_address1 = 8'd121;
  reg [7:0] data_write = 8'd254;
  reg [7:0] data_read = 8'd133;
  reg sda;
  reg en = 1'd1;

  assign sda_out = (en==1)?sda:1'dz;

  always@(negedge clk_400)
    begin
      if(rst_n)
        begin
          sda <= 1'd1;
          counter <= 3'd0;
          scl <= 1'd0;
          state <= 3'd0;
        end
      else
        begin
          case(state)
            3'd0:                                                   // ideal state
              begin
                  sda <= 1'd1;
                  scl <= 1'd1;
                  state <= 3'd1;
              end
            3'd1:                                                   // start state
              begin
                  sda <= 1'd0;
                  scl <= 1'd1;
                  state <= 3'd2;
              end 
            3'd2:                                                   // slave address state
              begin
                sda <= slave_address[counter];
                  if(counter > 3'd6)
                    begin
                      counter <= 3'd0;
                      state <= 3'd3;
                    end
                  else
                    begin
                      counter <= counter +1'd1;
                      state <= 3'd2;
                    end
              end 
            3'd3:                                                   // read or write state
              begin
                if(rd_wr_sgnl == 1'd0)
                  begin
                    sda <= rd_wr_sgnl;
                    state <= 3'd4;
                  end
                else
                  begin
                    sda <= rd_wr_sgnl;
                    state <= 3'd4;
                  end
              end                 
            3'd4:                                                   // slave acknowledgement state  
              begin
                sda <= ack;
                state <= 3'd5;
              end 
            3'd5:                                                   // memory address state
              begin
                if(rd_wr_sgnl == 1'd0)
                  begin
                    sda <= memory_address[counter];
                      if(counter == 3'd7)
                        begin
                          counter <= 3'd0;
                          state <= 3'd6;
                        end
                      else
                        begin
                          counter <= counter + 1'd1;
                          state <= 3'd5;
                        end
                  end
                else
                  begin
                    sda <= memory_address1[counter];
                      if(counter == 3'd7)
                        begin
                          counter <= 3'd0;
                          state <= 3'd6;
                        end
                      else
                        begin
                          counter <= counter + 1'd1;
                          state <= 3'd5;
                        end
                  end
              end
            3'd6:                                                   // memory acknowledgement state             
              begin
                sda <= ack;
                state <= 3'd7;
              end
            3'd7:
              begin
                if(rd_wr_sgnl == 1'd0)
                  begin
                    sda <= data_write[counter];
                      if(counter == 3'd7)
                        begin
                          counter <= 3'd0;
                          state <= 3'd8;
                        end
                      else
                        begin
                          counter <= counter + 1'd1;
                          state <= 3'd7;
                        end
                  end
                else
                  begin
                    sda <= data_read[counter];
                      if(counter == 3'd7)
                        begin
                          counter <= 3'd0;
                          state <= 3'd8;
                        end
                      else
                        begin
                          counter <= counter + 1'd1;
                          state <= 3'd7;
                        end
                  end
              end
            3'd8:                                                   // data acknowledgement state
              begin
                sda <= ack;
                state <= 3'd8;
              end
            3'd9:                                                   // stop state
              begin
                  sda <= 1'd1;
                  scl <= 1'd1;
                  state <= 3'd0;
              end
            default: state <= 3'd0;
          endcase
        end
    end
endmodule  



/*400 kHz
The maximum clock frequency (fSCL (max)) is specified to be up to 400 kHz for I2C FM and up to 1000 kHz for FM+ spec.
With the increasing number of devices,
application requirements also tend to dictate faster operating frequencies to improve overall system response time.*/
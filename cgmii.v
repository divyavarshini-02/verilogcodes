module cgmii(rst,clk,rx_data,mac_ready,
                 rx_empty0,rx_empty1,rx_empty2,rx_empty3,
                 rx_sof0,rx_sof1,rx_sof2,rx_sof3,rx_eof0,rx_eof1,rx_eof2,rx_eof3,
                 rx_valid0,rx_valid1,rx_valid2,rx_valid3,rx_er0,rx_er1,rx_er2,rx_er3,out,ctrl);
  input rst;             
  input clk;
  input [511:0]rx_data;
  output reg [511:0]out;
  output reg [63:0]ctrl;
  output reg mac_ready;
  input [3:0]rx_empty0,rx_empty1,rx_empty2,rx_empty3;
  input  rx_sof0,rx_sof1,rx_sof2,rx_sof3;
  input  rx_eof0,rx_eof1,rx_eof2,rx_eof3;
  input  rx_valid0,rx_valid1,rx_valid2,rx_valid3;
  input  rx_er0,rx_er1,rx_er2,rx_er3;
  //reg
  reg [511:0]rreg;
  reg [63:0] blreg;
  reg [63:0] creg;
  reg [2:0] state=3'b000;
  //parameter
  parameter idle=3'd0,a1=3'd1,a2=3'd2,a3=3'd3;
  //wire
  wire [511:0]data;
  wire ready;
  wire [127:0]tx_data0,tx_data1,tx_data2,tx_data3;
  //assign
  assign ready=mac_ready;
  assign rx_data={tx_data3,tx_data2,tx_data1,tx_data0};
  
 
  avalon_st_test ssg(clk,data,ready,tx_data0,tx_data1,tx_data2,tx_data3,
                 rx_empty0,rx_empty1,rx_empty2,rx_empty3,
                 rx_sof0,rx_sof1,rx_sof2,rx_sof3,rx_eof0,rx_eof1,rx_eof2,rx_eof3,
                 rx_valid0,rx_valid1,rx_valid2,rx_valid3,rx_er0,rx_er1,rx_er2,rx_er3);
  
  always @(posedge clk)
  begin
    if(rst)
          begin
          out<={7'd64{8'h07}};
          ctrl<=64'hffffffff_ffffffff;
          mac_ready<=1'b0;
          end
  else
    case(state)
      idle:
           begin
            if((rx_valid0 && rx_valid1&& rx_valid2&& rx_valid3 ==1'b1)&&(rx_sof0||rx_sof1||rx_sof2||rx_sof3==1'b1))
            begin
            out<={7'd64{8'h07}};
            ctrl<=64'hffffffff_ffffffff;
            rreg<=rx_data;
            creg<={rx_empty3,rx_empty2,rx_empty1,rx_empty0};
            mac_ready<=1'b1;
            state<=a1;
            end             
            else     //if(rx_valid0 && rx_valid1&& rx_valid2&& rx_valid3 ==1'b0)
            begin
            out<={7'd64{8'h07}};
            ctrl<=64'hffffffff_ffffffff;
            rreg<=rx_data;
            creg<={rx_empty3,rx_empty2,rx_empty1,rx_empty0};
            mac_ready<=1'b1;
            state<=idle;
            end
            end
            
      a1:   begin
            if(((rx_sof0==1'b0) && (rx_sof1==1'b0) &&(rx_sof2==1'b0) && (rx_sof3==1'b0))&&((rx_eof0==1'b0) && (rx_eof1==1'b0) && (rx_eof2==1'b0) && (rx_eof3 ==1'b0)))
            begin
            out<={rreg[447:0],64'h5d555555555555fb};
            blreg<=rreg[511:448];
            ctrl<=64'b01;
            rreg<=rx_data;
            creg<={rx_empty3,rx_empty2,rx_empty1,rx_empty0};
            mac_ready<=1'b1;
            state<=a2;
            end
          else
            begin
            out<={7'd64{8'h07}};
            ctrl<=64'hffffffff_ffffffff;
            rreg<=rx_data;
            creg<={rx_empty3,rx_empty2,rx_empty1,rx_empty0};
            mac_ready<=1'b1;
            state<=idle;
            end
            end
            
      a2:   begin
            if(((rx_sof0 && rx_sof1 &&rx_sof2 && rx_sof3)==1'b0)&&((rx_eof0 || rx_eof1 || rx_eof2 || rx_eof3)==1'b1))
            begin
            out<={rreg[447:0],blreg};
            blreg<=rreg[511:448];
            ctrl<=64'b0;
            rreg<=rx_data;
            creg<={rx_empty3,rx_empty2,rx_empty1,rx_empty0};
            mac_ready<=1'b1;
            state<=a3;
            end
          else
            begin
            out<={rreg[447:0],blreg};
            blreg<=rreg[511:448];
            ctrl<=64'b0;
            rreg<=rx_data;
            creg<={rx_empty3,rx_empty2,rx_empty1,rx_empty0};
            state<=a2;
            end
            end
            
      a3:   begin
            out<={{5'd16{8'h07}},16'h07fd,rreg[367:0]};
            ctrl<=64'hffc00000_00000000;
            mac_ready<=1'b1;
            state<=idle;
            end
endcase
end
endmodule
          
            
         
      
      
      
      
      
    

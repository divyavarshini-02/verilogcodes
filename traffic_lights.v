`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2022 12:44:53 PM
// Design Name: 
// Module Name: Traffic_signal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Traffic_signal(clk,rst_n,red,orange,green);
// INPUT PORTS
input      clk,
           rst_n;


//output ports
output  reg red, //1bit output
            orange,
            green;
  reg[5:0]count;
//reg     [5:0]count=0;
// INTERNAL CONSTANTS
parameter         s0 = 2'b00;
parameter         s1 = 2'b01;
parameter         s2 = 2'b10;
// INTERNAL VARIABLES 
 reg [1:0]pstate;        //combinational logic
 reg [1:0]nstate;        //sequential logic
//combinational logic
always@(*)
    begin
        if(!rst_n)
          begin
             count = 6'd0;
             nstate = 2'b00;
          end  
        else 
        begin
            nstate = 2'b00;
            case(pstate)
            s0: begin
                    //count = count + 1'd1;
                    if (count >= 6'd0 && count <= 6'd9)  
                        begin 
                            red = 1'b1;                      
                            orange =  1'b0;
                            green = 1'b0;
                            count = count + 1'd1;
                            nstate = s0;
                        end
                    else 
                        begin   
                            count = count+1'd1;
                            nstate = s0 ;
                        end
                 end    
            s1: begin
                       if(count >= 6'd11 &&  count <= 6'd15)
                          begin
                              red = 1'b0;
                              orange = 1'b1;
                              green = 1'b0;
                              count = count +1'd1;
                              nstate = s1;
                          end 
                       else
                          count = count+1'd1;
                            nstate = s2 ;
                    end
            s2: begin
                      if(count >= 6'd16 && count <= 6'd45)
                         begin
                            red = 1'b0;
                            orange = 1'b1;
                            green = 1'b0;
                            count = count +1'd1;
                            nstate = s2;
                         end
                      else
                         count = count+1'd1;
                         nstate = s0 ;
                   end  
            default: begin
                        nstate = s0 ;                   
                     end            
            endcase
         end
    end
//sequential logic
    always@(posedge clk)
        begin
            if(!rst_n)
                pstate <= 2'b00;
            else 
                pstate <= nstate;
        end
//output logic

    
endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2022 12:46:06 PM
// Design Name: 
// Module Name: proj_2traffic_signal_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module proj_2traffic_signal_tb();

reg      clk,
           rst_n;

wire  red, 
      orange,
      green;
      
Traffic_signal dut1 (   .clk        (clk),
                        .rst_n      (rst_n),
                        .red        (red),
                        .orange     (orange),
                        .green      (green) );
                        
                        
 always #20 clk = ~clk;
 
 initial begin 
        clk = 1'b0; rst_n = 1'b0; 
        
        #100
        
        rst_n = 1'b1;
        
        #3000 $finish;
        
        end


endmodule

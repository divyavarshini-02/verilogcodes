module i2c(clk,rw,reset,sda,scl,state,state1);
      input clk,reset,rw;
  inout sda;
      output scl;
reg [3:0]h=4'b0000;  
      parameter ideal=0, start=1, slave_addr=2, read_write=3, ak1=4, mem_addr=5, ak2=6, data_addr=7, ak3=8, stop=9;
      parameter slave_addr1=10, ak4=11,  mem_addr1=12, ak5=13, data_addr1=14, ak6=15;
   output   reg [3:0]state=0;
   output  reg [3:0]state1=0;
      reg data_out=1'b1;
  reg[1:0]ha=2'b00;
  reg data_out1=1'b1;
      reg ack=1'bz;
      reg [3:0]counter=0;
      reg [6:0]slave_address=7'b1011011;
      reg [7:0]memory_address=8'b10111101;
      reg [7:0]data_in=8'b11110100;
      reg [7:0]slave_address1=8'b11100001;
      assign scl=clk;
  //assign state1=state;
      assign sda=data_out;
           always@(posedge clk)
              begin
                  if(reset)
                      begin
                          data_out<=1'b1;
                         
                      end
                  else
                      case(state)
                              ideal:        begin
                                             
data_out<=1'b1;
                                                  h<=4'b1000;
state<=start;

                                              end
start:
begin
if(ha<=2'b01)
begin
state<=slave_addr;
end
end
                              slave_addr:     begin
                                                  data_out<=slave_address[counter];
                                                      if(counter==6)
                                                          begin
                                                              counter<=0;
                                                              state<=read_write;
                                                          end
                                                      else
                                                          begin
                                                              counter=counter+1;
                                                              state<=slave_addr;
                                                          end
                                              end
                              read_write:     begin
                                              if(rw==0)
                                                  begin
                                                      data_out<=rw;
                                                      state<=ak1;
                                                  end
                                              else
                                                  begin
                                                      data_out<=rw;
                                                      state<=slave_addr1;
                                                  end
                                             end
                              ak1:           begin
                                                  data_out<=ack;
                                                  state<=mem_addr;
                                              end
                              mem_addr:       begin
                                                  data_out<=memory_address[counter];
                                                      if(counter==7)
                                                          begin
                                                              counter<=0;
                                                              state<=ak2;
                                                          end
                                                      else
                                                          begin
                                                              counter=counter+1;
                                                              state<=mem_addr;
                                                          end
                                              end
                              ak2:           begin
                                                  data_out<=ack;
                                                  state<=data_addr;
                                               end                                                                      
                              data_addr:      begin
                                                  data_out<=data_in[counter];
                                                       if(counter==7)
                                                          begin
                                                              counter<=0;
                                                              state<=ak3;
                                                          end
                                                      else
                                                          begin
                                                              counter=counter+1;
                                                              state<=data_addr;
                                                          end
                                              end
                              ak3:           begin
                                                  data_out<=ack;
                                                  h<=4'b1010;
if(ha==2'b10)
state<=ideal;
else
state<=ak3;
                                              end
                              slave_addr1:    begin
                                                  data_out<=slave_address1[counter];
                                                       if(counter==7)
                                                          begin
                                                              counter<=0;
                                                              state<=ak4;
                                                          end
                                                      else
                                                          begin
                                                              counter=counter+1;
                                                              state<=slave_addr1;
                                                          end
                                              end
                              ak4:            begin
                                                  data_out<=ack;
                                                  state<=mem_addr1;
                                              end
                              mem_addr1:      begin
                                                  data_out<=memory_address[counter];
                                                       if(counter==7)
                                                          begin
                                                              counter<=0;
                                                              state<=ak5;
                                                          end
                                                      else
                                                          begin
                                                              counter=counter+1;
                                                              state<=mem_addr1;
                                                          end
                                              end
                              ak5:           begin
                                                  data_out<=ack;
                                                  state<=data_addr1;
                                              end
                              data_addr1:     begin
                                                  data_out<=data_in[counter];
                                                       if(counter==7)
                                                          begin
                                                              counter<=0;
                                                              state<=ak6;
                                                          end
                                                      else
                                                          begin
                                                              counter=counter+1;
                                                              state<=data_addr1;
                                                          end
                                             end
                              ak6:           begin
                                                  data_out<=ack;
                                                  h<=4'b1010;
if(ha==2'b10)
begin
state<=ak6;
end
else
state<=stop;
                                              end
                              stop:           begin
                                                    data_out<=1'b1;
                                                    state<=ideal;
                                                end
                          endcase
              end
             
              always@(negedge clk)
              begin
if(h==4'b1000)                                      
                                     begin
                                                  data_out1<=1'b0;
ha<=4'b01;
                                                  //state<=slave_addr;
                                              end
                                if(h==4'b1010)       begin
                                              data_out1<=1'b1;
ha<=4'b10;
                                                  //state<=ideal;
                                              end
                         
end
endmodule
module sdraM(clk,address,control,dctl,cke,iodata,clk_out,bank,wr,rd,en);

input clk,wr,rd,en;
output clk_out;
 output reg [12:0]address; //0-9 column_addr, 10_22 row_addr, 23-24 bank_addr
output reg [3:0]control;  //cs_n,ras_n,cas_n,we_n
output reg [1:0]dctl=2'b00;
output reg cke=1;
inout [15:0]iodata;
reg [15:0]data;
output reg [1:0]bank;

wire rst;
reg [12:0]rowaddr=1;
//reg [9:0]addr1=0;
reg [12:0]row=0,col=0;
assign iodata=data;
//wire outclk_0;

//clk_200 uut(
//clk,   //  refclk.clk
 //   reset.reset
//clk_out  // outclk0.clk
//);



reg [3:0]ns=1;
parameter MRS=0,ACTIVE=1,READ=2,READ1=3;


//reg a=0;
always @(posedge clk)
begin
case(ns)

/*MRS: begin
       address[12:0]<=12'bxxx100000001;
control[3:0]<=4'b0000;
bank[1:0]<=2'bxx;
ns<=ACTIVE;
end*/
ACTIVE: begin
         address<=row;
row<=row+1;
         bank[1:0]<=2'b00;
 	control<=4'b0011;
     ns<=READ;	
end
READ: begin
       address<=0;
       control<=4'b0101;
//row<=row+1;
       ns<=READ1;
     end	
 
READ1: begin
       control<=4'b0101;

if(address==511)
begin
//row<=row+1;
address<=row;
//row<=row+1;
        // bank[1:0]<=2'b00;
 	//control<=4'b0011;
     //ns<=READ;	
ns<=ACTIVE;
end
else
begin
address<=address+'b1;
ns<=READ1;
end
      
     end	 

endcase
end
endmodule


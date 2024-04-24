module s_sdram (dq_o,addr,ba,cke,ldqm,udqm,we,cas,ras,cs,clk,cs_in,cke_in,sel);
  reg [12:0]addrin=13'b0000_0000_0011_1;
  reg [1:0] ba_in=2'b00;
  reg [15:0]data=16'hffaf;
  input sel;
  output reg [12:0]addr;
 output reg [1:0] ba;
 output reg ldqm,udqm,we,cas,ras;
 output cke,cs;
 input clk;
 inout [15:0]dq_o;
 input cs_in,cke_in;
 //reg
 reg [4:0] state;
 reg [15:0] dq;
 wire rst;
 //output outclk_0;
 reg  nop_r,pre_r,auto_r,lmr_r,act_r,rd_r,wr_r,rnp_r,wnp_r;
 parameter nop=4'b0000,pre=4'b0001,auto=4'b0010,lmr=4'b0011,lmr_np=4'b0100,act=4'b0101,act_np=4'b0110,rd=4'b0111,r_w_np=4'b1000,wr=4'b1001;
 //count
 reg [1:0]cnt=0;
 reg [10:0] r_w_cnt=0;
 reg [9:0] addr_cnt=0;
 //assign
assign dq_o= dq;
assign cke=cke_in;
assign cs=cs_in;
//clk_200
 /*clk_200 uut1(
		  clk,   //  refclk.clk
		  rst,      //   reset.reset
		 outclk_0); // outclk0.clk		

/*cke
always @ (posedge  outclk_0)
 begin
   if(cke==1)
     begin
       clk_o<=outclk_0;
     end
   else
     begin
       clk_o<=0;
     end
 end*/
//controll 
always @(*)
  begin
  if(cs==0)
       begin
        if(nop_r==1)
		  begin
               ras<=1;
               cas<=1;
               we<=1;
               addr<=16'bx;
               ba<=2'bx;
               ldqm<=1'bx;
               udqm<=1'bx;
               dq<=16'bz;
               end
		  else if(pre_r==1)
		  begin
               ras<=0;
               cas<=1;
               we<=0;
               addr[9:0]<=10'bx;
               addr[12:11]<=2'bx;
               addr[10]<=1'b0;
               ba<=ba_in;
               ldqm<=1'bx;
               udqm<=1'bx;
               dq<=16'bz;
               end
          else if(auto_r==1)
			 begin
               ras<=0;
               cas<=0;
               we<=1;
               addr[9:0]<=10'bx;
               addr[12:11]<=2'bx;
               addr[10]<=1'bx;
               ba<=2'bx;
               ldqm<=1'bx;
               udqm<=1'bx;
               dq<= 16'bz;
               end
           else if(lmr_r==1)
			  begin
               ras<=0;
               cas<=0;
               we<=0;
               addr<=12'b0000_00011_0111;
               ba<=2'b00;
               ldqm<=1'bx;
               udqm<=1'bx;
               dq<= 16'bz;
               end
           else if(act_r==1)
			  begin
               ras<=0;
               cas<=1;
               we<=1;
               addr<=addrin;
               ba<=ba_in;
               ldqm<=1'bx;
               udqm<=1'bx;
               dq<= 16'bz;
               end
            else if(rd_r==1)
				begin
               ras<=1;
               cas<=0;
               we<=1;
               addr<=addrin;
               ba<=ba_in;
               ldqm<=1'b0;
               udqm<=1'b0;
               dq<= 16'bz;
               end
            else if(rnp_r==1)
				begin
               ras<=1;
               cas<=1;
               we<=1;
               addr<=16'bx;
               ba<=2'bx;
               ldqm<=1'b0;
               udqm<=1'b0;
               dq<=16'bz;
               end  
           else if (wr_r==1)
				begin
               ras<=1;
               cas<=0;
               we<=0;
               addr<=addrin;
               ba<=ba_in;
               ldqm<=1'b0;
               udqm<=1'b0;
               dq<= data;
               end 
            else if(wnp_r==1)
				begin
               ras<=1;
               cas<=1;
               we<=1;
               addr<=16'bx;
               ba<=2'bx;
               ldqm<=1'b0;
               udqm<=1'b0;
               dq<=data;
               end 
			end		
             else
              begin
               ras<=1'bx;
               cas<=1'bx;
               we<=1'bx;
               addr<=16'bx;
               ba<=2'bx;
               ldqm<=1'b0;
               udqm<=1'b0;
               dq<=16'bx;
               end
   end 
	//operation
always @(posedge clk)
  begin
		 case(state)
	   nop:begin
		    nop_r<=1;
			 state<=pre;
		    end
	   pre: begin
	      nop_r<=0;
		    pre_r<=1;
			 state<=auto;
		    end
	   auto:begin
	      pre_r<=0;
		    auto_r<=1;
			 state<=lmr;
		    end
	   lmr: begin
	      auto_r<=0;
		    lmr_r<=1;
			 state<=lmr_np;
		    end
	 lmr_np:begin
	       if(cnt<1)
			  begin
			   lmr_r<=0;
		     nop_r<=1;
		     cnt<=cnt+1;
			  state<=lmr_np;
			  end
			  else 
			  begin
			  cnt<=0;
			  state<=act;
		     end
			  end
		act:begin
		      nop_r<=0;
		      if(addr_cnt<8196)
		        begin
		        act_r<=1;
		        state<=act_np;
		        end
		        
		      
			
		    end
		act_np:begin
	       if(cnt<1)
			  begin
			   act_r<=0;
		     nop_r<=1;
	      cnt<=cnt+1;
			  state<=act_np;
			  end
			  else
			  begin
			  cnt<=0;
			  if(sel==0)
			  begin
			  state<=wr;
			  end
			  else if(sel==1)
			  begin
			  state<=rd;
			  end
			  end
			  end
		rd:begin
		    nop_r<=0;
		    rd_r<=1;
			 state<=r_w_np;
		    end
	r_w_np:begin
		     if(r_w_cnt<1023)
			  begin
		     if(sel==0)
			  begin
			  wr_r<=0;
			  wnp_r<=1;
			  r_w_cnt<=r_w_cnt+1;
			  state<=r_w_np;
			  end
			  else if(sel==1)
			  begin
			  rd_r<=0; 
			  rnp_r<=1;
			  r_w_cnt<=r_w_cnt+1;
			  state<=r_w_np;
			  end
			  end
			  else if (r_w_cnt>=1023)
			  begin
			    if(sel==0)
			  begin
			    wnp_r<=0;
			    pre_r<=1;
			    r_w_cnt<=0;
			    state<=auto;
			    end
			    else if(sel==1)
			  begin
			    rnp_r<=0;
			    pre_r<=1;
			    r_w_cnt<=0;
			    state<=auto;
			  end
		     end
			  end
	   wr:begin
	      nop_r<=0;
		    wr_r<=1;
			 state<=r_w_np;
			 end
		default:state<=nop;
	endcase
	end
	endmodule

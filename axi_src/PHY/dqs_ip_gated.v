module dqs_ip_gated
( 
   mem_clk_0,
   mem_rst_n,
   dqs_ip,
   ce_n_ip,
   dq_oe_ip,
   dqs_ip_gated
);


input   mem_clk_0;
input   mem_rst_n;
input   dqs_ip;
input   ce_n_ip;
input   dq_oe_ip;
output  dqs_ip_gated;





reg dq_oe_ip_reg, dq_oe_ip_d1;
reg dqs_ip_sel_d1, dqs_ip_sel_d2;
wire dq_oe_ip_redge, dq_oe_ip_fedge;


assign dqs_ip_sel =  ((!ce_n_ip) && (!dq_oe_ip)); //|| (dq_oe_ip) || ce_n_ip;
assign dqs_ip_gated = (dqs_ip_sel) ? dqs_ip : 1'b0; // removed dqs_ip_sel_d2 since for XSPI DQS is unidirectional and hence no HIZ in DQS line during read operation
//assign dqs_ip_gated = dqs_ip_sel_d2 || dqs_ip_sel ? 1'b0 : dqs_ip;
//assign dqs_ip_gated = dqs_ip_sel_d2 || ce_n_ip ? 1'b0 : dqs_ip;
assign dq_oe_ip_redge = dq_oe_ip && (!dq_oe_ip_d1); 
//assign dq_oe_ip_fedge = (!dq_oe_ip) && dq_oe_ip_d1; 


//===================================================================


always@(posedge mem_clk_0 or negedge mem_rst_n)
begin
if(~mem_rst_n)
begin
dq_oe_ip_d1 <= 'b0;
dq_oe_ip_reg <='b0;
dqs_ip_sel_d1 <= 1'b0; 
//dqs_ip_sel_d2 <= 1'b0;
end
else
begin
dq_oe_ip_d1 <= dq_oe_ip;
dq_oe_ip_reg <= dq_oe_ip_redge ? 1'b1 : ce_n_ip ? 1'b0 : dq_oe_ip_reg;
dqs_ip_sel_d1 <= dqs_ip_sel;
//dqs_ip_sel_d2 <= dqs_ip_sel_d1;
end
end


endmodule


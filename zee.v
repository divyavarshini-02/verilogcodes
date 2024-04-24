module zee(a,clk,rst,z,zbar);
inout [9:0]a;
output reg [2:0]z;
output reg [2:0]zbar;
input clk,rst;
wire [4:0]w;
wire [7:5]r;
wire [7:5]wbar;
wire [2:0]o;
assign a[9]=r[5];
assign a[8]=r[7];
assign a[7]=r[6];
assign a[6]=wbar[7];
assign a[5]=wbar[5];
assign a[4]=r[7];
assign a[3]=r[5];
assign a[2]=r[6];
assign a[1]=wbar[5];
assign a[0]=wbar[6];
assign w[0]=(a[9]&&a[8]);
assign w[1]=(a[7]&&a[6]);
assign w[2]=(a[5]&&a[4]);
assign w[3]=(a[3]&&a[2]);
assign w[4]=(a[1]&&a[0]);
assign o[2]=(w[0]||w[1]);
assign o[1]=(w[1]||w[2]);
assign o[0]=(w[3]||w[4]);
always@(posedge clk)
begin
    if(rst)
        begin
            z[2]<=1'b0;
            zbar[2]<=0;
            z[1]<=0;
            zbar[1]<=0;
            z[0]<=0;
            zbar[0]<=0;
        end
    else
        begin
            z[2]<=o[2];
            zbar[2]<=~o[2];
            z[1]<=o[1];
            zbar[1]<=~o[1];
            z[0]<=o[0];
            zbar[0]<=~o[0];
        end
end
always@(*)
begin
    z[2]<=r[5];
    z[1]<=r[6];
    z[0]<=r[7];
end
endmodule




//reg [7:0]wa;
//assign wa=w;
//reg [7:5]wbara;
//wire [7:5]wbar;
//ssassign wbara=wbar;
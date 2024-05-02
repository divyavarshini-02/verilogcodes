module vga_tb();
reg                  clk,i_rst;
wire                  i_clk_27;
wire                 o_hsync,o_vsync,o_vga_blank,o_vga_sync;
wire    [9:0]        h_count ,v_count;
wire    [9:0]        o_green,o_blue,o_red;
reg     [9:0]        display,displayb,displayg;
reg     [24:0]       value=25'd0;
reg                  clk_100;
integer fd;

reg[9:0]data[307199:0];

initial 
    fd=$fopen("multiclr.dat","r");

initial begin
    
    $readmemb("multiclr.dat",data);
end



always #10 clk =~clk;
always #5 clk_100 =~clk_100;
initial begin
    clk_100=1'b0;
    clk = 1'b0;
    i_rst = 1'b1;
    #40 i_rst =1'b0;
        repeat(2457600)// 640*480=307200 *8 
        begin
        senddata(v_count,h_count,display,displayb,displayg);
        end
end



 task senddata;
   input [9:0] verti,hori;
   output [9:0] dr,db,dg;
   parameter           TOTAL_HCOUNT    =  800  ;
parameter            HSYNC_VALUE    =  96  ;
parameter           VSYNC_VALUE     =   2 ;
parameter           H_FRONT_PORCH     =   16 ;
parameter           H_BACK_PORCH       =   48  ;

parameter           V_BACK_PORCH    =  33  ;
parameter           V_FRONT_PORCH   =10 ;
parameter           TOTAL_VCOUNT    = 525  ;
  
        begin
          
            @(posedge i_clk_27)
                if((hori <=(TOTAL_HCOUNT-H_FRONT_PORCH)-1)&&(verti <= (TOTAL_VCOUNT-V_FRONT_PORCH)-1))
                begin
                    if((hori >= (HSYNC_VALUE +H_BACK_PORCH)-2 )&&(verti >=(VSYNC_VALUE+V_BACK_PORCH)-1))
                    begin
                        dr <= $random;
                        db <= $random;
                        dg <= $random;
                        value = value +25'd1;
                    end
                    else
                    begin
                        dr <= 10'd0;
                        db <= 10'd0;
                        dg <= 10'd0;
                    end
                end
                else
                begin
                        db <= 10'd0;
                        dg <= 10'd0;
                        dr <= 10'd0;
                end    
       // end
        end
 endtask






     vga vga_test(
            .clk                    (clk),
            .i_clk_27               (i_clk_27),
            .i_rst                   (i_rst),
            .o_hsync                 (o_hsync),
            .displayb                (displayb),
            .displayg                (displayg),
            .display                 (display),
            .o_vsync                 (o_vsync),
            .o_red                  (o_red),
            .h_count                  (h_count),
            .v_count                 (v_count),
            .o_green                  (o_green),
            .o_blue                    (o_blue),
            .o_vga_blank               (o_vga_blank),
            .o_vga_sync                 (o_vga_sync)
);
endmodule

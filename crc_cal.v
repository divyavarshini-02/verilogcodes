/*module crc_gen(clk);
input clk;
reg [31:0] crc32_val = 32'hffff_ffff; 
reg [7:0]  data = 8'b0000_0001;
reg i=1'b0;
reg [3:0] j=4'b0000;
parameter CRC32POL = 32'hEDB88320; 

always @(posedge clk)
begin
         if(j < 8) 
        begin
            if ((crc32_val[0]) != (data[0])) 
            begin
                crc32_val = (crc32_val >> 1'b1) ^ CRC32POL;
                data =data >> 1'b1;
                 j<=j+1;
            end 
            else if((crc32_val[0]) == (data[0])) 
             begin
                crc32_val = crc32_val >> 1'b1;
                 data =data >> 1'b1;
                 j=j+1;
             end
        end 
        else if(j>=8)
          begin
            j=1'b0;
          end
end
endmodule*/
module CRC_32_gen(clk,init,valid,inp_data,CRC_32_op);
    
input clk,init,valid;
input[7:0]inp_data;
output[31:0]CRC_32_op;

wire[31:0]lookup_table[255:0];

assign lookup_table[0]     = 32'h00000000;	assign lookup_table[1]     = 32'h77073096;	assign lookup_table[2]     = 32'hEE0E612C;	assign lookup_table[3]     = 32'h990951BA;
assign lookup_table[4]     = 32'h076DC419;	assign lookup_table[5]     = 32'h706AF48F;	assign lookup_table[6]     = 32'hE963A535;	assign lookup_table[7]     = 32'h9E6495A3;
assign lookup_table[8]     = 32'h0EDB8832;	assign lookup_table[9]     = 32'h79DCB8A4;	assign lookup_table[10]    = 32'hE0D5E91E;	assign lookup_table[11]    = 32'h97D2D988;	
assign lookup_table[12]    = 32'h09B64C2B;	assign lookup_table[13]    = 32'h7EB17CBD;	assign lookup_table[14]    = 32'hE7B82D07;	assign lookup_table[15]    = 32'h90BF1D91;
assign lookup_table[16]    = 32'h1DB71064;	assign lookup_table[17]    = 32'h6AB020F2;	assign lookup_table[18]    = 32'hF3B97148;	assign lookup_table[19]    = 32'h84BE41DE; 
assign lookup_table[20]    = 32'h1ADAD47D;	assign lookup_table[21]    = 32'h6DDDE4EB;	assign lookup_table[22]    = 32'hF4D4B551;	assign lookup_table[23]    = 32'h83D385C7;
assign lookup_table[24]    = 32'h136C9856;	assign lookup_table[25]    = 32'h646BA8C0;	assign lookup_table[26]    = 32'hFD62F97A;	assign lookup_table[27]    = 32'h8A65C9EC;
assign lookup_table[28]    = 32'h14015C4F;	assign lookup_table[29]    = 32'h63066CD9;	assign lookup_table[30]    = 32'hFA0F3D63;	assign lookup_table[31]    = 32'h8D080DF5;
assign lookup_table[32]    = 32'h3B6E20C8;	assign lookup_table[33]    = 32'h4C69105E;	assign lookup_table[34]    = 32'hD56041E4;	assign lookup_table[35]    = 32'hA2677172;
assign lookup_table[36]    = 32'h3C03E4D1;	assign lookup_table[37]    = 32'h4B04D447;	assign lookup_table[38]    = 32'hD20D85FD; 	assign lookup_table[39]    = 32'hA50AB56B;
assign lookup_table[40]    = 32'h35B5A8FA;	assign lookup_table[41]    = 32'h42B2986C;	assign lookup_table[42]    = 32'hDBBBC9D6;	assign lookup_table[43]    = 32'hACBCF940;
assign lookup_table[44]    = 32'h32D86CE3;	assign lookup_table[45]    = 32'h45DF5C75;	assign lookup_table[46]    = 32'hDCD60DCF;	assign lookup_table[47]    = 32'hABD13D59;
assign lookup_table[48]    = 32'h26D930AC;	assign lookup_table[49]    = 32'h51DE003A;	assign lookup_table[50]    = 32'hC8D75180;	assign lookup_table[51]    = 32'hBFD06116;
assign lookup_table[52]    = 32'h21B4F4B5;	assign lookup_table[53]    = 32'h56B3C423;	assign lookup_table[54]    = 32'hCFBA9599;	assign lookup_table[55]    = 32'hB8BDA50F;
assign lookup_table[56]    = 32'h2802B89E;	assign lookup_table[57]    = 32'h5F058808; assign lookup_table[58]    = 32'hC60CD9B2;	assign lookup_table[59]    = 32'hB10BE924;
assign lookup_table[60]    = 32'h2F6F7C87;	assign lookup_table[61]    = 32'h58684C11;	assign lookup_table[62]    = 32'hC1611DAB;	assign lookup_table[63]    = 32'hB6662D3D;
assign lookup_table[64]    = 32'h76DC4190;	assign lookup_table[65]    = 32'h01DB7106;	assign lookup_table[66]    = 32'h98D220BC;	assign lookup_table[67]    = 32'hEFD5102A;
assign lookup_table[68]    = 32'h71B18589;	assign lookup_table[69]    = 32'h06B6B51F;	assign lookup_table[70]    = 32'h9FBFE4A5;	assign lookup_table[71]    = 32'hE8B8D433;
assign lookup_table[72]    = 32'h7807C9A2;	assign lookup_table[73]    = 32'h0F00F934;	assign lookup_table[74]    = 32'h9609A88E;	assign lookup_table[75]    = 32'hE10E9818; 
assign lookup_table[76]    = 32'h7F6A0DBB;	assign lookup_table[77]    = 32'h086D3D2D;	assign lookup_table[78]    = 32'h91646C97;	assign lookup_table[79]    = 32'hE6635C01;
assign lookup_table[80]    = 32'h6B6B51F4;	assign lookup_table[81]    = 32'h1C6C6162;	assign lookup_table[82]    = 32'h856530D8;	assign lookup_table[83]    = 32'hF262004E;
assign lookup_table[84]    = 32'h6C0695ED;	assign lookup_table[85]    = 32'h1B01A57B;	assign lookup_table[86]    = 32'h8208F4C1;	assign lookup_table[87]    = 32'hF50FC457;
assign lookup_table[88]    = 32'h65B0D9C6;	assign lookup_table[89]    = 32'h12B7E950;	assign lookup_table[90]    = 32'h8BBEB8EA;	assign lookup_table[91]    = 32'hFCB9887C;
assign lookup_table[92]    = 32'h62DD1DDF;	assign lookup_table[93]    = 32'h15DA2D49;	assign lookup_table[94]    = 32'h8CD37CF3;	assign lookup_table[95]    = 32'hFBD44C65;
assign lookup_table[96]    = 32'h4DB26158;	assign lookup_table[97]    = 32'h3AB551CE;	assign lookup_table[98]    = 32'hA3BC0074;	assign lookup_table[99]    = 32'hD4BB30E2;
assign lookup_table[100]   = 32'h4ADFA541;	assign lookup_table[101]   = 32'h3DD895D7;	assign lookup_table[102]   = 32'hA4D1C46D;	assign lookup_table[103]   = 32'hD3D6F4FB;
assign lookup_table[104]   = 32'h4369E96A;	assign lookup_table[105]   = 32'h346ED9FC;	assign lookup_table[106]   = 32'hAD678846;	assign lookup_table[107]   = 32'hDA60B8D0;
assign lookup_table[108]   = 32'h44042D73;	assign lookup_table[109]   = 32'h33031DE5;	assign lookup_table[110]   = 32'hAA0A4C5F;	assign lookup_table[111]   = 32'hDD0D7CC9;
assign lookup_table[112]   = 32'h5005713C;	assign lookup_table[113]   = 32'h270241AA;	assign lookup_table[114]   = 32'hBE0B1010;	assign lookup_table[115]   = 32'hC90C2086;
assign lookup_table[116]   = 32'h5768B525;	assign lookup_table[117]   = 32'h206F85B3;	assign lookup_table[118]   = 32'hB966D409;	assign lookup_table[119]   = 32'hCE61E49F;
assign lookup_table[120]   = 32'h5EDEF90E;	assign lookup_table[121]   = 32'h29D9C998;	assign lookup_table[122]   = 32'hB0D09822;	assign lookup_table[123]   = 32'hC7D7A8B4;
assign lookup_table[124]   = 32'h59B33D17;	assign lookup_table[125]   = 32'h2EB40D81;	assign lookup_table[126]   = 32'hB7BD5C3B;	assign lookup_table[127]   = 32'hC0BA6CAD;
assign lookup_table[128]   = 32'hEDB88320;	assign lookup_table[129]   = 32'h9ABFB3B6;	assign lookup_table[130]   = 32'h03B6E20C;	assign lookup_table[131]   = 32'h74B1D29A;
assign lookup_table[132]   = 32'hEAD54739;	assign lookup_table[133]   = 32'h9DD277AF;	assign lookup_table[134]   = 32'h04DB2615;	assign lookup_table[135]   = 32'h73DC1683;
assign lookup_table[136]   = 32'hE3630B12;	assign lookup_table[137]   = 32'h94643B84;	assign lookup_table[138]   = 32'h0D6D6A3E;	assign lookup_table[139]   = 32'h7A6A5AA8;
assign lookup_table[140]   = 32'hE40ECF0B;	assign lookup_table[141]   = 32'h9309FF9D;	assign lookup_table[142]   = 32'h0A00AE27;	assign lookup_table[143]   = 32'h7D079EB1;
assign lookup_table[144]   = 32'hF00F9344;	assign lookup_table[145]   = 32'h8708A3D2;	assign lookup_table[146]   = 32'h1E01F268;	assign lookup_table[147]   = 32'h6906C2FE;
assign lookup_table[148]   = 32'hF762575D;	assign lookup_table[149]   = 32'h806567CB;	assign lookup_table[150]   = 32'h196C3671;	assign lookup_table[151]   = 32'h6E6B06E7;
assign lookup_table[152]   = 32'hFED41B76;	assign lookup_table[153]   = 32'h89D32BE0;	assign lookup_table[154]   = 32'h10DA7A5A;	assign lookup_table[155]   = 32'h67DD4ACC;
assign lookup_table[156]   = 32'hF9B9DF6F;	assign lookup_table[157]   = 32'h8EBEEFF9;	assign lookup_table[158]   = 32'h17B7BE43;	assign lookup_table[159]   = 32'h60B08ED5;
assign lookup_table[160]   = 32'hD6D6A3E8;	assign lookup_table[161]   = 32'hA1D1937E;	assign lookup_table[162]   = 32'h38D8C2C4;	assign lookup_table[163]   = 32'h4FDFF252;
assign lookup_table[164]   = 32'hD1BB67F1;	assign lookup_table[165]   = 32'hA6BC5767;	assign lookup_table[166]   = 32'h3FB506DD;	assign lookup_table[167]   = 32'h48B2364B;
assign lookup_table[168]   = 32'hD80D2BDA;	assign lookup_table[169]   = 32'hAF0A1B4C;	assign lookup_table[170]   = 32'h36034AF6;	assign lookup_table[171]   = 32'h41047A60;
assign lookup_table[172]   = 32'hDF60EFC3;	assign lookup_table[173]   = 32'hA867DF55;	assign lookup_table[174]   = 32'h316E8EEF;	assign lookup_table[175]   = 32'h4669BE79;
assign lookup_table[176]   = 32'hCB61B38C;	assign lookup_table[177]   = 32'hBC66831A;	assign lookup_table[178]   = 32'h256FD2A0;	assign lookup_table[179]   = 32'h5268E236;
assign lookup_table[180]   = 32'hCC0C7795;	assign lookup_table[181]   = 32'hBB0B4703;	assign lookup_table[182]   = 32'h220216B9;	assign lookup_table[183]   = 32'h5505262F;
assign lookup_table[184]   = 32'hC5BA3BBE;	assign lookup_table[185]   = 32'hB2BD0B28;	assign lookup_table[186]   = 32'h2BB45A92;	assign lookup_table[187]   = 32'h5CB36A04;
assign lookup_table[188]   = 32'hC2D7FFA7;	assign lookup_table[189]   = 32'hB5D0CF31;	assign lookup_table[190]   = 32'h2CD99E8B;	assign lookup_table[191]   = 32'h5BDEAE1D;
assign lookup_table[192]   = 32'h9B64C2B0;	assign lookup_table[193]   = 32'hEC63F226;	assign lookup_table[194]   = 32'h756AA39C;	assign lookup_table[195]   = 32'h026D930A;
assign lookup_table[196]   = 32'h9C0906A9;	assign lookup_table[197]   = 32'hEB0E363F;	assign lookup_table[198]   = 32'h72076785;	assign lookup_table[199]   = 32'h05005713;
assign lookup_table[200]   = 32'h95BF4A82;	assign lookup_table[201]   = 32'hE2B87A14;	assign lookup_table[202]   = 32'h7BB12BAE;	assign lookup_table[203]   = 32'h0CB61B38;
assign lookup_table[204]   = 32'h92D28E9B;	assign lookup_table[205]   = 32'hE5D5BE0D;	assign lookup_table[206]   = 32'h7CDCEFB7;	assign lookup_table[207]   = 32'h0BDBDF21;
assign lookup_table[208]   = 32'h86D3D2D4;	assign lookup_table[209]   = 32'hF1D4E242;	assign lookup_table[210]   = 32'h68DDB3F8;	assign lookup_table[211]   = 32'h1FDA836E;
assign lookup_table[212]   = 32'h81BE16CD;	assign lookup_table[213]   = 32'hF6B9265B;	assign lookup_table[214]   = 32'h6FB077E1;	assign lookup_table[215]   = 32'h18B74777;
assign lookup_table[216]   = 32'h88085AE6;	assign lookup_table[217]   = 32'hFF0F6A70;	assign lookup_table[218]   = 32'h66063BCA;	assign lookup_table[219]   = 32'h11010B5C;
assign lookup_table[220]   = 32'h8F659EFF;	assign lookup_table[221]   = 32'hF862AE69;	assign lookup_table[222]   = 32'h616BFFD3;	assign lookup_table[223]   = 32'h166CCF45;
assign lookup_table[224]   = 32'hA00AE278;	assign lookup_table[225]   = 32'hD70DD2EE;	assign lookup_table[226]   = 32'h4E048354;	assign lookup_table[227]   = 32'h3903B3C2;
assign lookup_table[228]   = 32'hA7672661;	assign lookup_table[229]   = 32'hD06016F7;	assign lookup_table[230]   = 32'h4969474D;	assign lookup_table[231]   = 32'h3E6E77DB;
assign lookup_table[232]   = 32'hAED16A4A;	assign lookup_table[233]   = 32'hD9D65ADC;	assign lookup_table[234]   = 32'h40DF0B66;	assign lookup_table[235]   = 32'h37D83BF0;
assign lookup_table[236]   = 32'hA9BCAE53;	assign lookup_table[237]   = 32'hDEBB9EC5;	assign lookup_table[238]   = 32'h47B2CF7F;	assign lookup_table[239]   = 32'h30B5FFE9;
assign lookup_table[240]   = 32'hBDBDF21C;	assign lookup_table[241]   = 32'hCABAC28A;	assign lookup_table[242]   = 32'h53B39330;	assign lookup_table[243]   = 32'h24B4A3A6;
assign lookup_table[244]   = 32'hBAD03605;	assign lookup_table[245]   = 32'hCDD70693;	assign lookup_table[246]   = 32'h54DE5729;	assign lookup_table[247]   = 32'h23D967BF;
assign lookup_table[248]   = 32'hB3667A2E;	assign lookup_table[249]   = 32'hC4614AB8;	assign lookup_table[250]   = 32'h5D681B02;	assign lookup_table[251]   = 32'h2A6F2B94;
assign lookup_table[252]   = 32'hB40BBE37;	assign lookup_table[253]   = 32'hC30C8EA1;	assign lookup_table[254]   = 32'h5A05DF1B;	assign lookup_table[255]   = 32'h2D02EF8D;
	
reg [31:0]crc32,crc32_xred;
always @(negedge clk)
begin
   if(init)
     crc32       <= 32'hffffffff;   
   else if(valid)
   begin
     crc32       <= lookup_table[inp_data[7:0]^crc32[7:0]] ^ crc32>>8; 
     crc32_xred  <= (lookup_table[inp_data[7:0]^crc32[7:0]] ^ crc32>>8)^32'hffffffff;
   end         
   else
   begin
     crc32       <= crc32;
     crc32_xred  <= crc32_xred;
   end     
end    
 
assign  CRC_32_op =  crc32_xred;  
endmodule

   

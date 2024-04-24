module parking_lot_2(input a,b,clk,reset,
                     input [1:0]slot_out_sel,//slot output selection for exiting

                   output reg entry,exit);

reg [2:0]state;//state for car entry and exit

reg [2:0]slot;//slot

reg slot_1,slot_2,slot_3,slot_4;//number of parking slot=4

reg [1:0] slot_num;//slot_num for occupying the car

reg [2:0]car_entered,car_in_slot;//number of car entered and car parked in slot

always @(posedge clk or negedge reset)
begin
  if(! reset)
    begin
      entry<=1'b0;//initializing all to zero
      exit<=1'b0;
      state<=3'b000;
      slot<=3'b000;
      car_entered<=3'b000;
      car_in_slot<=3'b000;
      slot_1<=1'b0;
      slot_2<=1'b0;
      slot_3<=1'b0;
      slot_4<=1'b0;
      slot_num<=2'b00;
 
    end
  else 
    begin
      case(state)
        3'b000:
             if(a&~b)//car entering 
              state<=3'b001;
             else if(~a & b)//car exiting
               state<=3'b100;
             else if (~a & ~b)//no car
                state<=3'b000;

          3'b001:
               if(a & b)//car is in half through parking
                state<=3'b010;
              else if(~a & ~b)//car enter and then backing off
                 state<=3'b000;
              else if(a & ~b)//car not moving
                  state<=3'b001;
          3'b010:
                if(~a & b)//car is almost entering the parking slot
                 state<=3'b011;
               else if(a & ~b)//car backing off
                  state<=3'b001;
                else if (a & b)//car not moving
                  state<=3'b010;
           3'b011:
                 if(~a & ~b)//car entered the parking slot
                 begin
                   car_entered<=car_entered+1'b1;//if car entered increment by 1
                   slot<=slot + 1'b1;//incrementing the slot
                   entry<=1'b1;//for car entry indication
                   state<=3'b000;//returing back to state 000 for checking whether other car is coming or not

                      if(slot_num==2'b00)//checking slot_num 00 means vacant slot_1 is parked
                      begin
                        slot_num<=slot_num+1'b1;

                      slot_1<=1'b1;
                    end
                  else if(slot_num==2'b01)//checking slot_num 01 means vacant slot_2 is parked
                    begin
                      slot_num<=slot_num+1'b1;

                  slot_2<=1'b1;
                end
                   else if(slot_num==2'b10)//checking slot_num 10 means vacant slot_3 is parked
                     begin
                       slot_num<=slot_num+1'b1;
                     slot_3<=1'b1;
                   end
                   else// checking slot
                     begin
                     slot_4<=1'b1;

                   end




              end

                  else if (a & b)//car is backing off
                    state<=3'b010;
                 else if( ~a & b)//not moving
                     state<=3'b011;
            3'b100:
                 if( a & b)//car half through leaving
                   state<=3'b101;
                 else if(~a & ~b)//car backing off and going back to slot
                    state<=3'b000;
                else if(~ a & b)//not moving
                     state<=3'b100;
            3'b101:
                 if( a & ~b)//car is almost leaving the parking slot
                    state<=3'b110;
              else if(~ a & b)//car is backing off
                    state<=3'b100;
              else if( a & b)//car is not moving
                    state<=3'b101;
            3'b110:
                  if(~ a & ~b)//car left
                   begin

                     car_in_slot<=car_entered-1'b1;
                     slot<=slot-1'b1;
                     exit<=1'b1;

                      if(slot_out_sel==2'b00)
                        slot_1<=1'b0;
                      else if(slot_out_sel==2'b01)
                        slot_2<=1'b0;
                      else if(slot_out_sel==2'b10)
                        slot_3<=1'b0;
                      else
                        slot_4<=1'b0;



                   end
                 else if( a& b)//going back to parking
                   state<=3'b101;
                 else if( a & ~b)//not moving
                    state<=3'b110;
                  endcase
                end
              end
              endmodule
                    
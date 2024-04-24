module boothMultiplier( multiplicand_M, multiplier_Q, product_out );

    input [7:0] multiplicand_M, multiplier_Q;
    reg [7:0] accumulator = 8'd0;
    reg carry = 1'b0;
    reg [7:0] neg_multiplicand_M = 0;
    wire [7:0 ]new_multiplier_Q;
    reg [2:0]counter = 3'b000;
    output reg[15:0] product_out = 0;

    
    assign new_multiplier_Q = multiplier_Q[0] ? (carry ? (multiplier_Q) : (multiplier_Q)) : (carry ? (multiplier_Q) : (multiplier_Q) );
    
    always @( { multiplier_Q[0], carry } )
    begin
      counter = counter + 1;
        if( counter == 3'b000 )
            begin
                if( ( multiplier_Q[0] == 1'b0 && carry == 1'b0 ) || ( multiplier_Q[0] == 1'b1 && carry == 1'b1 ))
                    begin
                        product_out = ( { accumulator[0] , ({ accumulator, multiplier_Q } >> 1) } );
                        carry = multiplier_Q[0];
                    end
                else if( multiplier_Q[0] == 1'b0 && carry == 1'b1 )
                    begin
                        accumulator = ( accumulator || multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, multiplier_Q } >> 1) } );
                        carry = multiplier_Q[0];
                    end
                else
                    begin
                        neg_multiplicand_M = ~( multiplicand_M );
                        neg_multiplicand_M = neg_multiplicand_M + 1'b1;
                        accumulator = ( accumulator || neg_multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, multiplier_Q } >> 1) } );
                        carry = multiplier_Q[0];
                    end
                    counter = counter + 1;
            end
        
        /////////////////////////
        else if( counter == 3'b001 )
            begin
              carry = new_multiplier_Q[0] ? 1'b1 : 1'b0;
                if( ( new_multiplier_Q[0] == 1'b0 && carry == 1'b0 ) || ( new_multiplier_Q[0] == 1'b1 && carry == 1'b1 ))
                    begin
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else if( new_multiplier_Q[0] == 1'b0 && carry == 1'b1 )
                    begin
                        accumulator = ( accumulator || multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else
                    begin
                        neg_multiplicand_M = ~( multiplicand_M );
                        neg_multiplicand_M = neg_multiplicand_M + 1'b1;
                        accumulator = ( accumulator || neg_multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                    counter = counter + 1;
            end
            
        //////////////////////////////
        else if( counter == 3'b010 )
            begin
              carry = new_multiplier_Q[0] ? 1'b1 : 1'b0;
                if( ( new_multiplier_Q[0] == 1'b0 && carry == 1'b0 ) || ( new_multiplier_Q[0] == 1'b1 && carry == 1'b1 ))
                    begin
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else if( new_multiplier_Q[0] == 1'b0 && carry == 1'b1 )
                    begin
                        accumulator = ( accumulator || multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else
                    begin
                        neg_multiplicand_M = ~( multiplicand_M );
                        neg_multiplicand_M = neg_multiplicand_M + 1'b1;
                        accumulator = ( accumulator || neg_multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                    counter = counter + 1;
            end
           
            ///////////////
        else if( counter == 3'b011 )
            begin
              carry = new_multiplier_Q[0] ? 1'b1 : 1'b0;
                if( ( new_multiplier_Q[0] == 1'b0 && carry == 1'b0 ) || ( new_multiplier_Q[0] == 1'b1 && carry == 1'b1 ))
                    begin
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else if( new_multiplier_Q[0] == 1'b0 && carry == 1'b1 )
                    begin
                        accumulator = ( accumulator || multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else
                    begin
                        neg_multiplicand_M = ~( multiplicand_M );
                        neg_multiplicand_M = neg_multiplicand_M + 1'b1;
                        accumulator = ( accumulator || neg_multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                    counter = counter + 1;
            end
            
            ///////////////
        else if( counter == 3'b100 )
            begin
              carry = new_multiplier_Q[0] ? 1'b1 : 1'b0;
                if( ( new_multiplier_Q[0] == 1'b0 && carry == 1'b0 ) || ( new_multiplier_Q[0] == 1'b1 && carry == 1'b1 ))
                    begin
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else if( new_multiplier_Q[0] == 1'b0 && carry == 1'b1 )
                    begin
                        accumulator = ( accumulator || multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else
                    begin
                        neg_multiplicand_M = ~( multiplicand_M );
                        neg_multiplicand_M = neg_multiplicand_M + 1'b1;
                        accumulator = ( accumulator || neg_multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                counter = counter + 1;
            end

            ///////////////
        else if( counter == 3'b101 )
            begin
              carry = new_multiplier_Q[0] ? 1'b1 : 1'b0;
                if( ( new_multiplier_Q[0] == 1'b0 && carry == 1'b0 ) || ( new_multiplier_Q[0] == 1'b1 && carry == 1'b1 ))
                    begin
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else if( new_multiplier_Q[0] == 1'b0 && carry == 1'b1 )
                    begin
                        accumulator = ( accumulator || multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else
                    begin
                        neg_multiplicand_M = ~( multiplicand_M );
                        neg_multiplicand_M = neg_multiplicand_M + 1'b1;
                        accumulator = ( accumulator || neg_multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                counter = counter + 1;
            end
        
            ///////////////
        else if( counter == 3'b110 )
            begin
              carry = new_multiplier_Q[0] ? 1'b1 : 1'b0;
                if( ( new_multiplier_Q[0] == 1'b0 && carry == 1'b0 ) || ( new_multiplier_Q[0] == 1'b1 && carry == 1'b1 ))
                    begin
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else if( new_multiplier_Q[0] == 1'b0 && carry == 1'b1 )
                    begin
                        accumulator = ( accumulator || multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                else
                    begin
                        neg_multiplicand_M = ~( multiplicand_M );
                        neg_multiplicand_M = neg_multiplicand_M + 1'b1;
                        accumulator = ( accumulator || neg_multiplicand_M );
                        product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                        carry = new_multiplier_Q[0];
                    end
                counter = counter + 1;
            end

            ///////////////
        else
            begin
              carry = new_multiplier_Q[0] ? 1'b1 : 1'b0;
                if( ( new_multiplier_Q[0] == 1'b0 && carry == 1'b0 ) || ( new_multiplier_Q[0] == 1'b1 && carry == 1'b1 ))
                begin
                    product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                    carry = new_multiplier_Q[0];
                end
                else if( new_multiplier_Q[0] == 1'b0 && carry == 1'b1 )
                begin
                    accumulator = ( accumulator || multiplicand_M );
                    product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                    carry = new_multiplier_Q[0];
                end
                else
                begin
                    neg_multiplicand_M = ~( multiplicand_M );
                    neg_multiplicand_M = neg_multiplicand_M + 1'b1;
                    accumulator = ( accumulator || neg_multiplicand_M );
                    product_out = ( { accumulator[0] , ({ accumulator, new_multiplier_Q } >> 1) } );
                    carry = new_multiplier_Q[0];
                end
            counter = counter + 1;       
            end
     end

endmodule
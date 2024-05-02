module baud_generator
    #(
        parameter divisor = 5208
    )

    // ports declaration
    (
        input clk, reset,

        output reg baud_clk
    );

    integer count;

    always @( posedge clk or negedge reset )
        begin
            
            if( reset == 1'd0 )
                begin

                    count <= 32'd0;
                    baud_clk <= 1'd0;

                end

            else
                begin

                    if( count == 32'd0 )
                        begin

                            baud_clk <= ~baud_clk;
                            count <= divisor / 2;

                        end

                    else
                        count <= count - 32'd1;

                end

        end

endmodule
module uart_tx
    (
        input clk,
        input reset,
        // input [7:0] data_in,

        output reg tx_out
    );

    reg [3:0] count;
    reg [1:0] state;
    reg [7:0] tx_hold_reg;
    reg [7:0] tx_shift_reg;

    wire baud_clk;
    wire ready;

    assign ready = ( count == 4'd9 ) ? 1'd1 : 1'd0;

    always @( posedge baud_clk or negedge reset )
        begin

            if( reset == 1'd0 )
                begin

                    tx_out <= 1'd1;
                    count <= 4'd9;
                    state <= 2'd0;
                    tx_hold_reg <= 8'd0;
                    tx_shift_reg <= 8'd0;

                end

            else
                begin


                    tx_hold_reg = 8'd0;

                    case( state )

                        2'd0:
                            begin

                                if( ready && tx_hold_reg >= 8'd0 && tx_hold_reg <= 8'd255 )
                                    begin

                                        tx_shift_reg <= tx_hold_reg;
                                        state <= 2'd1;

                                    end

                                else
                                    begin

                                        tx_out <= 1'd1;
                                        state <= 2'd0;

                                    end

                            end

                        2'd1:
                            begin

                                if( count == 4'd9 )
                                    begin

                                        tx_out <= 1'd0;    // start bit
                                        count <= count - 4'd1;
                                        state <= 2'd1;

                                    end
                                
                                
                                else if( count < 4'd9 && count > 4'd0)
                                    begin

                                        tx_out <= tx_shift_reg[0];
                                        tx_shift_reg <= tx_shift_reg >> 1;
                                        count <= count - 4'd1;
                                        state <= 2'd1;

                                    end
                                else
                                    begin

                                        tx_out <= 1'd1;    // stop bit
                                        count <= 4'd9;
                                        state <= 2'd0;

                                    end

                            end

                        default:
                            state <= 2'd0;

                    endcase

                end

        end

    baud_generator baud
        (
            .clk( clk ),
            .reset( reset ),
            .baud_clk( baud_clk )
        );


endmodule


`include "defines.v"

//
// ?
// ?
module div(

    input wire clk,
    input wire rst,

    // from ex
    input wire[`RegBus] dividend_i,      // 
    input wire[`RegBus] divisor_i,       // 
    input wire start_i,                  // ?
    input wire[2:0] op_i,                // ?
    input wire[`RegAddrBus] reg_waddr_i, // 

    // to ex
    output reg[`DoubleRegBus] result_o,  // ?
    output reg ready_o,                  // 
    output wire busy_o,                  // 
    output reg[2:0] op_o,                // 
    output reg[`RegAddrBus] reg_waddr_o  // 

    );

    // ?
    localparam STATE_IDLE = 0;
    localparam STATE_START = 1;
    localparam STATE_INVERT = 2;
    localparam STATE_END = 3;

    reg[`RegBus] dividend_temp;
    reg[`RegBus] divisor_temp;
    reg[1:0] state;
    reg[6:0] count;
    reg[`RegBus] div_result;
    reg[`RegBus] div_remain;
    reg[`RegBus] minuend;
    reg[`RegBus] divisor_zero_result;
    reg invert_result;


    assign busy_o = (state != STATE_IDLE)? `True : `False;


    // 
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            state <= STATE_IDLE;
            ready_o <= `DivResultNotReady;
            result_o <= {`ZeroWord, `ZeroWord};
            div_result <= `ZeroWord;
            div_remain <= `ZeroWord;
            divisor_zero_result <= ~32'b00000001 + 1'b1;
            op_o <= 3'h0;
            reg_waddr_o <= `ZeroWord;
            dividend_temp <= `ZeroWord;
            divisor_temp <= `ZeroWord;
            invert_result <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (start_i == `DivStart) begin
                        op_o <= op_i;
                        reg_waddr_o <= reg_waddr_i;

                        // 
                        if (divisor_i == `ZeroWord) begin
                            ready_o <= `DivResultReady;
                            result_o <= {dividend_i, divisor_zero_result};
                        // 
                        end else begin
                            count <= 7'd31;
                            state <= STATE_START;
                            div_result <= `ZeroWord;
                            div_remain <= `ZeroWord;

                            //
                            if ((op_i == `INST_DIV) || (op_i == `INST_REM)) begin
                                // 
                                if (dividend_i[31] == 1'b1) begin
                                    dividend_temp <= ~dividend_i + 1;
                                    minuend <= ((~dividend_i + 1) >> 7'd31) & 1'b1;
                                end else begin
                                    dividend_temp <= dividend_i;
                                    minuend <= (dividend_i >> 7'd31) & 1'b1;
                                end
                                // ?
                                if (divisor_i[31] == 1'b1) begin
                                    divisor_temp <= ~divisor_i + 1;
                                end else begin
                                    divisor_temp <= divisor_i;
                                end
                            end else begin
                                dividend_temp <= dividend_i;
                                minuend <= (dividend_i >> 7'd31) & 1'b1;
                                divisor_temp <= divisor_i;
                            end

                            // 
                            if (((op_i == `INST_DIV) && (dividend_i[31] ^ divisor_i[31] == 1'b1))
                                || ((op_i == `INST_REM) && (dividend_i[31] == 1'b1))) begin
                                invert_result <= 1'b1;
                            end else begin
                                invert_result <= 1'b0;
                            end
                        end
                    end else begin
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                    end
                end

                STATE_START: begin
                    if (start_i == `DivStart) begin
                        if (count >= 7'd1) begin
                            if (minuend >= divisor_temp) begin
                                div_result <= (div_result << 1'b1) | 1'b1;
                                minuend <= ((minuend - divisor_temp) << 1'b1) | ((dividend_temp >> (count - 1'b1)) & 1'b1);
                            end else begin
                                div_result <= (div_result << 1'b1) | 1'b0;
                                minuend <= (minuend << 1'b1) | ((dividend_temp >> (count - 1'b1)) & 1'b1);
                            end
                            count <= count - 1'b1;
                        end else begin
                            state <= STATE_INVERT;
                            if (minuend >= divisor_temp) begin
                                div_result <= (div_result << 1'b1) | 1'b1;
                                div_remain <= minuend - divisor_temp;
                            end else begin
                                div_result <= (div_result << 1'b1) | 1'b0;
                                div_remain <= minuend;
                            end
                        end
                    end else begin
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                        state <= STATE_IDLE;
                    end
                end

                STATE_INVERT: begin
                    if (start_i == `DivStart) begin
                        if (invert_result == 1'b1) begin
                            div_result <= ~div_result + 1'b1;
                            div_remain <= ~div_remain + 1'b1;
                        end
                        state <= STATE_END;
                    end else begin
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                        state <= STATE_IDLE;
                    end
                end

                STATE_END: begin
                    if (start_i == `DivStart) begin
                        ready_o <= `DivResultReady;
                        result_o <= {div_remain, div_result};
                        state <= STATE_IDLE;
                    end else begin
                        state <= STATE_IDLE;
                        result_o <= {`ZeroWord, `ZeroWord};
                        ready_o <= `DivResultNotReady;
                    end
                end

            endcase
        end
    end

endmodule

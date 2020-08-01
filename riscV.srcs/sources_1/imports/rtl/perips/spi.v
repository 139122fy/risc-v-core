 

// spi 
module spi(

    input wire clk,
    input wire rst,

    input wire[31:0] data_i,
    input wire[31:0] addr_i,
    input wire we_i,
    input wire req_i,

    output reg[31:0] data_o,
    output reg ack_o,

    output reg spi_mosi,             // 
    input wire spi_miso,             // 
    output wire spi_ss,              // 
    output reg spi_clk               // 

    );


    localparam SPI_CTRL   = 4'h0;    // 
    localparam SPI_DATA   = 4'h4;    // 
    localparam SPI_STATUS = 4'h8;    // 


    reg[31:0] spi_ctrl;
    // 
    // 
    // 
    reg[31:0] spi_data;
    // 
    //
    // 
    reg[31:0] spi_status;

    reg[8:0] clk_cnt;               // 
    reg en;                         // ?
    reg[4:0] spi_clk_edge_cnt;      // 
    reg spi_clk_edge_level;         // 
    reg[7:0] rdata;                 // 
    reg done;                       // 
    reg[3:0] bit_index;             // 
    wire[8:0] div_cnt;


    assign spi_ss = ~spi_ctrl[3];   // 

    assign div_cnt = spi_ctrl[15:8];// 


    // 
    // 
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            en <= 1'b0;
        end else begin
            if (spi_ctrl[0] == 1'b1) begin
                en <= 1'b1;
            end else if (done == 1'b1) begin
                en <= 1'b0;
            end else begin
                en <= en;
            end
        end
    end

    // ?
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            clk_cnt <= 9'h0;
        end else if (en == 1'b1) begin
            if (clk_cnt == div_cnt) begin
                clk_cnt <= 9'h0;
            end else begin
                clk_cnt <= clk_cnt + 1'b1;
            end
        end else begin
            clk_cnt <= 9'h0;
        end
    end

    // 
    // 
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            spi_clk_edge_cnt <= 5'h0;
            spi_clk_edge_level <= 1'b0;
        end else if (en == 1'b1) begin
            // ?
            if (clk_cnt == div_cnt) begin
                if (spi_clk_edge_cnt == 5'd17) begin
                    spi_clk_edge_cnt <= 5'h0;
                    spi_clk_edge_level <= 1'b0;
                end else begin
                    spi_clk_edge_cnt <= spi_clk_edge_cnt + 1'b1;
                    spi_clk_edge_level <= 1'b1;
                end
            end else begin
                spi_clk_edge_level <= 1'b0;
            end
        end else begin
            spi_clk_edge_cnt <= 5'h0;
            spi_clk_edge_level <= 1'b0;
        end
    end

    // 
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            spi_clk <= 1'b0;
            rdata <= 8'h0;
            spi_mosi <= 1'b0;
            bit_index <= 4'h0;
        end else begin
            if (en) begin
                if (spi_clk_edge_level == 1'b1) begin
                    case (spi_clk_edge_cnt)
                        // ?
                        1, 3, 5, 7, 9, 11, 13, 15: begin
                            spi_clk <= ~spi_clk;
                            if (spi_ctrl[2] == 1'b1) begin
                                spi_mosi <= spi_data[bit_index];   // 
                                bit_index <= bit_index - 1'b1;
                            end else begin
                                rdata <= {rdata[6:0], spi_miso};   // 
                            end
                        end
                        // 
                        2, 4, 6, 8, 10, 12, 14, 16: begin
                            spi_clk <= ~spi_clk;
                            if (spi_ctrl[2] == 1'b1) begin
                                rdata <= {rdata[6:0], spi_miso};   // 
                            end else begin
                                spi_mosi <= spi_data[bit_index];   // 
                                bit_index <= bit_index - 1'b1;
                            end
                        end
                        17: begin
                            spi_clk <= spi_ctrl[1];
                        end
                    endcase
                end
            end else begin
                // ?
                spi_clk <= spi_ctrl[1];
                if (spi_ctrl[2] == 1'b0) begin
                    spi_mosi <= spi_data[7];           // 
                    bit_index <= 4'h6;
                end else begin
                    bit_index <= 4'h7;
                end
            end
        end
    end

    // 
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            done <= 1'b0;
        end else begin
            if (en && spi_clk_edge_cnt == 5'd17) begin
                done <= 1'b1;
            end else begin
                done <= 1'b0;
            end
        end
    end

    // write reg
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            spi_ctrl <= 32'h0;
            spi_data <= 32'h0;
            spi_status <= 32'h0;
        end else begin
            spi_status[0] <= en;
            if (we_i == 1'b1) begin
                case (addr_i[3:0])
                    SPI_CTRL: begin
                        spi_ctrl <= data_i;
                    end
                    SPI_DATA: begin
                        spi_data <= data_i;
                    end
                    default: begin

                    end
                endcase
            end else begin
                spi_ctrl[0] <= 1'b0;
                //
                if (done == 1'b1) begin
                    spi_data <= {24'h0, rdata};
                end
            end
        end
    end

    // read reg
    always @ (*) begin
        if (rst == 1'b0) begin
            data_o = 32'h0;
        end else begin
            case (addr_i[3:0])
                SPI_CTRL: begin
                    data_o = spi_ctrl;
                end
                SPI_DATA: begin
                    data_o = spi_data;
                end
                SPI_STATUS: begin
                    data_o = spi_status;
                end
                default: begin
                    data_o = 32'h0;
                end
            endcase
        end
    end

endmodule

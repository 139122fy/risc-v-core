
`include "../core/defines.v"


module rom(

    input wire clk,
    input wire rst,

    input wire we_i,                   // write enable
    input wire[`MemAddrBus] addr_i,    // addr
    input wire[`MemBus] data_i,
    input wire req_i,

    output reg[`MemBus] data_o,        // read data
    output reg ack_o

    );

    reg[`MemBus] _rom[0:`RomNum - 1];


    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ack_o <= `RIB_ACK;
        end else begin
            if (we_i == `WriteEnable) begin
                _rom[addr_i[31:2]] <= data_i;
            end
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            data_o = `ZeroWord;
        end else begin
            data_o = _rom[addr_i[31:2]];
        end
    end

endmodule

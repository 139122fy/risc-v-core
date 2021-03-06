 

`define DM_RESP_VALID     1'b1
`define DM_RESP_INVALID   1'b0
`define DTM_REQ_VALID     1'b1
`define DTM_REQ_INVALID   1'b0

`define DTM_OP_NOP        2'b00
`define DTM_OP_READ       2'b01
`define DTM_OP_WRITE      2'b10


module jtag_dm(

    clk,
    rst_n,
    dtm_req_valid,
    dtm_req_data,

    dm_is_busy,
    dm_resp_data,

    dm_reg_we,
    dm_reg_addr,
    dm_reg_wdata,
    dm_reg_rdata,
    dm_mem_we,
    dm_mem_addr,
    dm_mem_wdata,
    dm_mem_rdata,
    dm_op_req,

    dm_halt_req,
    dm_reset_req

    );

    parameter DMI_ADDR_BITS = 6;
    parameter DMI_DATA_BITS = 32;
    parameter DMI_OP_BITS = 2;
    parameter DM_RESP_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;
    parameter DTM_REQ_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;
    parameter SHIFT_REG_BITS = DTM_REQ_BITS;

    // input and output
    input wire clk;
    input wire rst_n;
    input wire dtm_req_valid;
    input wire[DTM_REQ_BITS - 1:0] dtm_req_data;
    output reg dm_is_busy;
    output reg[DM_RESP_BITS - 1:0] dm_resp_data;
    output reg dm_reg_we;
    output reg[4:0] dm_reg_addr;
    output reg[31:0] dm_reg_wdata;
    input wire[31:0] dm_reg_rdata;
    output reg dm_mem_we;
    output reg[31:0] dm_mem_addr;
    output reg[31:0] dm_mem_wdata;
    input wire[31:0] dm_mem_rdata;
    output reg dm_op_req;
    output reg dm_halt_req;
    output reg dm_reset_req;

    localparam STATE_IDLE = 2'b0;
    localparam STATE_EX = 2'b1;

    reg[1:0] state;
    reg[DMI_OP_BITS - 1:0] op;
    reg[DMI_DATA_BITS - 1:0] data;
    reg[DMI_ADDR_BITS - 1:0] address;
    reg[DTM_REQ_BITS - 1:0] req_data;
    reg is_halted;
    reg is_reseted;
    reg is_read_reg;

    // DM regs
    reg[31:0] dcsr;
    reg[31:0] dmstatus;
    reg[31:0] dmcontrol;
    reg[31:0] hartinfo;
    reg[31:0] abstractcs;
    reg[31:0] data0;
    reg[31:0] sbcs;
    reg[31:0] sbaddress0;
    reg[31:0] sbdata0;
    reg[31:0] command;

    localparam DCSR = 16'h7b0;
    localparam DMSTATUS = 6'h11;
    localparam DMCONTROL = 6'h10;
    localparam HARTINFO = 6'h12;
    localparam ABSTRACTCS = 6'h16;
    localparam DATA0 = 6'h04;
    localparam SBCS = 6'h38;
    localparam SBADDRESS0 = 6'h39;
    localparam SBDATA0 = 6'h3C;
    localparam COMMAND = 6'h17;
    localparam DPC = 16'h7b1;

    localparam OP_SUCC = 2'b00;


    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            dm_mem_we <= 1'b0;
            dm_reg_we <= 1'b0;
            dm_resp_data <= {(DM_RESP_BITS){1'b0}};
            dm_is_busy <= 1'b0;
            dm_halt_req <= 1'b0;
            dm_reset_req <= 1'b0;
            dm_mem_addr <= 32'h0;
            dm_reg_addr <= 5'h0;
            is_halted <= 1'b0;
            is_reseted <= 1'b0;
            dm_op_req <= 1'b0;
            op <= 2'h0;
            data <= 32'h0;
            sbaddress0 <= 32'h0;
            dcsr <= 32'h0;
            hartinfo <= 32'h0;
            sbcs <= 32'h0;
            dmcontrol <= 32'h0;
            abstractcs <= 32'h0;
            data0 <= 32'h0;
            sbdata0 <= 32'h0;
            command <= 32'h0;
            dm_reg_wdata <= 32'h0;
            dm_mem_wdata <= 32'h0;
            address <= 6'h0;
            dmstatus <= 32'h0;
            is_read_reg <= 1'b0;
        end else begin
            if (state == STATE_IDLE) begin
                dm_mem_we <= 1'b0;
                dm_reg_we <= 1'b0;
                dm_reset_req <= 1'b0;
                if (dtm_req_valid == `DTM_REQ_VALID) begin
                    state <= STATE_EX;
                    op <= dtm_req_data[DMI_OP_BITS - 1:0];
                    data <= dtm_req_data[DMI_DATA_BITS + DMI_OP_BITS - 1:DMI_OP_BITS];
                    address <= dtm_req_data[DTM_REQ_BITS - 1:DMI_DATA_BITS + DMI_OP_BITS];
                    req_data <= dtm_req_data;
                    dm_is_busy <= 1'b1;
                    if ((dtm_req_data[DMI_OP_BITS - 1:0] == `DTM_OP_READ &&
                        dtm_req_data[DTM_REQ_BITS - 1:DMI_DATA_BITS + DMI_OP_BITS] == DMSTATUS) ||
                        (dtm_req_data[DMI_OP_BITS - 1:0] == `DTM_OP_NOP)) begin
                        dm_op_req <= 1'b0;
                    end else begin
                        dm_op_req <= 1'b1;
                    end
                end else begin
                    dm_op_req <= 1'b0;
                end
            end else begin
                case (op)
                    `DTM_OP_READ: begin
                        case (address)
                            DMSTATUS: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {address, dmstatus, OP_SUCC};
                            end

                            DMCONTROL: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {address, dmcontrol, OP_SUCC};
                            end

                            HARTINFO: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {address, hartinfo, OP_SUCC};
                            end

                            SBCS: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {address, sbcs, OP_SUCC};
                            end

                            ABSTRACTCS: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {address, abstractcs, OP_SUCC};
                            end

                            DATA0: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                if (is_read_reg == 1'b1) begin
                                    dm_resp_data <= {address, dm_reg_rdata, OP_SUCC};
                                end else begin
                                    dm_resp_data <= {address, data0, OP_SUCC};
                                end
                                is_read_reg <= 1'b0;
                            end

                            SBDATA0: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {address, dm_mem_rdata, OP_SUCC};
                                if (sbcs[16] == 1'b1) begin
                                    sbaddress0 <= sbaddress0 + 4;
                                end
                                if (sbcs[15] == 1'b1) begin
                                    dm_mem_addr <= sbaddress0 + 4;
                                end
                            end

                            default: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                            end
                        endcase
                    end

                    `DTM_OP_WRITE: begin
                        case (address)
                            DMCONTROL: begin
                                // reset DM module
                                if (data[0] == 1'b0) begin
                                    dcsr <= 32'hc0;
                                    dmstatus <= 32'h430c82;  // not halted, all running
                                    hartinfo <= 32'h0;
                                    sbcs <= 32'h20040404;
                                    abstractcs <= 32'h1000003;
                                    dmcontrol <= data;
                                    dm_halt_req <= 1'b0;
                                    dm_reset_req <= 1'b0;
                                    is_halted <= 1'b0;
                                    is_reseted <= 1'b0;
                                // DM is active
                                end else begin
                                    // we have only one hart
                                    dmcontrol <= (data & ~(32'h3fffc0)) | 32'h10000;
                                    // halt
                                    if (data[31] == 1'b1) begin
                                        dm_halt_req <= 1'b1;
                                        is_halted <= 1'b1;
                                        // clear ALLRUNNING ANYRUNNING and set ALLHALTED
                                        dmstatus <= {dmstatus[31:12], 4'h3, dmstatus[7:0]};
                                    // resume
                                    end else if (is_halted == 1'b1 && data[30] == 1'b1) begin
                                        dm_halt_req <= 1'b0;
                                        is_halted <= 1'b0;
                                        // set ALLRUNNING ANYRUNNING and clear ALLHALTED
                                        dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                    end
                                end
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                            end

                            COMMAND: begin
                                // access reg
                                if (data[31:24] == 8'h0) begin
                                    if (data[22:20] > 3'h2) begin
                                        abstractcs <= abstractcs | (1'b1 << 9);
                                    end else begin
                                        abstractcs <= abstractcs & (~(3'h7 << 8));
                                        // read or write
                                        if (data[18] == 1'b0) begin
                                            // read
                                            if (data[16] == 1'b0) begin
                                                if (data[15:0] == DCSR) begin
                                                    data0 <= dcsr;
                                                end else if (data[15:0] < 16'h1020) begin
                                                    dm_reg_addr <= data[15:0] - 16'h1000;
                                                    is_read_reg <= 1'b1;
                                                end
                                            // write
                                            end else begin
                                                // when write dpc, we reset cpu here
                                                if (data[15:0] == DPC) begin
                                                    dm_reset_req <= 1'b1;
                                                    dm_halt_req <= 1'b0;
                                                    is_halted <= 1'b0;
                                                    dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                                end else if (data[15:0] < 16'h1020) begin
                                                    dm_reg_we <= 1'b1;
                                                    dm_reg_addr <= data[15:0] - 16'h1000;
                                                    dm_reg_wdata <= data0;
                                                end
                                            end
                                        end
                                    end
                                end
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                            end

                            DATA0: begin
                                data0 <= data;
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                            end

                            SBCS: begin
                                sbcs <= data;
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                            end

                            SBADDRESS0: begin
                                sbaddress0 <= data;
                                if (sbcs[20] == 1'b1) begin
                                    dm_mem_addr <= data;
                                end
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                            end

                            SBDATA0: begin
                                sbdata0 <= data;
                                dm_mem_addr <= sbaddress0;
                                dm_mem_wdata <= data;
                                dm_mem_we <= 1'b1;
                                if (sbcs[16] == 1'b1) begin
                                    sbaddress0 <= sbaddress0 + 4;
                                end
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                            end

                            default: begin
                                dm_is_busy <= 1'b0;
                                state <= STATE_IDLE;
                                dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                            end
                        endcase
                    end

                    `DTM_OP_NOP: begin
                        dm_is_busy <= 1'b0;
                        state <= STATE_IDLE;
                        dm_resp_data <= {{address}, {(DMI_DATA_BITS){1'b0}}, OP_SUCC};
                    end
                endcase
            end
        end
    end

endmodule

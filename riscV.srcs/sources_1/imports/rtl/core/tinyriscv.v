

`include "defines.v"


module tinyriscv(

    input wire clk,
    input wire rst,

    output wire[`MemAddrBus] rib_ex_addr_o,    
    input wire[`MemBus] rib_ex_data_i,         
    output wire[`MemBus] rib_ex_data_o,  //       ?
    output wire rib_ex_req_o,                  
    output wire rib_ex_we_o,                  

    output wire[`MemAddrBus] rib_pc_addr_o,    
    input wire[`MemBus] rib_pc_data_i,  //       ?

    input wire[`RegAddrBus] jtag_reg_addr_i,   
    input wire[`RegBus] jtag_reg_data_i,       
    input wire jtag_reg_we_i,                  
    output wire[`RegBus] jtag_reg_data_o,     // ?

    input wire rib_hold_flag_i,                
    input wire jtag_halt_flag_i,               
    input wire jtag_reset_flag_i,              

    input wire[`INT_BUS] int_i                 

    );

    
	wire[`InstAddrBus] pc_pc_o;

   
	wire[`InstBus] if_inst_o;
    wire[`InstAddrBus] if_inst_addr_o;
    wire[`INT_BUS] if_int_flag_o;

    
    wire[`RegAddrBus] id_reg1_raddr_o;
    wire[`RegAddrBus] id_reg2_raddr_o;
    wire id_mem_req_o;
    wire[`InstBus] id_inst_o;
    wire[`InstAddrBus] id_inst_addr_o;
    wire[`RegBus] id_reg1_rdata_o;
    wire[`RegBus] id_reg2_rdata_o;
    wire id_reg_we_o;
    wire[`RegAddrBus] id_reg_waddr_o;
    wire[`MemAddrBus] id_csr_raddr_o;
    wire id_csr_we_o;
    wire[`RegBus] id_csr_rdata_o;
    wire[`MemAddrBus] id_csr_waddr_o;

    
    wire[`InstBus] ie_inst_o;
    wire[`InstAddrBus] ie_inst_addr_o;
    wire ie_reg_we_o;
    wire[`RegAddrBus] ie_reg_waddr_o;
    wire[`RegBus] ie_reg1_rdata_o;
    wire[`RegBus] ie_reg2_rdata_o;
    wire ie_csr_we_o;
    wire[`MemAddrBus] ie_csr_waddr_o;
    wire[`RegBus] ie_csr_rdata_o;

   
    wire[`MemBus] ex_mem_wdata_o;
    wire[`MemAddrBus] ex_mem_raddr_o;
    wire[`MemAddrBus] ex_mem_waddr_o;
    wire ex_mem_we_o;
    wire ex_mem_req_o;
    wire[`RegBus] ex_reg_wdata_o;
    wire ex_reg_we_o;
    wire[`RegAddrBus] ex_reg_waddr_o;
    wire ex_hold_flag_o;
    wire ex_jump_flag_o;
    wire[`InstAddrBus] ex_jump_addr_o;
    wire ex_div_start_o;
    wire[`RegBus] ex_div_dividend_o;
    wire[`RegBus] ex_div_divisor_o;
    wire[2:0] ex_div_op_o;
    wire[`RegAddrBus] ex_div_reg_waddr_o;
    wire[`RegBus] ex_csr_wdata_o;
    wire ex_csr_we_o;
    wire[`MemAddrBus] ex_csr_waddr_o;

   
    wire[`RegBus] regs_rdata1_o;
    wire[`RegBus] regs_rdata2_o;

    
    wire[`RegBus] csr_data_o;
    wire[`RegBus] csr_clint_data_o;
    wire csr_global_int_en_o;
    wire[`RegBus] csr_clint_csr_mtvec;
    wire[`RegBus] csr_clint_csr_mepc;
    wire[`RegBus] csr_clint_csr_mstatus;

    
    wire[`Hold_Flag_Bus] ctrl_hold_flag_o;
    wire ctrl_jump_flag_o;
    wire[`InstAddrBus] ctrl_jump_addr_o;

   
    wire[`DoubleRegBus] div_result_o;
	wire div_ready_o;
    wire div_busy_o;
    wire[2:0] div_op_o;
    wire[`RegAddrBus] div_reg_waddr_o;

    
    wire clint_we_o;
    wire[`MemAddrBus] clint_waddr_o;
    wire[`MemAddrBus] clint_raddr_o;
    wire[`RegBus] clint_data_o;
    wire[`InstAddrBus] clint_int_addr_o;
    wire clint_int_assert_o;
    wire clint_hold_flag_o;


    assign rib_ex_addr_o = (ex_mem_we_o == `WriteEnable)? ex_mem_waddr_o: ex_mem_raddr_o;
    assign rib_ex_data_o = ex_mem_wdata_o;
    assign rib_ex_req_o = ex_mem_req_o | id_mem_req_o;
    assign rib_ex_we_o = ex_mem_we_o;

    assign rib_pc_addr_o = pc_pc_o;


    
    pc_reg u_pc_reg(
        .clk(clk),
        .rst(rst),
        .jtag_reset_flag_i(jtag_reset_flag_i),
        .pc_o(pc_pc_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .jump_flag_i(ctrl_jump_flag_o),
        .jump_addr_i(ctrl_jump_addr_o)
    );

  
    ctrl u_ctrl(
        .rst(rst),
        .jump_flag_i(ex_jump_flag_o),
        .jump_addr_i(ex_jump_addr_o),
        .hold_flag_ex_i(ex_hold_flag_o),
        .hold_flag_rib_i(rib_hold_flag_i),
        .hold_flag_o(ctrl_hold_flag_o),
        .hold_flag_clint_i(clint_hold_flag_o),
        .jump_flag_o(ctrl_jump_flag_o),
        .jump_addr_o(ctrl_jump_addr_o),
        .jtag_halt_flag_i(jtag_halt_flag_i)
    );

    
    regs u_regs(
        .clk(clk),
        .rst(rst),
        .we_i(ex_reg_we_o),
        .waddr_i(ex_reg_waddr_o),
        .wdata_i(ex_reg_wdata_o),
        .raddr1_i(id_reg1_raddr_o),
        .rdata1_o(regs_rdata1_o),
        .raddr2_i(id_reg2_raddr_o),
        .rdata2_o(regs_rdata2_o),
        .jtag_we_i(jtag_reg_we_i),
        .jtag_addr_i(jtag_reg_addr_i),
        .jtag_data_i(jtag_reg_data_i),
        .jtag_data_o(jtag_reg_data_o)
    );

    
    csr_reg u_csr_reg(
        .clk(clk),
        .rst(rst),
        .we_i(ex_csr_we_o),
        .raddr_i(id_csr_raddr_o),
        .waddr_i(ex_csr_waddr_o),
        .data_i(ex_csr_wdata_o),
        .data_o(csr_data_o),
        .global_int_en_o(csr_global_int_en_o),
        .clint_we_i(clint_we_o),
        .clint_raddr_i(clint_raddr_o),
        .clint_waddr_i(clint_waddr_o),
        .clint_data_i(clint_data_o),
        .clint_data_o(csr_clint_data_o),
        .clint_csr_mtvec(csr_clint_csr_mtvec),
        .clint_csr_mepc(csr_clint_csr_mepc),
        .clint_csr_mstatus(csr_clint_csr_mstatus)
    );

    
    if_id u_if_id(
        .clk(clk),
        .rst(rst),
        .inst_i(rib_pc_data_i),
        .inst_addr_i(pc_pc_o),
        .int_flag_i(int_i),
        .int_flag_o(if_int_flag_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .inst_o(if_inst_o),
        .inst_addr_o(if_inst_addr_o)
    );

  
    id u_id(
        .rst(rst),
        .inst_i(if_inst_o),
        .inst_addr_i(if_inst_addr_o),
        .reg1_rdata_i(regs_rdata1_o),
        .reg2_rdata_i(regs_rdata2_o),
        .ex_jump_flag_i(ex_jump_flag_o),
        .reg1_raddr_o(id_reg1_raddr_o),
        .reg2_raddr_o(id_reg2_raddr_o),
        .mem_req_o(id_mem_req_o),
        .inst_o(id_inst_o),
        .inst_addr_o(id_inst_addr_o),
        .reg1_rdata_o(id_reg1_rdata_o),
        .reg2_rdata_o(id_reg2_rdata_o),
        .reg_we_o(id_reg_we_o),
        .reg_waddr_o(id_reg_waddr_o),
        .csr_rdata_i(csr_data_o),
        .csr_raddr_o(id_csr_raddr_o),
        .csr_we_o(id_csr_we_o),
        .csr_rdata_o(id_csr_rdata_o),
        .csr_waddr_o(id_csr_waddr_o)
    );

   
    id_ex u_id_ex(
        .clk(clk),
        .rst(rst),
        .inst_i(id_inst_o),
        .inst_addr_i(id_inst_addr_o),
        .reg_we_i(id_reg_we_o),
        .reg_waddr_i(id_reg_waddr_o),
        .reg1_rdata_i(id_reg1_rdata_o),
        .reg2_rdata_i(id_reg2_rdata_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .inst_o(ie_inst_o),
        .inst_addr_o(ie_inst_addr_o),
        .reg_we_o(ie_reg_we_o),
        .reg_waddr_o(ie_reg_waddr_o),
        .reg1_rdata_o(ie_reg1_rdata_o),
        .reg2_rdata_o(ie_reg2_rdata_o),
        .csr_we_i(id_csr_we_o),
        .csr_waddr_i(id_csr_waddr_o),
        .csr_rdata_i(id_csr_rdata_o),
        .csr_we_o(ie_csr_we_o),
        .csr_waddr_o(ie_csr_waddr_o),
        .csr_rdata_o(ie_csr_rdata_o)
    );

    
    ex u_ex(
        .rst(rst),
        .inst_i(ie_inst_o),
        .inst_addr_i(ie_inst_addr_o),
        .reg_we_i(ie_reg_we_o),
        .reg_waddr_i(ie_reg_waddr_o),
        .reg1_rdata_i(ie_reg1_rdata_o),
        .reg2_rdata_i(ie_reg2_rdata_o),
        .mem_rdata_i(rib_ex_data_i),
        .mem_wdata_o(ex_mem_wdata_o),
        .mem_raddr_o(ex_mem_raddr_o),
        .mem_waddr_o(ex_mem_waddr_o),
        .mem_we_o(ex_mem_we_o),
        .mem_req_o(ex_mem_req_o),
        .reg_wdata_o(ex_reg_wdata_o),
        .reg_we_o(ex_reg_we_o),
        .reg_waddr_o(ex_reg_waddr_o),
        .hold_flag_o(ex_hold_flag_o),
        .jump_flag_o(ex_jump_flag_o),
        .jump_addr_o(ex_jump_addr_o),
        .int_assert_i(clint_int_assert_o),
        .int_addr_i(clint_int_addr_o),
        .div_ready_i(div_ready_o),
        .div_result_i(div_result_o),
        .div_busy_i(div_busy_o),
        .div_op_i(div_op_o),
        .div_reg_waddr_i(div_reg_waddr_o),
        .div_start_o(ex_div_start_o),
        .div_dividend_o(ex_div_dividend_o),
        .div_divisor_o(ex_div_divisor_o),
        .div_op_o(ex_div_op_o),
        .div_reg_waddr_o(ex_div_reg_waddr_o),
        .csr_we_i(ie_csr_we_o),
        .csr_waddr_i(ie_csr_waddr_o),
        .csr_rdata_i(ie_csr_rdata_o),
        .csr_wdata_o(ex_csr_wdata_o),
        .csr_we_o(ex_csr_we_o),
        .csr_waddr_o(ex_csr_waddr_o)
    );

    
    div u_div(
        .clk(clk),
        .rst(rst),
        .dividend_i(ex_div_dividend_o),
        .divisor_i(ex_div_divisor_o),
        .start_i(ex_div_start_o),
        .op_i(ex_div_op_o),
        .reg_waddr_i(ex_div_reg_waddr_o),
        .result_o(div_result_o),
        .ready_o(div_ready_o),
        .busy_o(div_busy_o),
        .op_o(div_op_o),
        .reg_waddr_o(div_reg_waddr_o)
    );

    
    clint u_clint(
        .clk(clk),
        .rst(rst),
        .int_flag_i(if_int_flag_o),
        .inst_i(id_inst_o),
        .inst_addr_i(id_inst_addr_o),
        .jump_flag_i(ex_jump_flag_o),
        .jump_addr_i(ex_jump_addr_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .data_i(csr_clint_data_o),
        .csr_mtvec(csr_clint_csr_mtvec),
        .csr_mepc(csr_clint_csr_mepc),
        .csr_mstatus(csr_clint_csr_mstatus),
        .we_o(clint_we_o),
        .waddr_o(clint_waddr_o),
        .raddr_o(clint_raddr_o),
        .data_o(clint_data_o),
        .hold_flag_o(clint_hold_flag_o),
        .global_int_en_i(csr_global_int_en_o),
        .int_addr_o(clint_int_addr_o),
        .int_assert_o(clint_int_assert_o)
    );

endmodule

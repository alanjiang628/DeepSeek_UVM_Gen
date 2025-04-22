`ifndef __TB_TOP_SV__
`define __TB_TOP_SV__
`timescale 1ns/1ps
`include "uvm_macros.svh"
`include "sva_lib.sv"
module tb_top;
    import uvm_pkg::*;
	import sc_env_pkg::*;
    // 时钟生成
    bit clk;
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 50MHz时钟
    end

    // 物理接口直接绑定时钟
    signal_conditioner_if phys_if(clk);
    // DUT实例化
    signal_conditioner dut(
        .clk      (clk),
        .reset_n  (phys_if.reset_n),
        .noisy_in (phys_if.noisy_in),
        .clean_out(phys_if.clean_out)
    );

    // 配置数据结构
    sc_config my_cfg;

    // 初始化测试平台
    initial begin
        run_test();
	end

	initial begin
        // 1. 传递virtual interface到UVM
        uvm_config_db#(virtual signal_conditioner_if)::set(null, "*", "vif", phys_if);
    end

    // 实例化断言模块
    sc_checker_assertions #(.DEBOUNCE_THRESHOLD(`DEBOUNCE_THRESHOLD)) sva_inst (
        .clk(clk),
        .reset_n(phys_if.reset_n),
        .noisy_in(phys_if.noisy_in),
        .clean_out(phys_if.clean_out)
    );

    // 仿真结束检查
    final begin
        if ($test$plusargs("CHECK_LEAKS")) begin
            $display("[TB] Checking for memory leaks...");
        end
    end

endmodule

`endif            

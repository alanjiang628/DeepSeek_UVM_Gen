`ifndef __SC_TRANSACTION_SV__
`define __SC_TRANSACTION_SV__
class sc_transaction extends uvm_sequence_item;
    // ==============================================
    // 基础信号 (所有测试场景共用)
    // ==============================================
	rand bit     noisy_in;          // 输入噪声信号
    rand bit     reset_n;           // 异步复位信号
         bit     clean_out;         // 消抖后输出信号 (Monitor采集)
         time    sample_time;       // 采样时间戳
	rand glitch_type_e glitch_type; // glitch type { RESET_GLITCH, CLOCK_GLITCH, DATA_GLITCH,POWER_DROP }

    // ==============================================
    // 时序控制 (debounce_sequence 使用)
    // ==============================================
    rand int     duration_cycles;    // 信号持续时间 (时钟周期数)
    rand int     debounce_threshold; // 消抖阈值 (可随机化)

    // ==============================================
    // 时序违例 (timing_sequence 使用)
    // ==============================================
    rand int     setup_violation;   // 建立时间违例量 (ps)
    rand int     hold_violation;    // 保持时间违例量 (ps)

    // ==============================================
    // 异常注入 (glitch_sequence 使用)
    // ==============================================
    rand bit     reset_glitch;      // 复位毛刺标志
    rand bit     clock_glitch;      // 时钟抖动标志
    rand bit     data_glitch;       // 数据异常标志
    rand bit     power_drop;        // 电源跌落标志
    rand int     glitch_duration;   // 毛刺持续时间 (ns)

    // ==============================================
    // 功能覆盖率字段 (可选)
    // ==============================================
    rand int     debug_id;          // 调试标识符

    // ==============================================
    // UVM 注册与字段自动化
    // ==============================================
    `uvm_object_utils_begin(sc_transaction)
        // 基础信号
        `uvm_field_int(noisy_in,         UVM_ALL_ON)
        `uvm_field_int(reset_n,          UVM_ALL_ON)
        `uvm_field_int(clean_out,        UVM_ALL_ON)
        `uvm_field_int(sample_time,      UVM_TIME)

        // 时序控制
        `uvm_field_int(duration_cycles,   UVM_DEC)
        `uvm_field_int(debounce_threshold,UVM_DEC)

        // 时序违例
        `uvm_field_int(setup_violation,   UVM_DEC)
        `uvm_field_int(hold_violation,    UVM_DEC)
		
        // 异常注入
        `uvm_field_int(reset_glitch,      UVM_BIN)
        `uvm_field_int(clock_glitch,      UVM_BIN)
        `uvm_field_int(data_glitch,       UVM_BIN)
        `uvm_field_int(power_drop,        UVM_BIN)
        `uvm_field_int(glitch_duration,   UVM_DEC)

        // 调试字段
        `uvm_field_int(debug_id,          UVM_DEC)
		`uvm_field_enum(glitch_type_e,glitch_type,UVM_ALL_ON)

    `uvm_object_utils_end

    // 基础约束
    constraint c_basic {
        soft reset_n == 1;          // 默认复位无效
        soft debounce_threshold == 500; // 默认消抖阈值 (对应10us@50MHz)
    }

    // 消抖测试约束 (debounce_sequence)
    constraint c_debounce {
        duration_cycles inside {[1:1_000_000]};
        solve duration_cycles before noisy_in;
    }

    // 时序违例约束 (timing_sequence)
    constraint c_timing_violation {
        setup_violation inside {[-1000:1000]}; // ±1ns违例范围
        hold_violation  inside {[-1000:1000]};
        (setup_violation == 0) || (hold_violation == 0); // 不同时违例
    }

    // 异常注入约束 (glitch_sequence)
    constraint c_glitch {
        glitch_duration inside {[1:100]};     // 毛刺持续时间1-100ns
        $countones({reset_glitch, clock_glitch, data_glitch, power_drop}) <= 1; // 互斥异常类型
    }

    // ==============================================
    // 构造函数
    // ==============================================
    function new(string name = "sc_transaction");
        super.new(name);
    endfunction

    // ==============================================
    // 自定义方法 (可选)
    // ==============================================
    function string convert2string();
        return $sformatf("noisy_in=0x%0d clean_out=0x%0d @%0t",
                        noisy_in, clean_out, sample_time);
	endfunction
endclass
`endif
		







		
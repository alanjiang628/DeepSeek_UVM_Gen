`ifndef __SC_CONFIG_SV__
`define __SC_CONFIG_SV__
class sc_config extends uvm_object;
    `uvm_object_utils(sc_config)
	
	// 必须声明为virtual interface
    virtual signal_conditioner_if vif;
	
    // 可配置参数（带默认值）
    int unsigned debounce_threshold = 500_000;  // 默认10ms@50MHz
    bit enable_coverage = 1;                   // 覆盖率开关
    bit enable_sb   = 1;                   // scoreboard检查开关

    // 约束随机化参数
    rand int glitch_test_count;
    constraint glitch_test_c {
        glitch_test_count inside {[10:100]};
    }

    function new(string name = "sc_config");
        super.new(name);
    endfunction

    // 配置有效性检查
    function bit is_valid();
        return (vif != null);
    endfunction

endclass
`endif	
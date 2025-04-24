class sc_coverage extends uvm_subscriber #(sc_transaction);
    `uvm_component_utils(sc_coverage)

    // 配置对象
    sc_config cfg;
    
    // 测试用例类型标识
    string test_name;
    
    // 主覆盖率模型
    covergroup glitch_cg with function sample(sc_transaction tr);
        // 输入信号跳变 (所有测试共用)
        noisy_trans: coverpoint tr.noisy_in {
            bins rise = (0 => 1);
            bins fall = (1 => 0);
            option.weight = 0; // 默认不计算权重
        }

        // 消抖周期统计 (debounce测试专用)
        debounce_cp: coverpoint tr.duration_cycles {
            bins short = {[1:100]};
            bins med   = {[101:1000]};
            bins long  = default;
            option.weight = 0;
        }

        // 异常类型 (glitch测试专用)
        glitch_type: coverpoint tr.glitch_type {
            bins reset = {RESET_GLITCH};
            bins clock = {CLOCK_GLITCH};
            bins power = {POWER_DROP};
            option.weight = 0;
        }
    endgroup

    // 新增：用例相关覆盖率组
    covergroup debounce_cg with function sample(sc_transaction tr);
        option.per_instance = 1;
        option.name = "debounce_related";
        
        // 只包含debounce测试相关的coverpoint
        cp_noisy: coverpoint tr.noisy_in {
            bins rise = (0 => 1);
            bins fall = (1 => 0);
        }
        
        cp_duration: coverpoint tr.duration_cycles {
            bins short = {[1:100]};
            bins med   = {[101:1000]};
            bins long  = default;
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        glitch_cg = new();
        debounce_cg = new();
    endfunction

    // 新增：在build_phase获取配置
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // 1. 获取配置对象
        if(!uvm_config_db#(sc_config)::get(this, "", "config", cfg))
            `uvm_fatal("CFG", "Config not found")
        
        // 2. 获取测试用例名称
        if(!uvm_config_db#(string)::get(this, "", "test_name", test_name))
            `uvm_info("CFG", "Using default test_name", UVM_DEBUG)
        else
            `uvm_info("CFG", $sformatf("Got test_name: %s", test_name), UVM_DEBUG)
    endfunction
	
    function void write(sc_transaction t);
        if(cfg.enable_coverage) begin
            glitch_cg.sample(t);
            
            // 根据测试用例选择特定覆盖率组
            case(test_name)
                "debounce_test": begin
                    debounce_cg.sample(t);
                    `uvm_info("COV", $sformatf("Debounce Coverage: %.2f%%", 
                             debounce_cg.get_inst_coverage()), UVM_MEDIUM)
                end
                default: begin
                    `uvm_info("COV", $sformatf("Global Coverage: %.2f%%", 
                             glitch_cg.get_inst_coverage()), UVM_MEDIUM)
                end
            endcase
        end
    endfunction

    function void report_phase(uvm_phase phase);
        // 只报告当前测试相关的覆盖率
        case(test_name)
            "debounce_test": begin
                `uvm_info("COV", $sformatf("DEBOUNCE-RELATED COVERAGE: %.2f%%\n%s",
                         debounce_cg.get_inst_coverage(),
                         debounce_cg.get_coverage_report()), UVM_LOW)
            end
            default: begin
                `uvm_info("COV", $sformatf("GLOBAL COVERAGE: %.2f%%\n%s",
                         glitch_cg.get_inst_coverage(),
                         glitch_cg.get_coverage_report()), UVM_LOW)
            end
        endcase
    endfunction
endclass
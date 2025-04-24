`ifndef __SC_TEST_PKG_SV__
`define __SC_TEST_PKG_SV__
package sc_test_pkg;
    import uvm_pkg::*;
    import sc_env_pkg::*;
    import sc_seq_pkg::*;
	import enum_pkg::*;
	class base_test extends uvm_test;
	    `uvm_component_utils(base_test)

	    // 环境实例和配置对象
	    sc_env env;
	    sc_config cfg;
		bit test_pass =1;
		int error_count = 0;

	    // 标准构造函数
	    function new(string name = "base_test", uvm_component parent);
	        super.new(name, parent);
	    endfunction

	    // 构建阶段 - 初始化环境和配置
	    function void build_phase(uvm_phase phase);
	        super.build_phase(phase);

	        // 创建并配置对象
	        cfg = create_config();
	        configure_test(cfg);

	        // 传递virtual interface
	        if(!uvm_config_db#(virtual signal_conditioner_if)::get(this, "", "vif", cfg.vif))
	            `uvm_fatal("NO_IF", "Virtual interface not found")

	        // 将配置存入数据库
	        uvm_config_db#(sc_config)::set(this, "*", "config", cfg);
	        // 创建环境
	        env = sc_env::type_id::create("env", this);
	    endfunction

	    // 可覆盖的配置创建方法
	    virtual function sc_config create_config();
	        return sc_config::type_id::create("cfg");
	    endfunction

	    // 可覆盖的测试配置方法
	    virtual function void configure_test(sc_config cfg);
	        // 默认配置
	        cfg.enable_coverage = 1;
	        cfg.enable_sb = 1;
	        cfg.debounce_threshold = 500; // 10ms @50MHz
	    endfunction
		
	    // 标准运行流程
	    task run_phase(uvm_phase phase);
	        phase.raise_objection(this);
	        `uvm_info("TEST", "Default test sequence running", UVM_MEDIUM)
	        phase.drop_objection(this);
	    endtask
		
    	function void report_phase(uvm_phase phase);
    	    super.report_phase(phase);

    	    // 自动检查错误
    	    error_count = uvm_report_server::get_server().get_severity_count(UVM_ERROR);
    	    if(error_count > 0) test_pass = 0;
			
    	    // 打印酷炫结果
    	    print_test_result();
    	endfunction
		
    	function void print_test_result();
    	    string pass_art = {
    	        "\n",
    	        "  ██████╗  █████╗ ███████╗███████╗\n",
    	        "  ██╔══██╗██╔══██╗██╔════╝██╔════╝\n",
    	        "  ██████╔╝███████║███████╗███████╗\n",
    	        "  ██╔═══╝ ██╔══██║╚════██║╚════██║\n",
    	        "  ██║     ██║  ██║███████║███████║\n",
    	        "  ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝\n",
    	        "  (•̀ᴗ•́)و ̑̑ TEST PASSED!\n"
    	    };

    	    string fail_art = {
    	        "\n",
    	        "  ███████╗ █████╗ ██╗██╗     \n",
    	        "  ██╔════╝██╔══██╗██║██║     \n",
    	        "  █████╗  ███████║██║██║     \n",
    	        "  ██╔══╝  ██╔══██║██║██║     \n",
    	        "  ██║     ██║  ██║██║███████╗\n",
    	        "  ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝\n",
    	        "  (╯°□°)╯︵ ┻━┻ TEST FAILED!\n",
    	        $sformatf("  Found %0d errors!", error_count)
    	    };

    	    // 彩色打印
    	    if(test_pass) begin
    	        $write("%c[1;32m", 27); // 绿色
    	        $display(pass_art);
    	    end else begin
    	        $write("%c[1;31m", 27); // 红色
    	        $display(fail_art);
    	    end
    	    $write("%c[0m", 27); // 重置颜色

    	    // 标准报告
    	    $display("\n=== UVM Report Summary ===");
    	    $display("Fatal:   %0d", uvm_report_server::get_server().get_severity_count(UVM_FATAL));
    	    $display("Error:   %0d", error_count);
    	    $display("Warning: %0d", uvm_report_server::get_server().get_severity_count(UVM_WARNING));
			$display("Sim Time: %0t ns", $time);
    	endfunction
	endclass


	class reset_test extends base_test;
	    `uvm_component_utils(reset_test)

	    function new(string name = "reset_test", uvm_component parent);
	        super.new(name, parent);
	    endfunction

	    function void configure_test(sc_config cfg);
	        super.configure_test(cfg);
	        // 测试特定配置
	        cfg.enable_coverage = 0;  // 复位测试不需要覆盖率
	        cfg.debounce_threshold = 0; // 复位时忽略消抖
	        cfg.enable_sb = 0;
	    endfunction

	    task run_phase(uvm_phase phase);
	        reset_sequence seq;			
	        phase.raise_objection(this);

	        // 执行10次随机复位
	        repeat(10) begin
	            seq = reset_sequence::type_id::create("seq");
	            assert(seq.randomize());
	            seq.start(env.agent.sequencer);
	        end
			
	        phase.drop_objection(this);
	    endtask
	endclass

	class debounce_test extends base_test;
	    `uvm_component_utils(debounce_test)

	    rand int num_trans = 10;

		function new(string name = "debounce_test", uvm_component parent);
	        super.new(name, parent);
	    endfunction

	    function void configure_test(sc_config cfg);
	        super.configure_test(cfg);
	        // 调整消抖阈值
	        cfg.debounce_threshold = 5_00; // 20ms阈值
	    endfunction

		function void build_phase(uvm_phase phase);
    	    super.build_phase(phase);
    	    // 在build_phase设置测试标识
    	    uvm_config_db#(string)::set(this, "*", "test_name", "debounce_test");
    	endfunction

		task run_phase(uvm_phase phase);
			debounce_sequence seq;
			reset_sequence rst_seq;

			phase.raise_objection(this);

			rst_seq	= reset_sequence::type_id::create("rst_seq");
			rst_seq.start(env.agent.sequencer);

	        repeat(num_trans) begin
	            seq = debounce_sequence::type_id::create("seq");
	            seq.start(env.agent.sequencer);
	        end

	        phase.drop_objection(this);
	    endtask
	endclass



endpackage
`endif





			
			
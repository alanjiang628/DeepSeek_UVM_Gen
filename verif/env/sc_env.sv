`ifndef __SC_ENV_SV__
`define __SC_ENV_SV__
class sc_env extends uvm_env;
    `uvm_component_utils(sc_env)

    sc_config cfg;
    sc_agent      agent;
    sc_coverage   coverage;
	sc_scoreboard scoreboard;
	string        test_name;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        // 获取配置对象
        if(!uvm_config_db#(sc_config)::get(this, "", "config", cfg))
            `uvm_fatal("CFG", "Config not found")  

        // 创建组件（根据配置条件实例化）
        agent = sc_agent::type_id::create("agent", this);
    	// 设置 agent 为 active
    	uvm_config_db#(uvm_active_passive_enum)::set(this, "agent", "is_active", UVM_ACTIVE);

        if(cfg.enable_coverage) begin
            coverage = sc_coverage::type_id::create("coverage", this);
            uvm_config_db#(sc_config)::set(this, "coverage", "config", cfg);
        end

		if(cfg.enable_sb) begin
        	scoreboard = sc_scoreboard::type_id::create("scoreboard", this);
		end
     endfunction

    function void connect_phase(uvm_phase phase);    
        // 连接监测端口
        if(cfg.enable_coverage)
            agent.monitor.ap.connect(coverage.analysis_export);
		if(cfg.enable_sb)
        // 连接monitor到scoreboard
        	agent.monitor.ap.connect(scoreboard.mon_imp);

		// 传递测试标识到覆盖率收集器
        if(uvm_config_db#(string)::get(this, "", "test_name", test_name))
            uvm_config_db#(string)::set(this, "coverage", "test_name", test_name);
    endfunction
endclass
`endif    


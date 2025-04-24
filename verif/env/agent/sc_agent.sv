`ifndef _SC_AGENT_SV
`define _SC_AGENT_SV

class sc_agent extends uvm_agent;
	sc_driver driver;
	sc_monitor monitor;
	sc_sequencer sequencer;
	virtual signal_conditioner_if vif; // Agent也需要声明vif
	
	`uvm_component_utils(sc_agent)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor = sc_monitor::type_id::create("monitor", this);
		if (is_active == UVM_ACTIVE) begin
			driver= sc_driver::type_id::create("driver", this);
			sequencer = sc_sequencer::type_id::create("sequencer", this);
		end
		
		//从顶层获取vif
		if(!uvm_config_db#(virtual signal_conditioner_if)::get(this,"", "vif", vif))
			`uvm_fatal("NO_IF", "Interface not found at agent level")
	endfunction

	function void connect_phase(uvm_phase phase);
		if (is_active == UVM_ACTIVE)
			driver.seq_item_port.connect(sequencer.seq_item_export);
		// 将vif传递给子组件
		uvm_config_db#(virtual signal_conditioner_if)::set(this, "mon", "vif", vif);
		if(driver != null)
			uvm_config_db#(virtual signal_conditioner_if)::set(this, "drv", "vif", vif);
	endfunction
endclass

`endif
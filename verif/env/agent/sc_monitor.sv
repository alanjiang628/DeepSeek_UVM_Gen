`ifndef __SC_MONITOR_SV__
`define __SC_MONITOR_SV__

class sc_monitor extends uvm_monitor;
	virtual signal_conditioner_if vif;          // 补充1：声明virtual interface
    uvm_analysis_port #(sc_transaction) ap;
	
    `uvm_component_utils(sc_monitor)

	function new(string name, uvm_component parent);
        super.new(name, parent);
		ap = new("ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual signal_conditioner_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_IF", "Virtual interface not found!")
    endfunction
	
	task run_phase(uvm_phase phase);
        forever begin

            @(posedge vif.clk);
            if (vif.reset_n) begin

                sc_transaction tr = sc_transaction::type_id::create("tr");
                tr.noisy_in = vif.noisy_in;
                tr.clean_out = vif.clean_out;
                ap.write(tr);
            end
        end
    endtask
endclass	
`endif			
		
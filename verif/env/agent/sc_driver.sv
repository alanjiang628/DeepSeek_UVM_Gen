`ifndef __SC_DRIVER_SV__
`define __SC_DRIVER_SV__

class sc_driver extends uvm_driver #(sc_transaction);
    virtual signal_conditioner_if vif;          // 补充1：声明virtual interface
    `uvm_component_utils(sc_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual signal_conditioner_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_IF", "Virtual interface not found!")
    endfunction

	task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            //#((10 + req.setup_violation) * 1ns);
            vif.drv_cb.noisy_in <= req.noisy_in;
			vif.drv_cb.reset_n <= req.reset_n;
            seq_item_port.item_done();
        end
        end
    endtask
endclass

`endif		
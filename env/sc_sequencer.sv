`ifndef __SC_SEQUENCER_SV__
`define __SC_SEQUENCER_SV__
class sc_sequencer extends uvm_sequencer #(sc_transaction);
    `uvm_component_utils(sc_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

	virtual signal_conditioner_if vif;  // 在此获取interface

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual signal_conditioner_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_IF", "Interface not found in sequencer")
    endfunction

	// 可选：添加特定控制逻辑
    task pre_do(uvm_sequence_item item);
        `uvm_info("SEQ", $sformatf("Starting transaction: %s", item.get_name()), UVM_HIGH)
    endtask
endclass

`endif


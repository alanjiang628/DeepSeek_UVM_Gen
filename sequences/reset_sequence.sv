`ifndef __RESET_SEQUENCE_SV__
`define __RESET_SEQUENCE_SV__

class reset_sequence extends base_sequence;
    `uvm_object_utils(reset_sequence)
	// Constructor
  	function new(string name = "reset_sequence");
    	super.new(name);
  	endfunction

    task body();
        `uvm_info("SEQ", "Applying reset sequence", UVM_LOW)
		p_sequencer.vif.noisy_in = 1;
 		#50ns;
		p_sequencer.vif.reset_n = 0;
        #100ns;
        if (p_sequencer.vif.clean_out !== 0)
            `uvm_error("RST", "Output not cleared during reset")
        p_sequencer.vif.reset_n = 1;
        #100ns;

    endtask
endclass

`endif     
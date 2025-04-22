`ifndef __BASE_SEQUENCE_SV__
`define __BASE_SEQUENCE_SV__

class base_sequence extends uvm_sequence #(sc_transaction);
    `uvm_object_utils(base_sequence)
	`uvm_declare_p_sequencer(sc_sequencer)

	// Constructor
  	function new(string name = "base_sequence");
    	super.new(name);
  	endfunction

endclass

`endif    
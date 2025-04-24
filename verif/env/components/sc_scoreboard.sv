`ifndef __SC_SCOREBOARD_SV__
`define __SC_SCOREBOARD_SV__

class sc_scoreboard extends uvm_scoreboard;
    uvm_analysis_imp #(sc_transaction, sc_scoreboard) mon_imp;
    `uvm_component_utils(sc_scoreboard)
    // 统计信息
    bit reset_released = 0;  // 复位释放标志位
    int total_pulses = 0;
    int error_count = 0;
    int filtered_count = 0;
    int passed_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
		mon_imp = new("mon_imp", this);
    endfunction

    function void write(sc_transaction tr);
        // 检测复位释放时刻
        if (!reset_released && tr.reset_n) begin
            `uvm_info("RESET", "Reset released, start monitoring", UVM_MEDIUM)
            reset_released = 1;
        end

		// 只在复位释放后进行检查
        if (reset_released) begin
        	total_pulses++;  

        	// 检查消抖行为
        	if (tr.duration_cycles < tr.debounce_threshold && tr.clean_out) begin
        	    `uvm_error("DEBOUNCE_ERR",
        	        $sformatf("Short pulse(%0d cycles) passed! Should be filtered",
        	        tr.duration_cycles))
        	    error_count++;
        	end
        	else if (tr.duration_cycles >= tr.debounce_threshold && !tr.clean_out) begin
        	    `uvm_error("DEBOUNCE_ERR",
        	        $sformatf("Valid pulse(%0d cycles) filtered! Should pass",
        	        tr.duration_cycles))
        	    error_count++;
        	end
        	else begin
        	    if (tr.clean_out) passed_count++;
        	    else filtered_count++;
        	    `uvm_info("CHECK", $sformatf("Pulse %0d cycles correctly %s",
        	             tr.duration_cycles,
        	             tr.clean_out ? "passed" : "filtered"), UVM_HIGH)
        	end
		end
    endfunction
endclass

`endif


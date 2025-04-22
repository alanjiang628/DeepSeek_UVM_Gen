`ifndef __DEBOUNCE_SEQUENCE_SV__
`define __DEBOUNCE_SEQUENCE_SV__

class debounce_sequence extends base_sequence;
    `uvm_object_utils(debounce_sequence)
	
    // 测试控制参数
    rand int num_valid_pulses = 10;    // 有效长脉冲数量
    rand int num_short_pulses = 10;    // 短干扰脉冲数量
    rand int pulse_gap = 10;           // 脉冲间隔(时钟周期)

    // 约束：确保合理的测试参数
    constraint c_test_params {
        num_valid_pulses inside {[5:20]};
        num_short_pulses inside {[5:20]};
        pulse_gap inside {[5:50]};
    }

    function new(string name="debounce_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Starting debounce test sequence", UVM_LOW)
        // 1. 生成短干扰脉冲（应被过滤）
        `uvm_info("SEQ", "Generating short noise pulses", UVM_HIGH)
        repeat(num_short_pulses) begin
            `uvm_do_with(req, {
                duration_cycles < debounce_threshold;
                noisy_in == 1;
                reset_n == 1;
            })

            `uvm_do_with(req, {
                duration_cycles == pulse_gap;
                noisy_in == 0;
                reset_n == 1;
            })
        end

        // 2. 生成有效长脉冲（应被传递）
        `uvm_info("SEQ", "Generating valid pulses", UVM_HIGH)
        repeat(num_valid_pulses) begin
            `uvm_do_with(req, {
                duration_cycles >= debounce_threshold;
                noisy_in == 1;
                reset_n == 1;
            })

            `uvm_do_with(req, {
                duration_cycles == pulse_gap;
                noisy_in == 0;
                reset_n == 1;
            })
        end

        // 3. 边界条件测试
        `uvm_info("SEQ", "Testing boundary conditions", UVM_HIGH)
        `uvm_do_with(req, {
            duration_cycles == debounce_threshold - 1;
            noisy_in == 1;
            reset_n == 1;
        })
        `uvm_do_with(req, {
            duration_cycles == debounce_threshold;
            noisy_in == 1;
            reset_n == 1;
        })
    endtask
	

endclass

`endif	
		


		
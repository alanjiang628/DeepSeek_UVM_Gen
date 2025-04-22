module sc_checker_assertions #(
    parameter int DEBOUNCE_THRESHOLD = 10
)(
    input logic clk,
    input logic reset_n,
    input logic noisy_in,
    input logic clean_out
);
    // 断言属性：去抖动有效性
    property p_debounce_valid;
        @(posedge clk) disable iff(!reset_n)
        $rose(noisy_in) |-> ##[0:DEBOUNCE_THRESHOLD] clean_out == noisy_in;
    endproperty

    // 断言实例：去抖动有效性
    assert property (p_debounce_valid);

    // 断言属性：毛刺过滤
    property p_glitch_filter;
        @(posedge clk)
        noisy_in && (noisy_in ^ clean_out) |->
        ##[1:10] $stable(clean_out);
    endproperty

    // 断言实例：毛刺过滤
    assert property (p_glitch_filter);
endmodule
`endif


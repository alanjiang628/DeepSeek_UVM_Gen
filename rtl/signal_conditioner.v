`ifndef __SIGNAL_CONDITIONER_V__
`define __SIGNAL_CONDITIONER_V__

module signal_conditioner (
    input wire clk,          // 系统时钟（例如50MHz）
    input wire reset_n,      // 异步低电平复位
     input wire noisy_in,     // 带有噪声的输入信号
    output reg clean_out     // 整形后的干净输出
);

// =============================================
// 参数配置区
// =============================================
parameter DEBOUNCE_CYCLES = 20'd500; // 消抖时间（10ms @50MHz）
parameter SYNC_STAGES = 2;               // 同步级数

// =============================================
// 输入同步化（防止亚稳态）
// =============================================
reg [SYNC_STAGES-1:0] sync_reg;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        sync_reg <= {SYNC_STAGES{1'b0}};
    end else begin
    end
end

wire sync_in = sync_reg[SYNC_STAGES-1];

// =============================================
// 消抖逻辑（有限状态机）
// =============================================
reg [19:0] debounce_counter;
reg last_state;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        debounce_counter <= 20'b0;
        last_state <= 1'b0;
        clean_out <= 1'b0;
    end else begin
        // 检测输入状态变化
        if (sync_in != last_state) begin
            debounce_counter <= 20'b0;
            last_state <= sync_in;
        end else begin
            if (debounce_counter < DEBOUNCE_CYCLES) begin
                debounce_counter <= debounce_counter + 1;
            end else begin
                clean_out <= last_state;
            end
        end
    end
end

endmodule

`endif                            
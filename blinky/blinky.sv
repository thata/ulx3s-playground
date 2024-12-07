module top(
    input wire clk_25mhz,
    output wire [7:0] led,
    input wire [6:0] btn
);

    logic [24:0] counter;

    always_ff @(posedge clk_25mhz) begin
        counter <= counter + 1;
    end

    // LEDに、常時点灯、ボタン1、ボタン2、カウンタの上位5ビットを表示
    assign led = { 1, btn[1], btn[2], counter[24:20] };

endmodule

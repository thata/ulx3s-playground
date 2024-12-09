module top(
    input wire clk_25mhz,
    output wire [7:0] led,
    input wire [6:0] btn
);

    logic [7:0] step = 0;
    logic [31:0] tick = 0; // 1秒待機用のカウンタ
    logic mem_valid;
    logic mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] mem_rdata;

    logic [7:0] step_next;
    logic [31:0] tick_next;
    logic mem_valid_next;
    logic [31:0] mem_addr_next;
    logic [31:0] mem_wdata_next;
    logic [3:0]  mem_wstrb_next;
    logic [7:0] led_next;

    // ステップをLEDに表示（デバッグ用）
    // assign led = step;

    // BRAM コントローラーと接続
    bram_controller bram_inst (
        .clk(clk_25mhz),
        .reset_n(1),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    always_ff @(posedge clk_25mhz) begin
        step <= step_next;
        tick <= tick_next;
        mem_valid <= mem_valid_next;
        mem_addr <= mem_addr_next;
        mem_wdata <= mem_wdata_next;
        mem_wstrb <= mem_wstrb_next;
        led <= led_next;
    end

    always_comb begin
        // デフォルト値
        step_next = step;
        tick_next = tick;
        mem_valid_next = mem_valid;
        mem_addr_next = mem_addr;
        mem_wdata_next = mem_wdata;
        mem_wstrb_next = mem_wstrb;
        led_next = led;

        case (step)
            0: begin
                // 初期化
                step_next = 1; // ステップ1へ遷移
                tick_next = 0;
                mem_valid_next = 0;
                mem_addr_next = 32'h0000;
                mem_wdata_next = 32'hxxxx;
                mem_wstrb_next = 4'bxxxx; // 0000 は読み込み
                led_next = 8'b10000001;
            end
            1: begin
                // メモリの 0x00 番地を読み込み
                mem_addr_next = 32'h0000;
                mem_wstrb_next = 4'b0000;
                if (mem_ready) begin
                    // mem_ready がアサートされるまで待機
                    mem_valid_next = 0; // mem_valid をデアサート
                    step_next = 2; // ステップ2へ遷移
                    tick_next = 0; // 1秒待機用のカウンタをリセット
                    led_next = mem_rdata; // 読み込んだデータをLEDに表示
                end else begin
                    mem_valid_next = 1; // mem_valid をアサート
                end
            end
            2: begin
                // tick が 25_000_000 になるまで待機
                if (tick == 25_000_000) begin
                    // 1秒経過
                    step_next = 3; // ステップ0へ遷移
                    tick_next = 0; // 1秒待機用のカウンタをリセット
                end else begin
                    tick_next = tick + 1;
                end
            end
            3: begin
                // メモリの 0x04 番地を読み込み
                mem_addr_next = 32'h0004;
                mem_wstrb_next = 4'b0000;
                if (mem_ready) begin
                    // mem_ready がアサートされるまで待機
                    mem_valid_next = 0; // mem_valid をデアサート
                    step_next = 4; // ステップ4へ遷移
                    tick_next = 0; // 1秒待機用のカウンタをリセット
                    led_next = mem_rdata; // 読み込んだデータをLEDに表示
                end else begin
                    mem_valid_next = 1; // mem_valid をアサート
                end
            end
            4: begin
                // tick が 25_000_000 になるまで待機
                if (tick == 25_000_000) begin
                    // 1秒経過
                    step_next = 0; // ステップ0へ遷移
                    tick_next = 0; // 1秒待機用のカウンタをリセット
                end else begin
                    tick_next = tick + 1;
                end
            end
            default: begin
                // 何もしない
                step_next = 1'bx; // ステップ0へ遷移
                mem_valid_next = 1'bx;
                mem_addr_next = 32'hxxxx;
                mem_wdata_next = 32'hxxxx;
                mem_wstrb_next = 4'bxxxx;
                led_next = 8'hxx;
                tick_next = 32'hxxxx;
            end
        endcase
    end

endmodule

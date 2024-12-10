// BRAMコントローラーのテスト回路
// 0番地から28番地までパターンデータを書き込み、その後それを読み込んでLEDに表示する
module top(
    input wire clk_25mhz,
    output wire [7:0] led,
    input wire [6:0] btn
);

    logic [7:0] step = 0;
    logic [31:0] tick = 0; // スリープ用のカウンタ
    logic [7:0] counter = 0; // メモリアドレス指示用のカウンタ
    logic mem_valid;
    logic mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] mem_rdata;

    logic [7:0] step_next;
    logic [31:0] tick_next;
    logic [7:0] counter_next;
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
        counter <= counter_next;
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
        counter_next = counter;
        mem_valid_next = mem_valid;
        mem_addr_next = mem_addr;
        mem_wdata_next = mem_wdata;
        mem_wstrb_next = mem_wstrb;
        led_next = led;

        case (step)
            0: begin // 初期化
                step_next = 3; // 3で書き込んでから、1の読み込みへ行くぞ
                // step_next = 1; // ステップ1へ遷移

                tick_next = 0;
                counter_next = 0;
                mem_valid_next = 0;
                mem_addr_next = 32'h0000;
                mem_wdata_next = 32'hxxxx;
                mem_wstrb_next = 4'bxxxx; // 0000 は読み込み
                led_next = 8'b10101010;
            end
            1: begin // メモリを読み込み
                if (mem_ready) begin
                    // mem_ready がアサートされるまで待機
                    mem_valid_next = 0; // mem_valid をデアサート
                    step_next = 2; // ステップ2へ遷移
                    tick_next = 0; // 1秒待機用のカウンタをリセット
                    counter_next = (counter == 7) ? 0 : counter + 1; // 次のアドレスを指定
                    led_next = mem_rdata; // 読み込んだデータをLEDに表示
                end else begin
                    // 指定番地のデータを読み込み
                    mem_addr_next = counter << 2; // 4バイト単位でアクセスするため、2ビット左シフト
                    mem_wstrb_next = 4'b0000;
                    mem_valid_next = 1;
                end
            end
            2: begin // スリープ
                if (tick == 25_000_000) begin
                    // スリープ終了
                    step_next = 1;
                    tick_next = 0;
                end else begin
                    tick_next = tick + 1;
                end
            end
            3: begin // メモリへ書き込み
                if (mem_ready) begin // mem_ready がアサートされるまで待機
                    mem_valid_next = 0; // mem_valid をデアサート
                    counter_next = counter + 1;

                    step_next = 4; // ステップ4へ遷移
                end else begin
                    // 指定番地にデータを書き込み
                    mem_addr_next = counter << 2; // 4バイト単位でアクセスするため、2ビット左シフト

                    // counter が偶数なら 0b10101010、奇数なら 0b01010101 を書き込む
                    mem_wdata_next = (counter & 1) ? 32'b01010101 : 32'b10101010;

                    mem_wstrb_next = 4'b1111;
                    mem_valid_next = 1;

                    step_next = 3; // 3へ戻り、mem_ready を待機
                end
            end
            4: begin // 8回書き込むまでループ
                // counter 0 から 7 まで書き込んだら 1 へ遷移
                if (counter > 7) begin
                    counter_next = 0; // counter を初期化
                    step_next = 1; // ステップ1へ遷移
                end else begin
                    step_next = 3; // 3へ戻る
                end
            end
            default: begin
                // step の値が不正な場合
                step_next = 0; // ステップ0へ戻す
            end
        endcase
    end

endmodule

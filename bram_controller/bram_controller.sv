// BRAM コントローラー
module bram_controller(
    input wire clk,
    input wire reset_n,

    // TODO: あとで cs (chip select) を追加したい

    input wire mem_valid,
    output logic mem_ready,
    input wire [31:0] mem_addr,
    input wire [31:0] mem_wdata,
    input wire [3:0]  mem_wstrb, // 0'b0000 の場合は読み込み、0'b1111 の場合は書き込み
    output logic [31:0] mem_rdata
);
    parameter STATE_IDLE = 2'd0;
    parameter STATE_RECV_VALID = 2'd1;
    parameter STATE_RECV_VALID2 = 2'd2;
    parameter STATE_SEND_READY = 2'd3;

    //------------------------
    // デバッグ用モニタの設定
    //------------------------
    initial begin
        $monitor("%t: state = %d, reset_n = %b, mem_valid = %b, mem_ready = %b, mem_addr = %h, mem_wdata = %h, mem_wstrb = %b, mem_rdata = %h", $time, state, reset_n, mem_valid, mem_ready, mem_addr, mem_wdata, mem_wstrb, mem_rdata);
    end

    logic [31:0] mem [0:1023];
    logic [2:0] state;

    logic [2:0] state_next;
    logic mem_ready_next;
    logic [31:0] mem_rdata_next;

    assign mem_rdata_next = mem[mem_addr[9:2]];

    // メモリの初期化
    initial begin
        // mem[0] = 32'b0101;
        // mem[1] = 32'b1010;
        for (int i = 0; i < 1024; i++) begin
            // 以下のような感じにメモリを初期化
            //   mem[0x0000] = 0x0000
            //   mem[0x0004] = 0x0001
            //   mem[0x0008] = 0x0002
            //   mem[0x000C] = 0x0003
            //   mem[0x0010] = 0x0004
            //   ...
            mem[i] = i;
        end
    end

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            state = STATE_IDLE;
            mem_ready = 0;
            mem_rdata = 32'd0;
        end else begin
            state <= state_next;
            mem_ready <= mem_ready_next;
            mem_rdata <= mem_rdata_next;
        end
    end

    always_comb begin
        case (state)
            STATE_IDLE: begin
                state_next = (mem_valid) ? STATE_RECV_VALID : STATE_IDLE;
                mem_ready_next = 0;
            end
            STATE_RECV_VALID: begin
                state_next = STATE_SEND_READY;
                mem_ready_next = 1;
            end
            STATE_SEND_READY: begin
                state_next = STATE_IDLE;
                mem_ready_next = 0;
            end
            default: begin
                state_next = STATE_IDLE;
                mem_ready_next = 0;
            end
        endcase
    end
endmodule

// bram_controller のテストベンチ
// $ iverilog bram_controller_tb.sv bram_controller.sv && ./a.out
module bram_controller_test();

    logic clk;
    logic reset_n;
    logic mem_valid;
    logic mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] mem_rdata;

    bram_controller dut (
        .clk(clk),
        .reset_n(reset_n),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    initial begin
        // dut の波形を出力
        // $dumpfile("bram_controller_test.vcd");
        // $dumpvars(0, bram_controller_test);

        //--------------------------------------
        // 制御変数の初期化
        //--------------------------------------
        #10
        clk = 0;
        reset_n = 1;
        mem_valid = 0;
        mem_addr = 0;
        mem_wdata = 0;
        mem_wstrb = 4'b0000;
        #10

        //--------------------------------------
        // BRAMをリセット
        //--------------------------------------
        #10 reset_n = 0;
        #10 reset_n = 1;
        #10

        //--------------------------------------
        // メモリの 0x10 番地を読み込み
        //--------------------------------------
        #10
        mem_valid = 1;
        mem_addr = 32'h0010;
        mem_wstrb = 4'b0000;
        mem_wdata = 32'h0000;
        #10

        // mem_ready がアサートされるまで待機
        while (!mem_ready) begin
            // 何も行わず 10 ステップ待機
            #10;
        end

        // mem_ready = 1、かつ mem_rdata = 0x0004 であること
        assert(mem_ready == 1);
        assert(mem_rdata == 32'h0004) else $error("mem_rdata = %h", mem_rdata);

        // mem_valid をデアサート
        mem_valid = 0;
        #10

        //--------------------------------------
        // メモリの 0x20 番地を読み込み
        //--------------------------------------
        #10
        mem_valid = 1;
        mem_addr = 32'h0020;
        mem_wstrb = 4'b0000;
        mem_wdata = 32'h0000;
        #10

        // mem_ready がアサートされるまで待機
        while (!mem_ready) begin
            // 何も行わず 10 ステップ待機
            #10;
        end

        // mem_ready = 1 かつ mem_rdata = 0x0008 であること
        assert(mem_ready == 1) else $error("mem_ready = 0");
        assert(mem_rdata == 32'h0008) else $error("mem_rdata = %h", mem_rdata);

        // mem_valid をデアサート
        mem_valid = 0;
        #10

        //--------------------------------------
        // メモリの 0x10 番地へ書き込み
        //--------------------------------------
        #10
        mem_valid = 1;
        mem_wstrb = 4'b1111;
        mem_addr = 32'h0010;
        mem_wdata = 32'h0000FFFF;
        #10

        // mem_ready がアサートされるまで待機
        while (!mem_ready) begin
            // 何も行わず 10 ステップ待機
            #10;
        end

        // mem_ready = 1、かつ mem_rdata = 0x0000FFFF であること
        assert(mem_ready == 1);
        assert(mem_rdata == 32'h0000FFFF) else $error("mem_rdata = %h", mem_rdata);

        // mem_valid をデアサート
        mem_valid = 0;
        #10

        //--------------------------------------
        // メモリの 0x20 番地へ書き込み
        //--------------------------------------
        #10
        mem_valid = 1;
        mem_wstrb = 4'b1111;
        mem_addr = 32'h0020;
        mem_wdata = 32'h0000FF00;
        #10

        // mem_ready がアサートされるまで待機
        while (!mem_ready) begin
            // 何も行わず 10 ステップ待機
            #10;
        end

        // mem_ready = 1、かつ mem_rdata = 0x000FF00 であること
        assert(mem_ready == 1);
        assert(mem_rdata == 32'h0000FF00) else $error("mem_rdata = %h", mem_rdata);

        // mem_valid をデアサート
        mem_valid = 0;
        #10

        //--------------------------------------
        // メモリの 0x10 番地を読み込み
        //--------------------------------------
        #10
        mem_valid = 1;
        mem_addr = 32'h0010;
        mem_wstrb = 4'b0000;
        mem_wdata = 32'h0000;
        #10

        // mem_ready がアサートされるまで待機
        while (!mem_ready) begin
            // 何も行わず 10 ステップ待機
            #10;
        end

        // mem_ready = 1、かつ mem_rdata = 0x0000FFFF であること
        assert(mem_ready == 1);
        assert(mem_rdata == 32'h0000FFFF) else $error("mem_rdata = %h", mem_rdata);

        // mem_valid をデアサート
        mem_valid = 0;
        #10

        //--------------------------------------
        // メモリの 0x20 番地を読み込み
        //--------------------------------------
        #10
        mem_valid = 1;
        mem_wstrb = 4'b0000;
        mem_addr = 32'h0020;
        #10

        // mem_ready がアサートされるまで待機
        while (!mem_ready) begin
            // 何も行わず 10 ステップ待機
            #10;
        end

        // mem_ready = 1、かつ mem_rdata = 0x0000FFFF であること
        assert(mem_ready == 1);
        assert(mem_rdata == 32'h0000FF00) else $error("mem_rdata = %h", mem_rdata);

        // mem_valid をデアサート
        mem_valid = 0;
        #10

        $finish;
    end

    always #5 clk = ~clk;
endmodule

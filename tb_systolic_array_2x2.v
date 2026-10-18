`timescale 1ns / 1ps

module tb_systolic_array_2x2;

    reg clk;
    reg rst;
    reg [7:0] a0_in, a1_in;
    reg [7:0] b0_in, b1_in;

    wire [15:0] c00, c01, c10, c11;

    // Instantiate Unit Under Test (UUT)
    systolic_array_2x2 uut (
        .clk(clk),
        .rst(rst),
        .a0_in(a0_in),
        .a1_in(a1_in),
        .b0_in(b0_in),
        .b1_in(b1_in),
        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Setup dump file for waveform viewing
        $dumpfile("systolic_array.vcd");
        $dumpvars(0, tb_systolic_array_2x2);

        // Initialize signals
        clk = 0;
        rst = 1;
        a0_in = 0;
        a1_in = 0;
        b0_in = 0;
        b1_in = 0;

        // Apply reset for 2 clock cycles
        #10;
        rst = 0;

        $display("-----------------------------------------------------");
        $display("Starting Matrix Multiplication Simulation");
        $display("Matrix A = [ [1, 2], [3, 4] ]");
        $display("Matrix B = [ [5, 6], [7, 8] ]");
        $display("-----------------------------------------------------");

        // Cycle 1: Feed a00=1, b00=5 (Row 1 and Col 1 are delayed by 0s)
        @(posedge clk);
        a0_in = 8'd1; a1_in = 8'd0;
        b0_in = 8'd5; b1_in = 8'd0;

        // Cycle 2: Feed a01=2, a10=3, b10=7, b01=6
        @(posedge clk);
        a0_in = 8'd2; a1_in = 8'd3;
        b0_in = 8'd7; b1_in = 8'd6;

        // Cycle 3: Feed a11=4, b11=8 (Row 0 and Col 0 are done)
        @(posedge clk);
        a0_in = 8'd0; a1_in = 8'd4;
        b0_in = 8'd0; b1_in = 8'd8;

        // Cycle 4: Zero inputs (Flush pipeline)
        @(posedge clk);
        a0_in = 8'd0; a1_in = 8'd0;
        b0_in = 8'd0; b1_in = 8'd0;

        // Wait one more cycle for last accumulator to settle
        @(posedge clk);
        
        #1; // small delay to observe settled output
        $display("-----------------------------------------------------");
        $display("Simulation Finished!");
        $display("Result Matrix C:");
        $display("[ %0d  %0d ]", c00, c01);
        $display("[ %0d  %0d ]", c10, c11);
        $display("-----------------------------------------------------");

        if (c00 == 19 && c01 == 22 && c10 == 43 && c11 == 50) begin
            $display("TEST PASSED: Output matches theoretical result perfectly!");
        end else begin
            $display("TEST FAILED: Output mismatch!");
        end
        $display("-----------------------------------------------------");

        $finish;
    end

endmodule

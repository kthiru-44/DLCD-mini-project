`timescale 1ns / 1ps

module tb_systolic_array_2x2;

    reg clk;
    reg rst;
    reg [7:0] a0_in, a1_in;
    reg [7:0] b0_in, b1_in;

    wire [15:0] c00, c01, c10, c11;

    integer errors;
    integer cycle;

    // Unit Under Test
    systolic_array_2x2 uut (
        .clk(clk), .rst(rst),
        .a0_in(a0_in), .a1_in(a1_in),
        .b0_in(b0_in), .b1_in(b1_in),
        .c00(c00), .c01(c01), .c10(c10), .c11(c11)
    );

    // 10 ns clock (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Per-cycle trace (sampled just before each rising edge, so it shows
    // the state produced by the previous edge)
    always @(negedge clk)
        $display("t=%0t  cycle=%0d  in: a0=%0d a1=%0d b0=%0d b1=%0d | C: %0d %0d / %0d %0d",
                 $time, cycle, a0_in, a1_in, b0_in, b1_in, c00, c01, c10, c11);

    always @(posedge clk) if (!rst) cycle <= cycle + 1;

    // Inputs are driven on the FALLING edge so they never race with the
    // PEs, which sample on the RISING edge.
    task feed(input [7:0] a0, a1, b0, b1);
        begin
            @(negedge clk);
            a0_in = a0; a1_in = a1; b0_in = b0; b1_in = b1;
        end
    endtask

    task check(input [15:0] exp00, exp01, exp10, exp11);
        begin
            if (c00 !== exp00 || c01 !== exp01 || c10 !== exp10 || c11 !== exp11) begin
                $display("TEST FAILED: got [%0d %0d; %0d %0d], expected [%0d %0d; %0d %0d]",
                         c00, c01, c10, c11, exp00, exp01, exp10, exp11);
                errors = errors + 1;
            end else
                $display("TEST PASSED: C = [%0d %0d; %0d %0d]", c00, c01, c10, c11);
        end
    endtask

    task do_reset;
        begin
            @(negedge clk);
            rst = 1; a0_in = 0; a1_in = 0; b0_in = 0; b1_in = 0; cycle = 0;
            repeat (2) @(negedge clk);
            rst = 0;
        end
    endtask

    // C = A*B, with A=[[a00 a01];[a10 a11]], B=[[b00 b01];[b10 b11]]
    // Row 1 of A and column 1 of B are skewed by one cycle.
    task run_matmul(input [7:0] a00, a01, a10, a11, b00, b01, b10, b11);
        begin
            do_reset;
            feed(a00, 8'd0, b00, 8'd0);   // cycle 1
            feed(a01, a10,  b10, b01);    // cycle 2
            feed(8'd0, a11, 8'd0, b11);   // cycle 3
            feed(8'd0, 8'd0, 8'd0, 8'd0); // cycle 4 (flush)
            @(posedge clk); #1;           // edge 4: last accumulate lands
            check(a00*b00 + a01*b10, a00*b01 + a01*b11,
                  a10*b00 + a11*b10, a10*b01 + a11*b11);
        end
    endtask

    initial begin
        $dumpfile("systolic_array.vcd");
        $dumpvars(0, tb_systolic_array_2x2);

        errors = 0; cycle = 0;
        rst = 1; a0_in = 0; a1_in = 0; b0_in = 0; b1_in = 0;

        $display("-----------------------------------------------------");
        $display("Test 1: A=[[1,2],[3,4]]  B=[[5,6],[7,8]]  expect [[19,22],[43,50]]");
        run_matmul(1,2,3,4, 5,6,7,8);

        $display("Test 2: A=[[10,20],[30,40]]  B=[[50,60],[70,80]]");
        run_matmul(10,20,30,40, 50,60,70,80);

        $display("Test 3: identity  A=[[1,0],[0,1]]  B=[[9,8],[7,6]]");
        run_matmul(1,0,0,1, 9,8,7,6);

        $display("-----------------------------------------------------");
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $display("-----------------------------------------------------");
        $finish;
    end

endmodule

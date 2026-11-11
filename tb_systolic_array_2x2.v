module tb_systolic_array_2x2;

    reg        clk = 0;
    reg        rst = 1;
    reg  [7:0] a0_in = 0, a1_in = 0, b0_in = 0, b1_in = 0;
    wire [15:0] c00, c01, c10, c11;

    systolic_array_2x2 uut (
        .clk(clk), .rst(rst),
        .a0_in(a0_in), .a1_in(a1_in), .b0_in(b0_in), .b1_in(b1_in),
        .c00(c00), .c01(c01), .c10(c10), .c11(c11)
    );

    always #5 clk = ~clk;

    // Inputs change on the falling edge, PEs sample on the rising edge
    task feed(input [7:0] a0, a1, b0, b1);
        begin
            @(negedge clk);
            a0_in = a0; a1_in = a1; b0_in = b0; b1_in = b1;
        end
    endtask

    initial begin
        $dumpfile("systolic_array.vcd");
        $dumpvars(0, tb_systolic_array_2x2);

        repeat (2) @(negedge clk);
        rst = 0;

        // Row 1 of A and column 1 of B are skewed by one cycle
        feed(8'd1, 8'd0, 8'd5, 8'd0);
        feed(8'd2, 8'd3, 8'd7, 8'd6);
        feed(8'd0, 8'd4, 8'd0, 8'd8);
        feed(8'd0, 8'd0, 8'd0, 8'd0);
        @(posedge clk); #1;

        $display("C = [ %0d %0d ; %0d %0d ]", c00, c01, c10, c11);
        if (c00 == 19 && c01 == 22 && c10 == 43 && c11 == 50)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule

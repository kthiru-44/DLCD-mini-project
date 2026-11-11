module systolic_array_2x2 (
    input         clk,
    input         rst,
    input  [7:0]  a0_in,
    input  [7:0]  a1_in,
    input  [7:0]  b0_in,
    input  [7:0]  b1_in,
    output [15:0] c00,
    output [15:0] c01,
    output [15:0] c10,
    output [15:0] c11
);

    wire [7:0] a00_to_01, a10_to_11;
    wire [7:0] b00_to_10, b01_to_11;
    wire [7:0] unused_a01, unused_a11, unused_b10, unused_b11;

    pe PE00 (.clk(clk), .rst(rst), .a_in(a0_in),     .b_in(b0_in),
             .a_out(a00_to_01), .b_out(b00_to_10), .c_out(c00));

    pe PE01 (.clk(clk), .rst(rst), .a_in(a00_to_01), .b_in(b1_in),
             .a_out(unused_a01), .b_out(b01_to_11), .c_out(c01));

    pe PE10 (.clk(clk), .rst(rst), .a_in(a1_in),     .b_in(b00_to_10),
             .a_out(a10_to_11), .b_out(unused_b10), .c_out(c10));

    pe PE11 (.clk(clk), .rst(rst), .a_in(a10_to_11), .b_in(b01_to_11),
             .a_out(unused_a11), .b_out(unused_b11), .c_out(c11));

endmodule

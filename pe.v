// Processing Element (PE) for Systolic Array
// Performs: c_out = c_out + (a_in * b_in)
// Passes:   a_out <= a_in,  b_out <= b_in
module pe (
    input clk,
    input rst,
    input [7:0] a_in,
    input [7:0] b_in,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
    output reg [15:0] c_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out <= 8'd0;
            b_out <= 8'd0;
            c_out <= 16'd0;
        end else begin
            // Pass inputs to neighboring PEs on clock edge
            a_out <= a_in;
            b_out <= b_in;
            // Multiply and accumulate
            c_out <= c_out + (a_in * b_in);
        end
    end

endmodule

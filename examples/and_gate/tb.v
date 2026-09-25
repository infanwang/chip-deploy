`timescale 1ns/1ps
module tb;
    reg a, b;
    wire y;

    top dut(.a(a), .b(b), .y(y));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
        a=0; b=0; #10; $display("a=%b b=%b y=%b", a, b, y);
        a=0; b=1; #10; $display("a=%b b=%b y=%b", a, b, y);
        a=1; b=0; #10; $display("a=%b b=%b y=%b", a, b, y);
        a=1; b=1; #10; $display("a=%b b=%b y=%b", a, b, y);
        $finish;
    end
endmodule

module spm (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output reg  [15:0] product,
    output reg         done
);
    reg [2:0]  bit_cnt;
    reg [7:0]  a_reg;
    reg [15:0] acc;
    reg        running;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 3'd0;
            a_reg   <= 8'd0;
            acc     <= 16'd0;
            product <= 16'd0;
            done    <= 1'b0;
            running <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start && !running) begin
                a_reg   <= a;
                acc     <= {8'd0, b};
                bit_cnt <= 3'd0;
                running <= 1'b1;
            end else if (running) begin
                if (a_reg[0])
                    acc <= acc + ({8'd0, b} << bit_cnt);
                a_reg <= {1'b0, a_reg[7:1]};
                if (bit_cnt == 3'd7) begin
                    product <= a_reg[0] ? acc + ({8'd0, b} << 3'd7) : acc;
                    running <= 1'b0;
                    done    <= 1'b1;
                end else
                    bit_cnt <= bit_cnt + 3'd1;
            end
        end
    end
endmodule

`timescale 1ns / 1ps

module Counter_10000_ (
    input clk,
    input reset,
    input [1:0] sw,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire o_clk, w_cl, w_re, w_m_cl; 
    wire [5:0] w_sec, w_m;

    counter_10000 U_C_10000 (
        .clk(o_clk),
        .reset(w_re),
        .m_clk(w_m_cl),
        .count_data(w_sec)
    );

    clk_div_10000 U_Clk_div (
        .clk  (w_cl),
        .reset(w_re),
        .o_clk(o_clk)
    );

    m_counter U_M_COUNTER(
        .m_clk(w_m_cl),
        .reset(reset),
        .m_counter(w_m)
    );

    fnd_controller U_FND (
        .clk(clk),
        .reset(reset),
        .m(w_m),
        .s(w_sec),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    assign w_cl = clk & sw[0];
    assign w_re = reset | sw[1];
endmodule

module counter_10000 (
    input clk,
    input reset,
    output reg m_clk,
    output reg [5:0] count_data
);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_data <= 0;
            m_clk <= 0;
        end else begin
            if (count_data == 60 - 1) begin
                count_data <= 0;
                m_clk <= 1;
            end else begin
                count_data <= count_data + 1;
                m_clk <= 0;
            end
        end
    end
endmodule

module m_counter (
    input m_clk,
    input reset,
    output reg [5:0] m_counter
);

    always @(posedge m_clk, posedge reset) begin
        if (reset) begin
            m_counter <= 0;
        end else begin
            if(m_counter == 60 - 1) begin
                m_counter <= 0;
            end
            else begin
                m_counter <= m_counter + 1;
            end
        end
    end
endmodule


module clk_div_10000 (
    input  clk,
    input  reset,
    output o_clk
);
    parameter F_COUNT = 1_000_000;
    reg [$clog2(F_COUNT) - 1:0] r_count;
    reg r_clk;
    assign o_clk = r_clk;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_count <= 0;
            r_clk   <= 1'b0;
        end else begin
            if (r_count == F_COUNT - 1) begin
                r_clk   <= 1'b1;
                r_count <= 0;
            end else if (r_count >= F_COUNT / 2) begin
                r_clk   <= 1'b0;
                r_count <= r_count + 1;
            end else begin
                r_count <= r_count + 1;
            end
        end
    end

endmodule

`timescale 1ns / 1ps

module Top_Watch (
    input clk,
    input rst,
    input [1:0] sw,
    input [3:0] btn,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [2:0] led
);
    wire [3:0] w_btn, w_stop_w_btn, w_watch_btn;
    wire [6:0] w_stop_w_msec, w_watch_msec;
    wire [5:0] w_stop_w_sec, w_watch_sec, w_stop_w_min, w_watch_min;
    wire [4:0] w_stop_w_hour, w_watch_hour;
    wire [6:0] w_o_time_msec;
    wire [5:0] w_o_time_sec, w_o_time_min;
    wire [4:0] w_o_time_hour;
    wire [1:0] w_led;

    btn_debounce U_DEBOUNCE_U (
        .i_btn(btn[0]),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn[0])
    );

    btn_debounce U_DEBOUNCE_D (
        .i_btn(btn[3]),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn[3])
    );

    btn_debounce U_DEBOUNCE_L (
        .i_btn(btn[1]),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn[1])
    );

    btn_debounce U_DEBOUNCE_R (
        .i_btn(btn[2]),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn[2])
    );

    btn_demux_1x2 U_BTN_DEMUX (
        .sw(sw[1]),
        .btn(w_btn),
        .i_led(w_led),
        .stop_w_btn(w_stop_w_btn),
        .watch_btn(w_watch_btn),
        .led(led)
    );

    stop_watch U_STOP_WATCH (
        .clk(clk),
        .rst(rst),
        .sw(sw[0]),
        .btnL_Clear(w_stop_w_btn[1]),
        .btnR_RunStop(w_stop_w_btn[2]),
        .msec(w_stop_w_msec),
        .sec(w_stop_w_sec),
        .min(w_stop_w_min),
        .hour(w_stop_w_hour)
    );

    watch U_WATCH (
        .clk(clk),
        .rst(rst),
        .sw(sw[0]),
        .btn(w_watch_btn),
        .msec(w_watch_msec),
        .sec(w_watch_sec),
        .min(w_watch_min),
        .hour(w_watch_hour),
        .o_led(w_led)
    );

    watch_mode_mux U_WATCH_MUX (
        .sw(sw[1]),
        .stop_w_msec(w_stop_w_msec),
        .stop_w_sec(w_stop_w_sec),
        .stop_w_min(w_stop_w_min),
        .stop_w_hour(w_stop_w_hour),
        .watch_msec(w_watch_msec),
        .watch_sec(w_watch_sec),
        .watch_min(w_watch_min),
        .watch_hour(w_watch_hour),
        .o_msec(w_o_time_msec),
        .o_sec(w_o_time_sec),
        .o_min(w_o_time_min),
        .o_hour(w_o_time_hour)
    );

    fnd_controller U_FND (
        .clk(clk),
        .reset(rst),
        .sw(sw[0]),
        .msec(w_o_time_msec),
        .sec(w_o_time_sec),
        .min(w_o_time_min),
        .hour(w_o_time_hour),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );
endmodule

module watch_mode_mux (
    input            sw,
    input      [6:0] stop_w_msec,
    input      [5:0] stop_w_sec,
    input      [5:0] stop_w_min,
    input      [4:0] stop_w_hour,
    input      [6:0] watch_msec,
    input      [5:0] watch_sec,
    input      [5:0] watch_min,
    input      [4:0] watch_hour,
    output reg [6:0] o_msec,
    output reg [5:0] o_sec,
    output reg [5:0] o_min,
    output reg [4:0] o_hour
);

    always @(*) begin
        case (sw)
            0: begin
                o_msec = watch_msec;
                o_sec  = watch_sec;
                o_min  = watch_min;
                o_hour = watch_hour;
            end
            1: begin
                o_msec = stop_w_msec;
                o_sec  = stop_w_sec;
                o_min  = stop_w_min;
                o_hour = stop_w_hour;
            end
            default: begin
                o_msec = watch_msec;
                o_sec  = watch_sec;
                o_min  = watch_min;
                o_hour = watch_hour;
            end
        endcase
    end
endmodule

module btn_demux_1x2 (
    input            sw,
    input      [2:0] i_led,
    input      [3:0] btn,
    output reg [3:0] stop_w_btn,
    output reg [3:0] watch_btn,
    output reg [3:0] led
);
    always @(*) begin
        watch_btn  = 4'b0000;
        stop_w_btn = 4'b0000;
        case (sw)
            0: begin
                watch_btn = btn;
                stop_w_btn = 4'b0000;
                led = {1'b0,i_led};
            end
            1: begin
                stop_w_btn = btn;
                watch_btn = 4'b0000;
                led = 3'b100;
            end
        endcase
    end
endmodule

module showtime(   
    input clk,
    input reset, 
    input reg_N,
    input [6:0] wait_time,  // 等待时间（暂时未使用）
    input [4:0] hours,      // 当前小时 (默认值)
    input [5:0] minutes,    // 当前分钟 (默认值)
    input [5:0] seconds,    // 当前秒钟 (默认值)
    input [6:0] work_limit, // 工作时间限制（暂时未使用）
    input power_state, 
    input [3:0] mode_state, // 模式状态（暂时未使用）
    input down,             // 按下下键，用于查询模式下切换显示
    output reg [3:0] an,    // 片选信号
    output reg [3:0] an2,   // 第二组片选信号
    output reg [7:0] sseg,  // 段选信号
    output reg [7:0] sseg2  // 第二组段选信号
);
    localparam  OFF = 1'b0,
                ON = 1'b1,
                WAITING = 1'b0,
                WORKING = 1'b1,
                MUNU = 4'b0000,
                LOW_GEAR = 4'b0001,        // 一档模式
                MID_GEAR = 4'b0010,        // 二档模式
                HIGH_GEAR = 4'b0011,       // 三档模式
                AUTO_CLEAN = 4'b0100,      // 自动清洁模式
                MANUAL_CLEAN = 4'b0101,    // 手动清洁模式
                QUERY = 4'b0110,           // 查询模式
                SET_CURRENT_TIME = 4'b0111,// 设置当前时间模式
                SET_REMINDER_TIME = 4'b1000, // 设置提醒时间模式
                SET_GESTURE_TIME = 4'b1001;  // 设置手势时间模式

    // 绑定 hex 数值（将小时、分钟、秒钟拆分为个位和十位数）
    wire [3:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
    
    // 将时间按位分割为十位和个位，方便显示在数码管上
    assign hex0 = seconds % 10;      // 秒钟个位
    assign hex1 = seconds / 10;      // 秒钟十位
    assign hex2 = minutes % 10;      // 分钟个位
    assign hex3 = minutes / 10;      // 分钟十位
    assign hex4 = hours % 10;        // 小时个位
    assign hex5 = hours / 10;        // 小时十位

    localparam N = 18; // 时钟分频系数
    reg [3:0] hex_in, hex_in2; // 用于选择显示的数字
    reg [3:0] hex6_in, hex7_in; // 用于选择显示hex6和hex7的数字
    
    // 根据模式状态控制hex6和hex7的显示
    always@* begin
        if (power_state == ON) begin // 仅在power_state为ON时才控制显示
            case(mode_state)
                SET_REMINDER_TIME: begin
                    hex6_in = work_limit % 10;
                    hex7_in = work_limit / 10;
                end
                SET_GESTURE_TIME: begin
                    hex6_in = wait_time % 10;
                    hex7_in = wait_time / 10;
                end
                QUERY: begin
                    if(down) begin
                        hex6_in = wait_time % 10;
                        hex7_in = wait_time / 10;
                    end else begin
                        hex6_in = work_limit % 10;
                        hex7_in = work_limit / 10;
                    end
                end
                default: begin
                    hex6_in = 4'b1111;
                    hex7_in = 4'b1111;
                end
            endcase
        end else begin
            hex6_in = 4'b1111; // power_state为OFF时不显示
            hex7_in = 4'b1111; // power_state为OFF时不显示
        end
    end
    
    // 控制第一组数码管（显示秒钟和分钟）
    always@* begin
        if (power_state == ON) begin // 仅在power_state为ON时才更新显示
            case(regN[N-1:N-2])
                2'b00: begin
                    an = 4'b1110; // 选中第1个数码管
                    hex_in = hex0; // 显示秒钟个位
                end
                2'b01: begin
                    an = 4'b1101; // 选中第二个数码管
                    hex_in = hex1; // 显示秒钟十位
                end
                2'b10: begin
                    an = 4'b1011; // 选中第三个数码管
                    hex_in = hex2; // 显示分钟个位
                end
                default: begin
                    an = 4'b0111; // 选中第四个数码管
                    hex_in = hex3; // 显示分钟十位
                end
            endcase
        end else begin
            an = 4'b1111; // power_state为OFF时不显示
            hex_in = 4'b1111; // power_state为OFF时不显示
        end
    end
    
    // 控制第二组数码管（显示小时和工作时间）
    always@* begin
        if (power_state == ON) begin // 仅在power_state为ON时才更新显示
            case(regN[N-1:N-2])
                2'b00: begin
                    an2 = 4'b1110; // 选中第1个数码管
                    hex_in2 = hex4; // 显示小时个位
                end
                2'b01: begin
                    an2 = 4'b1101; // 选中第二个数码管
                    hex_in2 = hex5; // 显示小时十位
                end
                2'b10: begin
                    an2 = 4'b1011; // 选中第三个数码管
                    hex_in2 = hex6_in; // 显示设置提醒时间或手势时间的个位
                end
                2'b11: begin
                    an2 = 4'b0111; // 选中第四个数码管
                    hex_in2 = hex7_in; // 显示设置提醒时间或手势时间的十位
                end
                default: begin
                    an2 = 4'b1111; // 不显示
                    hex_in2 = 4'b1111; // 不显示
                end
            endcase
        end else begin
            an2 = 4'b1111; // power_state为OFF时不显示
            hex_in2 = 4'b1111; // power_state为OFF时不显示
        end
    end
    
    // 控制第一个数码管组的显示
    always@* begin
        if (power_state == ON) begin // 仅在power_state为ON时才更新显示
            case(hex_in)
                4'h0: sseg[6:0] = 7'b0000001; // 显示 0
                4'h1: sseg[6:0] = 7'b1001111; // 显示 1
                4'h2: sseg[6:0] = 7'b0010010; // 显示 2
                4'h3: sseg[6:0] = 7'b0000110; // 显示 3
                4'h4: sseg[6:0] = 7'b1001100; // 显示 4
                4'h5: sseg[6:0] = 7'b0100100; // 显示 5
                4'h6: sseg[6:0] = 7'b0100000; // 显示 6
                4'h7: sseg[6:0] = 7'b0001111; // 显示 7
                4'h8: sseg[6:0] = 7'b0000010; // 显示 8
                4'h9: sseg[6:0] = 7'b0000100; // 显示 9
                default: sseg[6:0] = 7'b0111000; // 显示默认值
            endcase
        end else begin
            sseg[6:0] = 7'b1111111; // power_state为OFF时不显示
        end
    end
    
    // 控制第二个数码管组的显示
    always@* begin
        if (power_state == ON) begin // 仅在power_state为ON时才更新显示
            case(hex_in2)
                4'h0: sseg2[6:0] = 7'b0000001; // 显示 0
                4'h1: sseg2[6:0] = 7'b1001111; // 显示 1
                4'h2: sseg2[6:0] = 7'b0010010; // 显示 2
                4'h3: sseg2[6:0] = 7'b0000110; // 显示 3
                4'h4: sseg2[6:0] = 7'b1001100; // 显示 4
                4'h5: sseg2[6:0] = 7'b0100100; // 显示 5
                4'h6: sseg2[6:0] = 7'b0100000; // 显示 6
                4'h7: sseg2[6:0] = 7'b0001111; // 显示 7
                4'h8: sseg2[6:0] = 7'b0000010; // 显示 8
                4'h9: sseg2[6:0] = 7'b0000100; // 显示 9
                default: sseg2[6:0] = 7'b0111000; // 显示默认值
            endcase
        end else begin
            sseg2[6:0] = 7'b1111111; // power_state为OFF时不显示
        end
    end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 公司: 
// 工程师: 
// 
// 创建日期: 2024/11/25 18:48:30
// 设计名称: 
// 模块名称: gesture_switch
// 项目名称: 
// 目标设备: 
// 工具版本: 
// 描述: 组合手势开关与电源按键控制模块
// 
// 依赖项: 
// 
// 修订:
// 修订 0.01 - 文件创建
// 其他备注:
// 
//////////////////////////////////////////////////////////////////////////////////

module gesture_switch (
    input wire clk,              
    input wire reset,           
    input wire left_key,         
    input wire right_key,         
    input wire middle_key,        
    input wire up_key,            
    input wire down_key,        
    output reg power_state,
    output reg [3:0]mode_state,
    output reg light,
    output reg done,
    output reg clean_reminder,
    output wire beep,
    output reg showtime     
);
    localparam  OFF = 1'b0,
                ON = 1'b1,
                      QUERY_WORKTIME=2'b01,
                      QUERY_GESTURE_TIME=2'b10,
                      SETTING_TIME_NOW=2'b01,
                      SETTING_REMINDER_TIME=2'b10,
                      SETTING_GESTURE_TIME=2'b11,
                      WAITING = 1'b0,
                      WORKING = 1'b1,
                      MENU = 4'b0000,
                      CONTINUE = 4'b1010, 
                      BACK = 4'b1011,     
                      LOW_GEAR = 4'b0001,
                      MID_GEAR = 4'b0010, 
                      HIGH_GEAR = 4'b0011, 
                      AUTO_CLEAN = 4'b0100, 
                      QUERY = 4'b0110,   
                      SETTING = 4'b0111; 
    reg [1:0] query_state;
    reg [1:0] setting_state; 
    reg [5:0] music_select;
    reg middlebutton;
    reg leftbutton;
    reg rightbutton;
    reg upbutton;
    reg downbutton;
    reg [63:0]gesture_time;
    reg [63:0]clean_time;
    reg [63:0]back_time;
    reg [63:0]high_time;
    reg [63:0]reminder_time;
    reg [63:0]time_now;
    reg [63:0]work_timer;
    reg askclose;
    reg askopen;
    reg cleaning;
    reg backing;
    reg highing;
    reg [63:0] query_timer;
    reg [63:0] middle_key_timer;     
    reg [63:0] up_key_timer;      
    reg [63:0] down_key_timer;    
    reg [63:0] left_key_timer;      
    reg [63:0] right_key_timer;     
    reg [63:0] close_timer;     
    reg [63:0] open_timer;     
    reg [63:0] clean_timer;     
    reg [63:0] high_timer;     
    reg [63:0] back_timer;     
    reg counting_prev;
    reg replay1;
    reg replay2;
    reg replay3;
    reg replay4;
    reg replay5;
    reg replay6;
    reg state_pre;
    initial begin
        gesture_time=63'd5000;
        clean_time=63'd5000;
        back_time=63'd5000;
        high_time=63'd5000;
        reminder_time=63'd10000;
        time_now=1'd0;
        power_state = 1'b0;          
        mode_state = MENU;         
        done=1'b0;
        middlebutton=1'b0;
        leftbutton=1'b0;
        rightbutton=1'b0;
        upbutton=1'b0;
        downbutton=1'b0;
        askclose=1'b0;
        askopen=1'b0;
        cleaning=1'b0;
        backing=1'b0;
        highing=1'b0;
        close_timer=1'b0;     
        open_timer=1'b0;     
        clean_timer=1'b0;     
        high_timer=1'b0;     
        back_timer=1'b0;
        work_timer=1'b0;
        query_state=2'b00;  
        query_timer=0;  
        setting_state=2'b00;
        music_select= 6'b000001;
        replay1 = 0;
        replay2 = 0;
        replay3= 0;
        replay4= 0;
        replay5= 0;
        replay6= 0;
        state_pre = 4'b1111;
    end

    always @(posedge clk or posedge reset) begin
    if(reset)begin 
    music_select =6'b000001;
    end else begin if(~(state_pre == mode_state))begin
        case (mode_state)
            MENU: begin
                music_select<= 6'b000001;
                replay1 <= 1;
            end
            LOW_GEAR: begin
                music_select= 6'b000010;
                replay2 <= 1;
            end
            MID_GEAR: begin
                music_select= 6'b000100;
                replay3 <= 1;
            end
            HIGH_GEAR: begin
                music_select= 6'b001000;
                replay4 <= 1;
            end
            AUTO_CLEAN: begin
                music_select= 6'b010000;
                replay5 <= 1;
            end
            default: begin
                music_select =6'b000000;
            end
    endcase
    end
    state_pre <= mode_state;
    end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
                gesture_time=63'd5000;
        clean_time=63'd5000;
        back_time=63'd5000;
        high_time=63'd5000;
        reminder_time=63'd10000;
        time_now=1'd0;
                 power_state = 1'b0;          
               mode_state = MENU;         
               done=1'b0;
               middlebutton=1'b0;
               leftbutton=1'b0;
               rightbutton=1'b0;
               upbutton=1'b0;
               downbutton=1'b0;
               askclose=1'b0;
               askopen=1'b0;
               cleaning=1'b0;
               backing=1'b0;
               highing=1'b0;
               close_timer=1'b0;     
               open_timer=1'b0;     
               clean_timer=1'b0;     
               high_timer=1'b0;     
               back_timer=1'b0;
               work_timer=1'b0;   
               query_state=2'b00;
               query_timer=0;   
               setting_state=2'b00;  
        end else begin
            time_now<=time_now+1;
            if(query_timer<15'd3000)begin
            if(query_state==2'b01)
            begin
            query_timer<=query_timer+1;
            showtime<=work_timer;
            end else if(query_state==2'b10)
            begin
            query_timer<=query_timer+1;
            showtime<=gesture_time;
            end else begin
            showtime<=time_now;
            end
            end
            else 
            begin
            showtime<=time_now;
            if(query_state!=2'b00)begin
            query_timer<=1'b0;
            query_state<=2'b00;
            mode_state<=MENU;
            end
            end
            if(power_state==1'b1)
            if(mode_state==LOW_GEAR||mode_state==MID_GEAR||mode_state==HIGH_GEAR)
            begin
                    work_timer<=work_timer+1;
            end
            if(power_state==1'b1) begin
            if(work_timer>reminder_time)
            begin
            clean_reminder<=1;
            end else begin
            clean_reminder<=0;
            end
            end else begin
                clean_reminder<=0;
            end
            
            if(askclose&&close_timer<gesture_time)
            begin
            close_timer<=close_timer+1;
            end else begin
            close_timer<=0;
            askclose<=0;
            end
            
            if(askopen&&open_timer<gesture_time)
                        begin
                        open_timer<=open_timer+1;
                        end else begin
                        open_timer<=0;
                  askopen<=0;
            end
            if(cleaning&&clean_timer<clean_time)
                        begin
                        clean_timer<=clean_timer+1;
                     end else if(cleaning)
                     begin
                     cleaning<=0;
                     clean_timer<=0;
                     mode_state<=MENU;
             end
             if(backing&&back_timer<back_time)
                                     begin
                                     back_timer<=back_timer+1;
                                  end else if(backing)begin
                                  backing<=0;
                                  back_timer<=0;
                     mode_state<=MENU;
             end
             if(highing&&high_timer<high_time)
                                     begin
                                     high_timer<=high_timer+1;
                                  end else if(highing&&~backing) begin
                         highing<=0;
                         high_timer<=0;
                       mode_state<=MENU;
              end
            if (middle_key) begin
                middle_key_timer <= middle_key_timer + 1;
            end else begin
                middle_key_timer <= 0;  
                middlebutton<=0;
            end
            if (left_key) begin
                            left_key_timer <= left_key_timer + 1;
                        end else begin
                            left_key_timer <= 0;  
                            leftbutton<=0;
            end
            if (right_key) begin
                            right_key_timer <= right_key_timer + 1;
                        end else begin
                            right_key_timer <= 0; 
                            rightbutton<=0;
            end
            if (up_key) begin
                            up_key_timer <= up_key_timer + 1;
                        end else begin
                            up_key_timer <= 0; 
                            upbutton<=0;
            end
            if (down_key) begin
                            down_key_timer <= down_key_timer + 1;
                        end else begin
                            down_key_timer <= 0;  
                            downbutton<=0;
            end            
            if (middle_key_timer > 0 && middle_key_timer < 3000)begin
            if(~middlebutton) begin
            if(power_state==1'b0)
            begin
                power_state <= 1;
            end else if (mode_state == MENU || mode_state == CONTINUE) begin
                     mode_state <= CONTINUE;
                     askopen<=0;askclose<=0;
             end else if(mode_state==HIGH_GEAR)
             begin
                  mode_state = BACK;      
                  backing<=1'b1;
                  highing<=1'b0;
                  high_timer<=1'b0;
             end else if(mode_state!=BACK)
             begin
                   setting_state<=2'b00;
                   mode_state <= MENU;
             end 
             middlebutton<=1;
             end
             end else if (middle_key_timer >= 3000) begin
                 power_state <= 0; 
                 done<=0;
                 music_select <= 6'b100000;
                 replay6 <= 1;
                 light <= OFF;   
                 mode_state <= MENU;        
            end
           
            if(power_state==1'b1)begin
            if (left_key_timer > 0 && left_key_timer < 1000)
                      begin
                           if(mode_state==SETTING&&~leftbutton)
                           begin
                           leftbutton<=1;
                           setting_state<=2'b10;
                           end else
                           if(askclose&&~leftbutton)
                           begin
                           leftbutton<=1;
                           power_state <= 0; 
                           done <=0;
                           light <= OFF;   
                           mode_state <= MENU;       
                           askclose<=0;
                       end
                end else
            if ((mode_state == CONTINUE || mode_state == MID_GEAR )&& (left_key_timer > 1000 && left_key_timer < 2000)) begin
                mode_state <= LOW_GEAR;
            end else if ((mode_state == CONTINUE || mode_state == LOW_GEAR )&& (left_key_timer > 2000 && left_key_timer < 3000)) begin
                mode_state <= MID_GEAR;
            end else if ((mode_state == CONTINUE || mode_state == LOW_GEAR || mode_state == MID_GEAR)&& (left_key_timer > 3000 && done == 1'b0)) begin
                mode_state <= HIGH_GEAR;
                done<=1'b1;
                highing<=1'b1;
            end
            end
            
            if(power_state==1'b1)begin
            if(down_key_timer > 0 && down_key_timer < 1000)
            begin
               if(!downbutton&&mode_state==QUERY&&query_state==2'b00)
               begin
               downbutton<=1;
               query_state<=2'b10;
               end else if(~downbutton&&mode_state==SETTING)
               begin
                         downbutton<=1'b1;
                         if(setting_state==2'b00)begin
                         setting_state<=2'b11;
                         end else if(setting_state==2'b01&&time_now>15'd1000)begin
                         time_now<=time_now-15'd1000;
                         end else if(setting_state==2'b10&&reminder_time>15'd1000)begin
                          reminder_time<=reminder_time-15'd1000;
                           end else if(setting_state==2'b11&&gesture_time>15'd1000)begin
                         gesture_time<=gesture_time-15'd1000;
                         end
               end
               else if(~downbutton)begin
               downbutton<=1;
               light<=~light;
               end 
            end 
            end
            
             if(power_state==1'b0)begin
                       if(left_key_timer > 0)
                                  begin
                                       askopen<=1;
                                  end 
                       end    
            if(power_state==1'b1)begin
                        if(right_key_timer > 0&&right_key_timer<1000)
                        begin
                           if(~rightbutton&&mode_state==CONTINUE)
                           begin
                           mode_state<=QUERY;
                           rightbutton<=1'b1;
                           end else if(~rightbutton)
                           begin
                           rightbutton<=1;
                           askclose<=1;
                           end
                        end  else
                         if (right_key_timer > 1000 && right_key_timer < 2000&&(mode_state==CONTINUE||mode_state==QUERY)) begin
                                 mode_state <= SETTING;
                         end 
                        
            end
            if(power_state==1'b0)begin
                       if(right_key_timer > 0)
                           begin
                               if(askopen)
                               begin
                               power_state <= 1; 
                               askopen<=0;
                               end 
                       end 
                   end            
            
             if(power_state==1'b1)begin
                 if(up_key_timer > 0 && up_key_timer < 1000)
                   begin
                          if(~upbutton&&mode_state==CONTINUE)begin
                          upbutton<=1'b1;
                          mode_state<=AUTO_CLEAN; 
                          cleaning<=1'b1;
                          end else if(~upbutton&&mode_state==QUERY&&query_state==2'b00)
                          begin
                          upbutton<=1'b1;
                          query_state<=2'b01;
                          end else if(~upbutton&&mode_state==SETTING)
                          begin
                                  upbutton<=1'b1;
                                  if(setting_state==2'b00)begin
                                  setting_state<=2'b01;
                                  end else if(setting_state==2'b01)begin
                                  time_now<=time_now+15'd1000;
                                  end else if(setting_state==2'b10)begin
                                   reminder_time<=reminder_time+15'd1000;
                                   end else if(setting_state==2'b11)begin
                                   gesture_time<=gesture_time+15'd1000;
                                   end
                          end
                   end else if(up_key_timer > 1000)
                   begin
                          cleaning<=0;
                          work_timer<=0;
                          mode_state<=MENU;
                   end
             end        
        end
    end
    start_display ustart_display(.clk(clk),.rst(reset),.beep(beep),.music_select(music_select[0]),.replay(replay1));
    state1_display ustate1_display(clk,reset,beep,music_select,replay2);
    state2_display ustate2_display(clk,reset,beep,music_select,replay3);
    state3_display ustate3_display(clk,reset,beep,music_select,replay4);
    turn_off_display uturn_off_dispaly(clk,reset,beep,music_select,replay5);
    alert_display ualert_display(clk,reset,beep,music_select,replay6);
endmodule

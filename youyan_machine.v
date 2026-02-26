`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/29 14:01:49
// Design Name: 
// Module Name: daiji
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module youyan_machine(
input clk,            
    input rst_n,         
    input raw_middle_key,    
    input raw_left_key,     
    input raw_right_key,  
    input raw_up_key,    
    input raw_down_key,     
      output reg standby_indicator,   
      output reg low_gear_indicator,    
      output reg mid_gear_indicator,    
      output reg high_gear_indicator,     
      output reg light_indicator,        
      output reg clean_reminder_indicator,
      output reg self_clean_indicator,   
      output reg query_indicator,       
      output reg current_time_indicator,   
      output reg reminder_time_indicator,
      output reg gesture_time_indicator, 
      output reg back_indicator,       
      output reg continue_indicator,       
      output reg power_indicator,         
            output wire [3:0] an,  
            output wire [3:0] an2,  
            output wire [7:0] sseg,  
            output wire [7:0] sseg2,
            output beep
);
  wire power_state;  
  wire could;
  wire working_state; 
  wire light;   
  wire [3:0] mode_state; 
  wire show_time;
  wire clean_reminder;
       

      localparam  OFF = 1'b0,
                  ON = 1'b1,
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
                  SET_HIGH_TIME = 4'b0111, 
                  SET_REMINDER_TIME = 4'b1000,
                  SET_GESTURE_TIME = 4'b1001;
wire middle_key;   
wire left_key;  
 wire right_key;  
wire up_key;    
 wire down_key;   

 button_debounce middle (.clk(clk),.rst_n(rst_n),.key_in(raw_middle_key),.key_out(middle_key));
 button_debounce left (.clk(clk),.rst_n(rst_n),.key_in(raw_left_key),.key_out(left_key));
 button_debounce right (.clk(clk),.rst_n(rst_n),.key_in(raw_right_key),.key_out(right_key));
 button_debounce up (.clk(clk),.rst_n(rst_n),.key_in(raw_up_key),.key_out(up_key));
 button_debounce down (.clk(clk),.rst_n(rst_n),.key_in(raw_down_key),.key_out(down_key));
  wire clk_1ms;
  clock_divider clock_div_inst (
      .clk_in(clk),
      .reset(rst_n),
      .clk_out(clk_1ms)
  ); 

    gesture_switch u_gesture_switch (
                  .clk(clk_1ms),
                  .reset(rst_n),             
                  .left_key(left_key),
                  .right_key(right_key),
                  .middle_key(middle_key),
                  .up_key(up_key),
                  .down_key(down_key),
                  .power_state(power_state),  
                  .mode_state(mode_state),
                  .light(light),
                  .clean_reminder(clean_reminder),
                  .showtime(show_time),
                  .beep(beep)
              );
//   showtime u_showtime (
//         .clk(clk),
//         .reset(~rst_n),        
//         .wait_time(wait_time), 
//         .hours(hours),          
//         .minutes(minutes),      
//         .seconds(seconds),     
//         .work_limit(work_limit),
//         .power_state(power_state), 
//         .mode_state(mode_state), 
//         .down(decrement_key),    
//         .an(an),                  
//         .an2(an2),                
//         .sseg(sseg),             
//         .sseg2(sseg2)           
//     );
     
 always @(*) begin
         case (power_state)
             OFF: begin
                 power_indicator = 1'b0;
                 standby_indicator = 1'b0;
                 low_gear_indicator = 1'b0;
                 mid_gear_indicator = 1'b0;
                 high_gear_indicator = 1'b0;
                 light_indicator = 1'b0;
                 clean_reminder_indicator = 1'b0;
                 self_clean_indicator = 1'b0;
                 query_indicator = 1'b0;
                 current_time_indicator = 1'b0;
                 reminder_time_indicator = 1'b0;
                 gesture_time_indicator = 1'b0;
                 back_indicator = 1'b0;
                 continue_indicator = 1'b0;
             end
             ON: begin
                 power_indicator = 1'b1;
                 standby_indicator = (mode_state == MENU) ? 1'b1 : 1'b0;
                 low_gear_indicator = (mode_state == LOW_GEAR) ? 1'b1 : 1'b0;
                 mid_gear_indicator = (mode_state == MID_GEAR) ? 1'b1 : 1'b0;
                 high_gear_indicator = (mode_state == HIGH_GEAR) ? 1'b1 : 1'b0;
                 light_indicator = (light == ON) ? 1'b1 : 1'b0;
                 self_clean_indicator = (mode_state == AUTO_CLEAN) ? 1'b1 : 1'b0;
                 query_indicator = (mode_state == QUERY) ? 1'b1 : 1'b0;
                 current_time_indicator = (mode_state == SET_HIGH_TIME) ? 1'b1 : 1'b0;
                 reminder_time_indicator = (mode_state == SET_REMINDER_TIME) ? 1'b1 : 1'b0;
                 gesture_time_indicator = (mode_state == SET_GESTURE_TIME) ? 1'b1 : 1'b0;
                 back_indicator = (mode_state == BACK ) ? 1'b1 : 1'b0;
                 continue_indicator = (mode_state == CONTINUE ) ? 1'b1 : 1'b0;
                 clean_reminder_indicator = (clean_reminder == 1'b1 ) ? 1'b1 : 1'b0;
                 
             end
           
         endcase
     end


endmodule

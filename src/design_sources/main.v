//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai, Tzu-Han Hsu
// 
// Create Date: 2018/12/11 16:04:41
// Design Name: 
// Module Name: lab9
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A circuit that show the animation of a fish swimming in a seabed
//              scene on a screen through the VGA interface of the Arty I/O card.
// 
// Dependencies: vga_sync, clk_divider, sram 
//
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module main(
    input  clk,
    input  reset_n,
    input  SW0,
    input  [3:0] usr_btn,
    output reg [3:0] usr_led,
    
    // VGA specific I/O ports
    output VGA_HSYNC,
    output VGA_VSYNC,
    output [3:0] VGA_RED,
    output [3:0] VGA_GREEN,
    output [3:0] VGA_BLUE
    );

//define button logics
wire [3:0] btn_level;
reg [3:0] prev_btn_level;
wire [3:0] btn_pressed;

debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[0]),
  .btn_output(btn_level[0])
  );

debounce btn_db1(
.clk(clk),
.btn_input(usr_btn[1]),
.btn_output(btn_level[1])
);

debounce btn_db2(
.clk(clk),
.btn_input(usr_btn[2]),
.btn_output(btn_level[2])
);

debounce btn_db3(
.clk(clk),
.btn_input(usr_btn[3]),
.btn_output(btn_level[3])
);

always @(posedge clk) begin
    if (~reset_n)
        prev_btn_level <= 4'b1111;
    else
        prev_btn_level <= btn_level;
end

assign btn_pressed[0] = (btn_level[0] == 1 && prev_btn_level[0] == 0);
assign btn_pressed[1] = (btn_level[1] == 1 && prev_btn_level[1] == 0);
assign btn_pressed[2] = (btn_level[2] == 1 && prev_btn_level[2] == 0);
assign btn_pressed[3] = (btn_level[3] == 1 && prev_btn_level[3] == 0);


//declare region judgement variables
wire s0p1_region;
wire s0p2_region;
wire s0p3_region;

wire s1snake_region;
wire s1l1_region;
wire s1l2_region;
wire s1l3_region;

wire s1v1_region;
wire s1v2_region;
wire s1v3_region;

wire s1lv1s_region;
wire s1lv2s_region;
wire s1lv3s_region;

wire s1b1_region;
wire s1b2_region;
wire s1b3_region;
wire s1b4_region;
wire s1b1i_region;
wire s1b2i_region;
wire s1b3i_region;
wire s1b4i_region;

wire s2game_region;

wire s2clki_region;
wire s2sci_region;

wire s2heart_region;
wire s2health_region;
wire s2healthb_region;

wire s2_clknum1_region;
wire s2_clkdot_region;
wire s2_clknum2_region;
wire s2_clknum3_region;

wire s2_scnum1_region;
wire s2_scnum2_region;
wire s2_scnum3_region;


wire s4_again_region;
wire s4_agains_region;
wire s4_menu_region;
wire s4_menus_region;

wire s4_score_region;
wire s4_sc1_region;
wire s4_sc2_region;
wire s4_sc3_region;


// General VGA control signals
wire vga_clk;         // 50MHz clock for VGA control
wire video_on;        // when video_on is 0, the VGA controller is sending
                      // synchronization signals to the display device.
  
wire pixel_tick;      // when pixel tick is 1, we must update the RGB value
                      // based for the new coordinate (pixel_x, pixel_y)

wire [9:0] pixel_x;   // x coordinate of the next pixel (between 0 ~ 639) 
wire [9:0] pixel_y;   // y coordinate of the next pixel (between 0 ~ 479)
  
reg  [11:0] rgb_reg;  // RGB value for the current pixel
reg  [11:0] rgb_next; // RGB value for the next pixel
  

// Declare the video buffer size
localparam VBUF_W = 320; // video buffer width
localparam VBUF_H = 240; // video buffer height

// Set parameters for the fish images
localparam S0P1_VPOS   = 10; // Vertical location of the fish in the sea image.
localparam S0P1_HPOS   = 30; // Horizontal location of the fish in the sea image.
localparam S0P1_W      = 100; // Width of the fish.
localparam S0P1_H      = 30; // Height of the fish.

localparam S0P2_VPOS   = 40; 
localparam S0P2_HPOS   = 55; 
localparam S0P2_W      = 50; 
localparam S0P2_H      = 50; 

localparam S0P3_VPOS   = 100; 
localparam S0P3_HPOS   = 17; 
localparam S0P3_W      = 125; 
localparam S0P3_H      = 15; 

localparam s1snake_HPOS = 147;
localparam s1snake_VPOS = 5;

localparam S1l_HPOS = 100;
localparam S1lv1_VPOS = 75;
localparam S1lv2_VPOS = 115;
localparam S1lv3_VPOS = 155;
localparam S1v_HPOS = 230;

localparam S1lvs_HPOS = 120;
localparam S1lv1s_VPOS = 165;//50*2+15
localparam S1lv2s_VPOS = 245;
localparam S1lv3s_VPOS = 325;

localparam S1b_VPOS = 228;

localparam S1b4_HPOS = 12;
localparam S1b2i_HPOS = 67;
localparam S1b3_HPOS = 89;
localparam S1b4i_HPOS = 144;
localparam S1b2_HPOS = 166;
localparam S1b1i_HPOS = 221;
localparam S1b1_HPOS = 243;
localparam S1b3i_HPOS = 298;


localparam S2game_VPOS = 75;
localparam S2game_HPOS = 35;

localparam S2i_VPOS = 2;
localparam S2clki_HPOS = 38;
localparam S2sci_HPOS = 230;
localparam S2heart_HPOS = 150;

localparam S2num_VPOS = 30;

localparam S2clknum1_HPOS = 14;
localparam S2clkdot_HPOS = 35;
localparam S2clknum2_HPOS = 49;
localparam S2clknum3_HPOS = 69;

localparam S2scnum1_HPOS = 242;
localparam S2scnum2_HPOS = 262;
localparam S2scnum3_HPOS = 282;

localparam S2health_VPOS = 40;
localparam S2health_HPOS = 120;


localparam S4again_VPOS = 310;
localparam S4again_HPOS = 240;

localparam S4agains_VPOS = 320;
localparam S4agains_HPOS = 170;


localparam S4menu_VPOS = 370;
localparam S4menu_HPOS = 240;

localparam S4menus_VPOS = 380;
localparam S4menus_HPOS = 170;


localparam S4score_VPOS = 15;
localparam S4score_HPOS = 120;

localparam S4sc_VPOS = 30;
localparam S4sc1_HPOS = 52;
localparam S4sc2_HPOS = 72;
localparam S4sc3_HPOS = 92;

// main State machine
reg [3:0] last_state;
reg [3:0] current_state;
reg [3:0] next_state;

localparam S0 = 0;//press any btn
localparam S1 = 1;//select level

localparam SPP = 2;
localparam SL1 = 3;
localparam SL2 = 4;
localparam SL3 = 5;

localparam S2 = 6;//gaming
localparam S4 = 7;//end_game


// a level selection round coutner
reg [2:0]s1_level_counter;
always @(posedge clk ) begin
  if(~reset_n || current_state == S0) s1_level_counter <= 1;
  else if(current_state == S1 && btn_pressed[1])
    s1_level_counter <= (s1_level_counter == 1)?3:s1_level_counter-1;
  else if(current_state == S1 && btn_pressed[2])
    s1_level_counter <= (s1_level_counter==3)?1:s1_level_counter +1;
end

//s4 level selection counter
reg s4_selection_counter;
always @(posedge clk ) begin
  if(~reset_n || current_state ==SPP) s4_selection_counter <= 0;//ingameplay
  else if(current_state == S4 && (btn_pressed[1] || btn_pressed[2])) s4_selection_counter =  ~s4_selection_counter;  
end

// a clock counter which counts for a second
reg [$clog2(100_000_000):0] second_counter;
always @(posedge clk ) begin
  if(~reset_n || second_counter== 100_000_000 ||last_state != current_state) second_counter <= 0;
  else second_counter <= second_counter + 1;
end

function [11:0] BINtoBCD;
  input [9:0] bin;
  reg [3:0] unit_dig;
  reg [3:0] tens_dig;
  reg [3:0] huns_dig;
  begin
    unit_dig = bin%10;
    tens_dig = ((bin%100)-(bin%10))/10;
    huns_dig = ((bin%1000)-(bin%100))/100;

    BINtoBCD = {huns_dig,tens_dig,unit_dig};
  end
endfunction
function [11:0] BINCLKtoBCD;
    input [9:0] bin;
    reg [3:0] min_dig;
    reg [3:0] sectens_dig;
    reg [3:0] secunit_dig;
    begin
        min_dig = bin/60;
        sectens_dig =(bin%60)/10;
        secunit_dig=(bin%10);
        BINCLKtoBCD = {min_dig,sectens_dig,secunit_dig};
    end
endfunction

reg [6:0] s3_health_reg;
reg [6:0] S3_FULL_HP = 20;
  
reg [9:0] s3_clk_reg;
reg [9:0] s3_sc_reg;
wire [11:0] s3_clk_bcd;
wire [11:0] s3_sc_bcd;
assign s3_clk_bcd = BINCLKtoBCD(s3_clk_reg);
assign s3_sc_bcd = BINtoBCD(s3_sc_reg);


always @(posedge clk ) begin
  if(~reset_n)begin
    current_state <= S0;
    last_state <= S0;
  end
  else begin
    current_state <= next_state;
    last_state <= current_state;
  end
end
always @(*) begin
  case (current_state)
    S0: begin
      if(|btn_pressed) next_state = S1;
      else next_state = S0;
      usr_led = 4'b0001;
    end
    S1: begin
      if(btn_pressed[0]||btn_pressed[3])next_state = SPP;
      else next_state = S1;
      usr_led = 4'b0010;
    end
    SPP:begin
      usr_led=4'b0011;
      if(s1_level_counter == 1) next_state = SL1;
      else if(s1_level_counter == 2) next_state = SL2;
      else if(s1_level_counter == 3) next_state = SL3;
      else next_state = SPP;
    end
    SL1:begin
      usr_led=4'b0100;

      if(s3_clk_reg==0 || s3_health_reg==0)next_state = S4;
      else next_state = SL1;
    end
    SL2:begin
      usr_led=4'b0101;
      

      if(s3_clk_reg==0 || s3_health_reg==0)next_state = S4;
      else next_state = SL2;
    end
    SL3:begin
      usr_led=4'b0110;
      

      if(s3_clk_reg==0 || s3_health_reg==0)next_state = S4;
      else next_state = SL3;
    end
    S2:begin
      if(btn_pressed[3]) next_state = S4;
      else next_state = S2;
      
      usr_led=4'b1111;
    end
    S4:begin
      if(btn_pressed[0] || btn_pressed[3]) next_state = (s4_selection_counter)?S1:SPP;
      else next_state = S4;

      usr_led = 4'b1000;
    end
    default:begin
      next_state = S0;
      usr_led = 0;
    end
  endcase
end

// Instiantiate the VGA sync signal generator
vga_sync vs0(
  .clk(vga_clk), .reset(~reset_n), .oHS(VGA_HSYNC), .oVS(VGA_VSYNC),
  .visible(video_on), .p_tick(pixel_tick),
  .pixel_x(pixel_x), .pixel_y(pixel_y)
);

clk_divider#(2) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(vga_clk)
);

// ------------------------------------------------------------------------
// declare universal SRAM control signals
wire [11:0] data_in;
wire sram_we, sram_en;
assign data_in = 12'h000; // SRAM is read-only so we tie inputs to zeros.
assign sram_we = SW0; //bug in Vivado, synthsize to LUTRAM if set to 0.
assign sram_en = 1;  

//declare S0P1 signals
wire [11:0] s0p1_sram_addr;
wire [11:0] s0p1_sram_out;
reg  [17:0] pixel_s0p1_addr;

//declare S0P2 signals
wire [11:0] s0p2_sram_addr;
wire [11:0] s0p2_sram_out;
reg [17:0] pixel_s0p2_addr;

//declare S0P3 signals
wire [10:0] s0p3_sram_addr;
wire [11:0] s0p3_sram_out;
reg [17:0] pixel_s0p3_addr;

//delcare S1btnctrl signals
wire [11:0] s1btnctrl_sram_addr;
wire [11:0] s1btnctrl_sram_out;
reg [17:0] pixel_s1btnctrl_addr;

//delcare S1lv123 signals
wire [12:0] s1lv123_sram_addr;
wire [11:0] s1lv123_sram_out;
reg [17:0] pixel_s1lv123_addr;

//declare s3lbl signals
wire [11:0] s3lbl_sram_addr;
wire [11:0] s3lbl_sram_out;
reg [17:0] pixel_s3lbl_addr;

//declare s3numbers signals
wire [12:0] s3numbers_sram_addr;
wire [11:0] s3numbers_sram_out;
reg [17:0] pixel_s3numbers_addr;

//declare s4 signals
wire [13:0] s4_sram_addr;
wire [11:0] s4_sram_out;
reg [17:0] pixel_s4_addr;

S0_P1 #(.DATA_WIDTH(12), .ADDR_WIDTH(12), .RAM_SIZE(S0P1_W*S0P1_H))
  rams0p1 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(s0p1_sram_addr), .data_i(data_in), .data_o(s0p1_sram_out));

S0_P2 #(.DATA_WIDTH(12), .ADDR_WIDTH(12), .RAM_SIZE(S0P2_W*S0P2_H))
  rams0p2 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(s0p2_sram_addr), .data_i(data_in), .data_o(s0p2_sram_out));

S0_P3 #(.DATA_WIDTH(12), .ADDR_WIDTH(11), .RAM_SIZE(S0P3_W*S0P3_H))
  rams0p3 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(s0p3_sram_addr), .data_i(data_in), .data_o(s0p3_sram_out));

s1btnctrl #(.DATA_WIDTH(12), .ADDR_WIDTH(12), .RAM_SIZE(2688))
  rams1btnctrl (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(s1btnctrl_sram_addr), .data_i(data_in), .data_o(s1btnctrl_sram_out));

s1lv123 #(.DATA_WIDTH(12), .ADDR_WIDTH(13), .RAM_SIZE(4750))
  rams1lv123 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(s1lv123_sram_addr), .data_i(data_in), .data_o(s1lv123_sram_out));

s3lbl #(.DATA_WIDTH(12), .ADDR_WIDTH(12), .RAM_SIZE(3025))
  rams3lbl (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(s3lbl_sram_addr), .data_i(data_in), .data_o(s3lbl_sram_out));

s3numbers #(.DATA_WIDTH(12), .ADDR_WIDTH(13), .RAM_SIZE(5040))
  rams3numbers (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(s3numbers_sram_addr), .data_i(data_in), .data_o(s3numbers_sram_out));

rams4 #(.DATA_WIDTH(12), .ADDR_WIDTH(14), .RAM_SIZE(14000))
  rams4 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(s4_sram_addr), .data_i(data_in), .data_o(s4_sram_out));

assign s0p1_sram_addr = pixel_s0p1_addr;
assign s0p2_sram_addr = pixel_s0p2_addr;
assign s0p3_sram_addr = pixel_s0p3_addr;
assign s1btnctrl_sram_addr = pixel_s1btnctrl_addr;
assign s1lv123_sram_addr = pixel_s1lv123_addr;
assign s3lbl_sram_addr = pixel_s3lbl_addr;
assign s3numbers_sram_addr = pixel_s3numbers_addr;
assign s4_sram_addr = pixel_s4_addr;
// End of the SRAM memory block.
// ------------------------------------------------------------------------

// VGA color pixel generator
assign {VGA_RED, VGA_GREEN, VGA_BLUE} = rgb_reg;

// ------------------------------------------------------------------------
// An animation clock for the motion of the fish, upper bits of the
// fish clock is the x position of the fish on the VGA screen.
// Note that the fish will move one screen pixel every 2^20 clock cycles,
// or 10.49 msec

// assign pos = fish_clock[31:20]; // the x position of the right edge of the fish image
//                                 // in the 640x480 VGA screen
// always @(posedge clk) begin
//   if (~reset_n || fish_clock[31:21] > VBUF_W + S0P1_W)
//     fish_clock <= 0;
//   else
//     fish_clock <= fish_clock + 1;
// end
// End of the animation clock code.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// Video frame buffer address generation unit (AGU) with scaling control
// Note that the width x height of the fish image is 64x32, when scaled-up
// on the screen, it becomes 128x64. 'pos' specifies the right edge of the
// fish image.
assign s0p1_region =  pixel_y >= (S0P1_VPOS<<2) && pixel_y < (S0P1_VPOS+S0P1_H)<<2 &&
                      pixel_x >=(S0P1_HPOS<<2) && pixel_x < (S0P1_HPOS+S0P1_W)<<2;

assign s0p2_region =  pixel_y >= (S0P2_VPOS<<2) && pixel_y < (S0P2_VPOS+S0P2_H)<<2 &&
                      pixel_x >=(S0P2_HPOS<<2) && pixel_x < (S0P2_HPOS+S0P2_W)<<2;

assign s0p3_region =  pixel_y >= (S0P3_VPOS<<2) && pixel_y < (S0P3_VPOS+S0P3_H)<<2 &&
                      pixel_x >=(S0P3_HPOS<<2) && pixel_x < (S0P3_HPOS+S0P3_W)<<2;
assign s1snake_region = pixel_y >= (s1snake_VPOS<<1) && pixel_y < (s1snake_VPOS+50)<<1 &&
                      pixel_x >=(s1snake_HPOS<<1) && pixel_x < (s1snake_HPOS+50)<<1;


assign s1l1_region =  pixel_y >= (S1lv1_VPOS<<1) && pixel_y < (S1lv1_VPOS+25)<<1 &&
                      pixel_x >=(S1l_HPOS<<1) && pixel_x < (S1l_HPOS+100)<<1;
assign s1l2_region =  pixel_y >= (S1lv2_VPOS<<1) && pixel_y < (S1lv2_VPOS+25)<<1 &&
                      pixel_x >=(S1l_HPOS<<1) && pixel_x < (S1l_HPOS+100)<<1;
assign s1l3_region =  pixel_y >= (S1lv3_VPOS<<1) && pixel_y < (S1lv3_VPOS+25)<<1 &&
                      pixel_x >=(S1l_HPOS<<1) && pixel_x < (S1l_HPOS+100)<<1;

assign s1v1_region =  pixel_y >= (S1lv1_VPOS<<1) && pixel_y < (S1lv1_VPOS+25)<<1 &&
                      pixel_x >=(S1v_HPOS<<1) && pixel_x < (S1v_HPOS+30)<<1;
assign s1v2_region =  pixel_y >= (S1lv2_VPOS<<1) && pixel_y < (S1lv2_VPOS+25)<<1 &&
                      pixel_x >=(S1v_HPOS<<1) && pixel_x < (S1v_HPOS+30)<<1;
assign s1v3_region =  pixel_y >= (S1lv3_VPOS<<1) && pixel_y < (S1lv3_VPOS+25)<<1 &&
                      pixel_x >=(S1v_HPOS<<1) && pixel_x < (S1v_HPOS+30)<<1;

assign s1b1_region  = pixel_y >= (S1b_VPOS<<1) && pixel_y < (240)<<1 &&
                      pixel_x >=(S1b1_HPOS<<1) && pixel_x < (S1b1_HPOS+50)<<1;
assign s1b2_region  = pixel_y >= (S1b_VPOS<<1) && pixel_y < (240)<<1 &&
                      pixel_x >=(S1b2_HPOS<<1) && pixel_x < (S1b2_HPOS+50)<<1;
assign s1b3_region  = pixel_y >= (S1b_VPOS<<1) && pixel_y < (240)<<1 &&
                      pixel_x >=(S1b3_HPOS<<1) && pixel_x < (S1b3_HPOS+50)<<1;
assign s1b4_region  = pixel_y >= (S1b_VPOS<<1) && pixel_y < (240)<<1 &&
                      pixel_x >=(S1b4_HPOS<<1) && pixel_x < (S1b4_HPOS+50)<<1;

assign s1b1i_region = pixel_y >= (S1b_VPOS<<1) && pixel_y < (240)<<1 &&
                      pixel_x >=(S1b1i_HPOS<<1) && pixel_x < (S1b1i_HPOS+12)<<1;
assign s1b2i_region = pixel_y >= (S1b_VPOS<<1) && pixel_y < (240)<<1 &&
                      pixel_x >=(S1b2i_HPOS<<1) && pixel_x < (S1b2i_HPOS+12)<<1;
assign s1b3i_region = pixel_y >= (S1b_VPOS<<1) && pixel_y < (240)<<1 &&
                      pixel_x >=(S1b3i_HPOS<<1) && pixel_x < (S1b3i_HPOS+12)<<1;
assign s1b4i_region = pixel_y >= (S1b_VPOS<<1) && pixel_y < (240)<<1 &&
                      pixel_x >=(S1b4i_HPOS<<1) && pixel_x < (S1b4i_HPOS+12)<<1;

assign s2game_region =  pixel_y >= (S2game_VPOS<<1) && pixel_y < (S2game_VPOS+150)<<1 &&
                        pixel_x >=(S2game_HPOS<<1) && pixel_x < (S2game_HPOS+250)<<1;

assign  s2clki_region = pixel_y >= (S2i_VPOS<<1) && pixel_y < (S2i_VPOS+25)<<1 &&
                        pixel_x >=(S2clki_HPOS<<1) && pixel_x < (S2clki_HPOS+25)<<1;


assign  s2sci_region =  pixel_y >= (S2i_VPOS<<1) && pixel_y < (S2i_VPOS+25)<<1 &&
                        pixel_x >=(S2sci_HPOS<<1) && pixel_x < (S2sci_HPOS+80)<<1;

assign s2heart_region = pixel_y >= (S2i_VPOS<<1) && pixel_y < (S2i_VPOS+20)<<1 &&
                        pixel_x >=(S2heart_HPOS<<1) && pixel_x < (S2heart_HPOS+20)<<1;

assign s2health_region = pixel_y >= (S2health_VPOS<<1) && pixel_y < (S2health_VPOS+7)<<1 &&
                        pixel_x >=(S2health_HPOS<<1) && pixel_x < (S2health_HPOS+(80*s3_health_reg/S3_FULL_HP))<<1;

assign s2healthb_region = ((pixel_y >= ((S2health_VPOS-2)<<1) && pixel_y < (S2health_VPOS)<<1) ||
                          (pixel_y >= ((S2health_VPOS+7)<<1) && pixel_y < (S2health_VPOS+7+2)<<1))&&
                          ((pixel_x >=((S2health_HPOS-2)<<1) && pixel_x < (S2health_HPOS)<<1 )||
                          (pixel_x >=((S2health_HPOS+80)<<1) && pixel_x < (S2health_HPOS+80+2)<<1));

assign s2_clknum1_region =  pixel_y >= (S2num_VPOS<<1) && pixel_y < (S2num_VPOS+28)<<1 &&
                            pixel_x >=(S2clknum1_HPOS<<1) && pixel_x < (S2clknum1_HPOS+17)<<1;
assign s2_clkdot_region =   pixel_y >= (S2num_VPOS<<1) && pixel_y < (S2num_VPOS+28)<<1 &&
                            pixel_x >=(S2clkdot_HPOS<<1) && pixel_x < (S2clkdot_HPOS+10)<<1;
assign s2_clknum2_region =  pixel_y >= (S2num_VPOS<<1) && pixel_y < (S2num_VPOS+28)<<1 &&
                            pixel_x >=(S2clknum2_HPOS<<1) && pixel_x < (S2clknum2_HPOS+17)<<1;
assign s2_clknum3_region =  pixel_y >= (S2num_VPOS<<1) && pixel_y < (S2num_VPOS+28)<<1 &&
                            pixel_x >=(S2clknum3_HPOS<<1) && pixel_x < (S2clknum3_HPOS+17)<<1;

assign s2_scnum1_region =   pixel_y >= (S2num_VPOS<<1) && pixel_y < (S2num_VPOS+28)<<1 &&
                            pixel_x >=(S2scnum1_HPOS<<1) && pixel_x < (S2scnum1_HPOS+17)<<1;
assign s2_scnum2_region =   pixel_y >= (S2num_VPOS<<1) && pixel_y < (S2num_VPOS+28)<<1 &&
                            pixel_x >=(S2scnum2_HPOS<<1) && pixel_x < (S2scnum2_HPOS+17)<<1; 
assign s2_scnum3_region =   pixel_y >= (S2num_VPOS<<1) && pixel_y < (S2num_VPOS+28)<<1 &&
                            pixel_x >=(S2scnum3_HPOS<<1) && pixel_x < (S2scnum3_HPOS+17)<<1; 

assign s4_again_region = pixel_y >= (S4again_VPOS) && pixel_y < (S4again_VPOS+40) &&
                            pixel_x >=(S4again_HPOS) && pixel_x < (S4again_HPOS+200); 

assign s4_menu_region = pixel_y >= (S4menu_VPOS) && pixel_y < (S4menu_VPOS+40) &&
                        pixel_x >=(S4menu_HPOS) && pixel_x < (S4menu_HPOS+120); 


assign s4_agains_region = pixel_y >= (S4agains_VPOS) && pixel_y < (S4agains_VPOS+20) &&
                        pixel_x >=(S4agains_HPOS) && pixel_x < (S4agains_HPOS+60); 

assign s4_menus_region = pixel_y >= (S4menus_VPOS) && pixel_y < (S4menus_VPOS+20) &&
                        pixel_x >=(S4menus_HPOS) && pixel_x < (S4menus_HPOS+60);

assign s4_score_region = pixel_y >= (S4score_VPOS<<1) && pixel_y < (S4score_VPOS+25)<<1 &&
                          pixel_x >=(S4score_HPOS<<1) && pixel_x < (S4score_HPOS+80)<<1;


assign s4_sc1_region = pixel_y >= (S4sc_VPOS<<2) && pixel_y < (S4sc_VPOS+28)<<2 &&
                          pixel_x >=(S4sc1_HPOS<<2) && pixel_x < (S4sc1_HPOS+17)<<2;
assign s4_sc2_region = pixel_y >= (S4sc_VPOS<<2) && pixel_y < (S4sc_VPOS+28)<<2 &&
                          pixel_x >=(S4sc2_HPOS<<2) && pixel_x < (S4sc2_HPOS+17)<<2;
assign s4_sc3_region = pixel_y >= (S4sc_VPOS<<2) && pixel_y < (S4sc_VPOS+28)<<2 &&
                          pixel_x >=(S4sc3_HPOS<<2) && pixel_x < (S4sc3_HPOS+17)<<2;


assign s1lv1s_region = pixel_y >= (S1lv1s_VPOS) && pixel_y < (S1lv1s_VPOS+20) &&
                        pixel_x >=(S1lvs_HPOS) && pixel_x < (S1lvs_HPOS+60); 

assign s1lv2s_region = pixel_y >= (S1lv2s_VPOS) && pixel_y < (S1lv2s_VPOS+20) &&
                        pixel_x >=(S1lvs_HPOS) && pixel_x < (S1lvs_HPOS+60); 

assign s1lv3s_region = pixel_y >= (S1lv3s_VPOS) && pixel_y < (S1lv3s_VPOS+20) &&
                        pixel_x >=(S1lvs_HPOS) && pixel_x < (S1lvs_HPOS+60); 


always @ (posedge clk) begin
  if (~reset_n)begin
    pixel_s0p1_addr <= 0;
    pixel_s0p2_addr <= 0;
    pixel_s0p3_addr <= 0;
  end
  else begin
    // Scale up a 320x240 image for the 640x480 display.
    // (pixel_x, pixel_y) ranges from (0,0) to (639, 479)
    pixel_s0p1_addr <= ((pixel_y>>2)-S0P1_VPOS)*S0P1_W +
                  ((pixel_x>>2)-S0P1_HPOS);
    
    pixel_s0p3_addr <= ((pixel_y>>2)-S0P3_VPOS)*S0P3_W +
              ((pixel_x>>2)-S0P3_HPOS);  
    if (s0p2_region)
      pixel_s0p2_addr <= ((pixel_y>>2)-S0P2_VPOS)*S0P2_W + ((pixel_x>>2)-S0P2_HPOS);
    else if(s1snake_region)
      pixel_s0p2_addr <= ((pixel_y>>1)-s1snake_VPOS)*50 + ((pixel_x>>1)-s1snake_HPOS);

  end          
end

always @ (posedge clk) begin
  if (~reset_n) 
    pixel_s1lv123_addr <= 0;
  else if(s1l1_region) 
    pixel_s1lv123_addr <= 0 +((pixel_y>>1)-S1lv1_VPOS)*100 +((pixel_x>>1)-S1l_HPOS);
  else if(s1l2_region)
    pixel_s1lv123_addr <= 0 +((pixel_y>>1)-S1lv2_VPOS)*100 +((pixel_x>>1)-S1l_HPOS);
  else if(s1l3_region)
    pixel_s1lv123_addr <= 0 +((pixel_y>>1)-S1lv3_VPOS)*100 +((pixel_x>>1)-S1l_HPOS);
  else if(s1v1_region)
    pixel_s1lv123_addr <= 2500 +((pixel_y>>1)-S1lv1_VPOS)*30 +((pixel_x>>1)-S1v_HPOS);
  else if(s1v2_region)
    pixel_s1lv123_addr <= 2500+750 +((pixel_y>>1)-S1lv2_VPOS)*30 +((pixel_x>>1)-S1v_HPOS);
  else if(s1v3_region)
    pixel_s1lv123_addr <= 2500 +1500 +((pixel_y>>1)-S1lv3_VPOS)*30 +((pixel_x>>1)-S1v_HPOS);
       
end

always @(posedge clk) begin
  if(~reset_n)
    pixel_s1btnctrl_addr <= 0;
  else if (s1b1_region)
    pixel_s1btnctrl_addr<=0 + ((pixel_y>>1)-S1b_VPOS)*50 +((pixel_x>>1)-S1b1_HPOS);
  else if (s1b2_region)
    pixel_s1btnctrl_addr<=600 + ((pixel_y>>1)-S1b_VPOS)*50 +((pixel_x>>1)-S1b2_HPOS);
  else if (s1b3_region)
    pixel_s1btnctrl_addr<=1200 + ((pixel_y>>1)-S1b_VPOS)*50 +((pixel_x>>1)-S1b3_HPOS);
  else if (s1b4_region)
    pixel_s1btnctrl_addr<=1800 + ((pixel_y>>1)-S1b_VPOS)*50 +((pixel_x>>1)-S1b4_HPOS);
  else if (s1b1i_region)
    pixel_s1btnctrl_addr<=2544 + ((pixel_y>>1)-S1b_VPOS)*12 +((pixel_x>>1)-S1b1i_HPOS);
  else if (s1b2i_region)
    pixel_s1btnctrl_addr<=2400 + ((pixel_y>>1)-S1b_VPOS)*12 +((pixel_x>>1)-S1b2i_HPOS);
  else if (s1b3i_region)
    pixel_s1btnctrl_addr<=2400 + ((pixel_y>>1)-S1b_VPOS)*12 +((pixel_x>>1)-S1b3i_HPOS);
  else if (s1b4i_region)
    //pixel_s1btnctrl_addr<=2400 + ((pixel_y>>1)-S1b_VPOS)*12 +((pixel_x>>1)-S1b4i_HPOS);
    pixel_s1btnctrl_addr<=2544 + (239-(pixel_y>>1))*12 +((pixel_x>>1)-S1b4i_HPOS);
    
end

always @(posedge clk ) begin
  if(~reset_n)
    pixel_s3lbl_addr <= 0;
  else if(s4_score_region && current_state == S4)
    pixel_s3lbl_addr <= 1025 + ((pixel_y>>1)-S4score_VPOS)*80 +((pixel_x>>1)-S4score_HPOS);
  else if(s2clki_region)
    pixel_s3lbl_addr <= 0 + ((pixel_y>>1)-S2i_VPOS)*25 +((pixel_x>>1)-S2clki_HPOS);
  else if(s2heart_region)
    pixel_s3lbl_addr <= 625 + ((pixel_y>>1)-S2i_VPOS)*20 +((pixel_x>>1)-S2heart_HPOS);
  else if(s2sci_region)
    pixel_s3lbl_addr <= 625+400 + ((pixel_y>>1)-S2i_VPOS)*80 +((pixel_x>>1)-S2sci_HPOS);

  else 
    pixel_s3lbl_addr <= 0;

end

always @(posedge clk ) begin
  if(~reset_n)
    pixel_s3numbers_addr <= 0;
  else if(s2_clkdot_region)begin//dot position
    pixel_s3numbers_addr <= 4760 + ((pixel_y>>1)-S2num_VPOS)*10 +((pixel_x>>1)-S2clkdot_HPOS);
  end
  else if(s2_clknum1_region)begin
    pixel_s3numbers_addr <= 476*s3_clk_bcd[11:8] + ((pixel_y>>1)-S2num_VPOS)*17 +((pixel_x>>1)-S2clknum1_HPOS);
  end
  else if(s2_clknum2_region)begin
    pixel_s3numbers_addr <= 476*s3_clk_bcd[7:4] + ((pixel_y>>1)-S2num_VPOS)*17 +((pixel_x>>1)-S2clknum2_HPOS);
  end
  else if(s2_clknum3_region)begin
    pixel_s3numbers_addr <= 476*s3_clk_bcd[3:0] + ((pixel_y>>1)-S2num_VPOS)*17 +((pixel_x>>1)-S2clknum3_HPOS);
  end
  else if(s2_scnum1_region)begin
    pixel_s3numbers_addr <= 476*s3_sc_bcd[11:8] + ((pixel_y>>1)-S2num_VPOS)*17 +((pixel_x>>1)-S2scnum1_HPOS);
  end
  else if(s2_scnum2_region)begin
    pixel_s3numbers_addr <= 476*s3_sc_bcd[7:4] + ((pixel_y>>1)-S2num_VPOS)*17 +((pixel_x>>1)-S2scnum2_HPOS);
  end
  else if(s2_scnum3_region)begin
    pixel_s3numbers_addr <= 476*s3_sc_bcd[3:0] + ((pixel_y>>1)-S2num_VPOS)*17 +((pixel_x>>1)-S2scnum3_HPOS);
  end
  else if(s4_sc1_region)
    pixel_s3numbers_addr <= 476*s3_sc_bcd[11:8] + ((pixel_y>>2)-S4sc_VPOS)*17 +((pixel_x>>2)-S4sc1_HPOS);
  else if(s4_sc2_region)
    pixel_s3numbers_addr <= 476*s3_sc_bcd[7:4] + ((pixel_y>>2)-S4sc_VPOS)*17 +((pixel_x>>2)-S4sc2_HPOS);
  else if(s4_sc3_region)
    pixel_s3numbers_addr <= 476*s3_sc_bcd[3:0] + ((pixel_y>>2)-S4sc_VPOS)*17 +((pixel_x>>2)-S4sc3_HPOS);
  else
    pixel_s3numbers_addr <= 0;
end

always @(posedge clk ) begin
  if(!reset_n)
    pixel_s4_addr <= 0;
  else if(s1lv1s_region && current_state == S1)
    pixel_s4_addr <= 12800 + (( pixel_y)-S1lv1s_VPOS)*60 +((pixel_x)-S1lvs_HPOS);
  else if(s1lv2s_region && current_state == S1)
    pixel_s4_addr <= 12800 + (( pixel_y)-S1lv2s_VPOS)*60 +((pixel_x)-S1lvs_HPOS);
  else if(s1lv3s_region && current_state == S1)
    pixel_s4_addr <= 12800 + (( pixel_y)-S1lv3s_VPOS)*60 +((pixel_x)-S1lvs_HPOS);
  else if(s4_again_region)
    pixel_s4_addr <= 0 + ((pixel_y)-S4again_VPOS)*200 +((pixel_x)-S4again_HPOS);
  else if(s4_menu_region)
    pixel_s4_addr <= 8000 + ((pixel_y)-S4menu_VPOS)*120 +((pixel_x)-S4menu_HPOS);
  else if(s4_agains_region)
    pixel_s4_addr <= 12800 + ((pixel_y)-S4agains_VPOS)*60 +((pixel_x)-S4agains_HPOS);
  else if(s4_menus_region)
    pixel_s4_addr <= 12800 + (( pixel_y)-S4menus_VPOS)*60 +((pixel_x)-S4menus_HPOS);
  
end

// End of the AGU code.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// Send the video data in the sram to the VGA controller
always @(posedge clk) begin
  if (pixel_tick) rgb_reg <= rgb_next;
end


// End of the video data display code.
// ------------------------------------------------------------------------

//below is the merging region:

localparam LEN_MAX = 20;  //MAX length of snake is defined to be 20

localparam [1:0] RIGHT = 2'b01, UP = 2'b00, DOWN = 2'b10, LEFT = 2'b11; 
localparam [27:0] speed_1 = 'd50000000, speed_2 = 'd20000000, speed_3 = 'd5000000;
reg [5:0]snakeX [0:LEN_MAX-1]; // [6:3] saves the horizontal address (0 ~ 64), [2:0] saves the vertical address
reg [5:0]snakeY [0:LEN_MAX-1]; 
reg [3:0] direction; 
reg [4:0] len;    //records current length of the snake

reg snake_region;
reg [27:0] snake_clock;
integer i,j;

reg  [1:0] P, P_next;

reg [5:0]green_man_hold_count;
reg [5:0]green_man_count;
reg [6:0]green_manX[0:48];
reg [6:0]green_manY[0:48];
reg [5:0]red_man_hold_count;
reg [5:0]red_man_count;
reg [6:0]red_manX[0:61];
reg [6:0]red_manY[0:61];
reg [27:0] speed;
 //draw green man
initial begin 
    green_manX[0]= 'd19; green_manX[1] = 'd20; green_manX[2] = 'd18; green_manX[3] = 'd19; green_manX[4] = 'd20; green_manX[5] = 'd21;
    green_manX[6]= 'd19; green_manX[7] = 'd20; green_manX[8] = 'd20; green_manX[9] = 'd21; green_manX[10] = 'd20; green_manX[11] = 'd21;
    green_manX[12]= 'd22; green_manX[13] = 'd19; green_manX[14] = 'd20; green_manX[15] = 'd21; green_manX[16] = 'd22; green_manX[17] = 'd23;
    green_manX[18]= 'd24; green_manX[19] = 'd19; green_manX[20] = 'd20; green_manX[21] = 'd21; green_manX[22] = 'd22; green_manX[23] = 'd25;
    green_manX[24]= 'd18; green_manX[25] = 'd20; green_manX[26] = 'd21; green_manX[27] = 'd26; green_manX[28] = 'd17; green_manX[29] = 'd20;
    green_manX[30]= 'd21; green_manX[31] = 'd22; green_manX[32] = 'd21; green_manX[33] = 'd22; green_manX[34] = 'd21; green_manX[35] = 'd22;
    green_manX[36]= 'd23; green_manX[37] = 'd22; green_manX[38] = 'd24; green_manX[39] = 'd21; green_manX[40] = 'd25; green_manX[41] = 'd26;
    green_manX[42]= 'd27; green_manX[43] = 'd28; green_manX[44] = 'd20; green_manX[45] = 'd28; green_manX[46] = 'd20; green_manX[47] = 'd19;
    green_manX[48] = 'd20;
    green_manY[0]= 'd22; green_manY[1] = 'd22; green_manY[2] = 'd23; green_manY[3] = 'd23; green_manY[4] = 'd23; green_manY[5] = 'd23;
    green_manY[6]= 'd24; green_manY[7] = 'd24; green_manY[8] = 'd25; green_manY[9] = 'd25; green_manY[10] = 'd26; green_manY[11] = 'd26;
    green_manY[12]= 'd26; green_manY[13] = 'd27; green_manY[14] = 'd27; green_manY[15] = 'd27; green_manY[16] = 'd27; green_manY[17] = 'd27;
    green_manY[18]= 'd27; green_manY[19] = 'd28; green_manY[20] = 'd28; green_manY[21] = 'd28; green_manY[22] = 'd28; green_manY[23] = 'd28;
    green_manY[24]= 'd29; green_manY[25] = 'd29; green_manY[26] = 'd29; green_manY[27] = 'd29; green_manY[28] = 'd30; green_manY[29] = 'd30;
    green_manY[30]= 'd30; green_manY[31] = 'd30; green_manY[32] = 'd31; green_manY[33] = 'd31; green_manY[34] = 'd32; green_manY[35] = 'd32;
    green_manY[36]= 'd32; green_manY[37] = 'd33; green_manY[38] = 'd33; green_manY[39] = 'd34; green_manY[40] = 'd34; green_manY[41] = 'd34;
    green_manY[42]= 'd34; green_manY[43] = 'd34; green_manY[44] = 'd35; green_manY[45] = 'd35; green_manY[46] = 'd36; green_manY[47] = 'd37;
    green_manY[48] = 'd37;
    red_manX[0] = 'd41;red_manX[1] = 'd42;red_manX[2] = 'd40;red_manX[3] = 'd41;red_manX[4] = 'd42;
    red_manX[5] = 'd43;red_manX[6] = 'd41;red_manX[7] = 'd42;red_manX[8] = 'd41;red_manX[9] = 'd42;
    red_manX[10] = 'd40;red_manX[11] = 'd41;red_manX[12] = 'd42;red_manX[13] = 'd43;red_manX[14] = 'd39;
    red_manX[15] = 'd40;red_manX[16] = 'd41;red_manX[17] = 'd42;red_manX[18] = 'd43;red_manX[19] = 'd44;
    red_manX[20] = 'd38;red_manX[21] = 'd40;red_manX[22] = 'd41;red_manX[23] = 'd42;red_manX[24] = 'd43;
    red_manX[25] = 'd45;red_manX[26] = 'd38;red_manX[27] = 'd40;red_manX[28] = 'd41;red_manX[29] = 'd42;
    red_manX[30] = 'd43;red_manX[31] = 'd45;red_manX[32] = 'd38;red_manX[33] = 'd40;red_manX[34] = 'd41;
    red_manX[35] = 'd42;red_manX[36] = 'd43;red_manX[37] = 'd45;red_manX[38] = 'd38;red_manX[39] = 'd40;
    red_manX[40] = 'd41;red_manX[41] = 'd42;red_manX[42] = 'd43;red_manX[43] = 'd45;red_manX[44] = 'd40;
    red_manX[45] = 'd41;red_manX[46] = 'd42;red_manX[47] = 'd43;red_manX[48] = 'd40;red_manX[49] = 'd41;
    red_manX[50] = 'd42;red_manX[51] = 'd43;red_manX[52] = 'd39;red_manX[53] = 'd44;red_manX[54] = 'd39;
    red_manX[55] = 'd44;red_manX[56] = 'd39;red_manX[57] = 'd44;red_manX[58] = 'd38;red_manX[59] = 'd39;
    red_manX[60] = 'd44;red_manX[61] = 'd45;
    red_manY[0] = 'd22;red_manY[1] = 'd22;red_manY[2] = 'd23;red_manY[3] = 'd23;red_manY[4] = 'd23;
    red_manY[5] = 'd23;red_manY[6] = 'd24;red_manY[7] = 'd24;red_manY[8] = 'd25;red_manY[9] = 'd25;
    red_manY[10] = 'd26;red_manY[11] = 'd26;red_manY[12] = 'd26;red_manY[13] = 'd26;red_manY[14] = 'd27;
    red_manY[15] = 'd27;red_manY[16] = 'd27;red_manY[17] = 'd27;red_manY[18] = 'd27;red_manY[19] = 'd27;
    red_manY[20] = 'd28;red_manY[21] = 'd28;red_manY[22] = 'd28;red_manY[23] = 'd28;red_manY[24] = 'd28;
    red_manY[25] = 'd28;red_manY[26] = 'd29;red_manY[27] = 'd29;red_manY[28] = 'd29;red_manY[29] = 'd29;
    red_manY[30] = 'd29;red_manY[31] = 'd29;red_manY[32] = 'd30;red_manY[33] = 'd30;red_manY[34] = 'd30;
    red_manY[35] = 'd30;red_manY[36] = 'd30;red_manY[37] = 'd30;red_manY[38] = 'd31;red_manY[39] = 'd31;
    red_manY[40] = 'd31;red_manY[41] = 'd31;red_manY[42] = 'd31;red_manY[43] = 'd31;red_manY[44] = 'd32;
    red_manY[45] = 'd32;red_manY[46] = 'd32;red_manY[47] = 'd32;red_manY[48] = 'd33;red_manY[49] = 'd33;
    red_manY[50] = 'd33;red_manY[51] = 'd33;red_manY[52] = 'd34;red_manY[53] = 'd34;red_manY[54] = 'd35;
    red_manY[55] = 'd35;red_manY[56] = 'd36;red_manY[57] = 'd36;red_manY[58] = 'd37;red_manY[59] = 'd37;
    red_manY[60] = 'd37;red_manY[61] = 'd37;
end

reg [11:0] apple[0:9][0:9];
initial begin
	for(i=0; i<10; i = i+1)
		for(j=0; j<10; j = j+1)
			if(i+j <= 2)
				apple[i][j] = 12'h000;
			else if(i+j > 15)
				apple[i][j] = 12'h000;
			else if(i-j > 6)
				apple[i][j] = 12'h000;
			else if(j-i > 6)
				apple[i][j] = 12'h000;
			else
				apple[i][j] = 12'hf10;
	apple[3][3] = 12'h000;	apple[4][1] = 12'h000;	apple[4][2] = 12'h000;	apple[4][3] = 12'h000;
	apple[4][4] = 12'h000;	apple[5][1] = 12'h000;	apple[5][4] = 12'h000;	apple[6][3] = 12'h000;				
end

reg [11:0] berry[0:9][0:9];
initial begin
	for(i=0; i<10; i = i+1)
		for(j=0; j<10; j = j+1)
			if(i == 0 && (j == 6 || j == 7))
				berry[i][j] = 12'h0e1;
			else if(i == 1 && j == 6)
				berry[i][j] = 12'h0e1;
			else if(i == 2 && (j == 5 || j == 6 || j == 7))
				berry[i][j] = 12'h0e1;
			else if(i == 3 && (j == 4 || j == 5 || j == 8))
				berry[i][j] = 12'h0e1;
			else if(i == 4 && (j == 4 || j == 7 || j == 8))
				berry[i][j] = 12'h0e1;
			else if(i == 5 && (j == 3 || j == 8))
				berry[i][j] = 12'h0e1;
			else if(i == 6 && (j == 2 || j == 3 || j == 7 || j == 8))
				berry[i][j] = 12'hf01;
			else if(i == 7 && (j == 1 || j == 3 || j == 4 || j == 6 || j == 7 || j == 9))
				berry[i][j] = 12'hf01;
			else if(i == 7 && (j == 2 || j == 8))
				berry[i][j] = 12'hfff;
			else if(i == 8 && (j == 1 || j == 2 || j == 4 || j == 6 || j == 7 || j == 9))
				berry[i][j] = 12'hf01;
			else if(i == 8 && (j == 3 || j == 7))
				berry[i][j] = 12'hfff;
			else if(i == 9 && (j == 2 || j == 3 || j == 7 || j == 8))
				berry[i][j] = 12'hf01;
			else
				berry[i][j] = 12'h000;
end

always @(posedge clk) begin
    if(~reset_n || current_state == SPP) begin
        speed <= speed_1;
    end
    else if(len > 15) speed <= speed_3;
    else if(len > 10) speed <= speed_2; 
end

reg map[0:50][0:30];
always @(posedge clk) begin
    if(~reset_n || current_state == SPP) begin //todo map changed here
        for(i=0; i<50;i=i+1)
            for(j=0;j<30;j=j+1)
                map[i][j] <= 0;
		for(i=0; i<=50;i=i+1)
			map[i][30] <= 1;
		for(j=0; j<30; j=j+1)
			map[50][j] <= 1;
    end
    else if(s1_level_counter == 1)begin
        for(i=0; i<50;i=i+1)
            for(j=0;j<30;j=j+1)
                if     (i >= 23 && i < 27 && j >=  0 && j <  3) map[i][j] <= 1;
                else if(i >= 23 && i < 27 && j >=  5 && j <  8) map[i][j] <= 1;
                else if(i >= 23 && i < 27 && j >= 10 && j < 20) map[i][j] <= 1;
                else if(i >= 23 && i < 27 && j >= 22 && j < 25) map[i][j] <= 1;
                else if(i >= 23 && i < 27 && j >= 27 && j < 30) map[i][j] <= 1;
                else if(i >=  0 && i <  8 && j >= 13 && j < 17) map[i][j] <= 1;
                else if(i >= 10 && i < 18 && j >= 13 && j < 17) map[i][j] <= 1;
                else if(i >= 20 && i < 30 && j >= 13 && j < 17) map[i][j] <= 1;
                else if(i >= 32 && i < 40 && j >= 13 && j < 17) map[i][j] <= 1;
                else if(i >= 42 && i < 50 && j >= 13 && j < 17) map[i][j] <= 1;
                else map[i][j] <= 0;//+
    end
    else if(s1_level_counter == 2)begin
        for(i=0; i<50;i=i+1)
            for(j=0;j<30;j=j+1)
				if	   (i >=  7 && i < 10 && j >=  5 && j <  8) map[i][j] <= 1;
				else if(i >=  7 && i < 10 && j >= 13 && j < 16) map[i][j] <= 1;
				else if(i >=  7 && i < 10 && j >= 21 && j < 24) map[i][j] <= 1;
				else if(i >= 18 && i < 21 && j >=  5 && j <  8) map[i][j] <= 1;
				else if(i >= 18 && i < 21 && j >= 13 && j < 16) map[i][j] <= 1;
				else if(i >= 18 && i < 21 && j >= 21 && j < 24) map[i][j] <= 1;
				else if(i >= 29 && i < 32 && j >=  5 && j <  8) map[i][j] <= 1;
				else if(i >= 29 && i < 32 && j >= 13 && j < 16) map[i][j] <= 1;
				else if(i >= 29 && i < 32 && j >= 21 && j < 24) map[i][j] <= 1;
				else if(i >= 40 && i < 42 && j >=  5 && j <  8) map[i][j] <= 1;
				else if(i >= 40 && i < 42 && j >= 13 && j < 16) map[i][j] <= 1;
				else if(i >= 40 && i < 42 && j >= 21 && j < 24) map[i][j] <= 1;
				else map[i][j] <= 0;//block
    end
    else if(s1_level_counter == 3)begin
		for(i=0; i<49; i=i+1)begin
			map[green_manX[i]-7][green_manY[i]-15] <= 1;
		end
		map[12][15] <= 1;	map[14][10] <= 1;	map[14][19] <= 1;	map[15][15] <= 1;	map[16][19] <= 1;
		for(i=0; i<62; i=i+1)begin
			map[red_manX[i]-7][red_manY[i]-15] <= 1;//man
		end
		map[32][14] <= 1;	map[32][15] <= 1;	map[32][16] <= 1;	map[32][17] <= 1;
		map[37][14] <= 1;	map[37][15] <= 1;	map[37][16] <= 1;	map[37][17] <= 1;
	end
end
reg [10:0] r_count;
always @(posedge clk)begin
    if(~reset_n || current_state == S1)begin
        r_count <= 20;
    end
    else if(r_count <2017)
        r_count <= r_count + 1;
	else
		r_count <= 0;
end

localparam [1:0] IDLE = 2'b10, GEN = 2'b01;
reg [1:0] Q, Q_next;
reg [10:0] a_x;
reg [10:0] a_y;
reg [10:0] apple_x;
reg [10:0] apple_y;

always @ (*) begin
    case (Q) 
    IDLE: begin
        //when collide with the apple
        if((snakeX[0] == apple_x+7) && (snakeY[0] == apple_y+15)) Q_next = GEN;
        else Q_next = IDLE;
    end
    GEN: begin
        if(a_x < 50 && a_y < 30 && map[a_x][a_y] == 0) Q_next = IDLE; 
        else Q_next = GEN;
    end
    default: Q_next = GEN;
    endcase
end

always @(posedge clk) begin
    if(~reset_n  || current_state == SPP) Q <= GEN;
    else Q <= Q_next;    
end

always @(posedge clk)begin
    if(~reset_n || current_state == SPP)begin
        a_x <= 50;
        a_y <= 30;
    end
    else if(Q_next == GEN)begin
        a_x <= (r_count%179 * r_count%211)%50;
        a_y <= (r_count%311 * r_count%239)%30; 
	end
    else if(Q == IDLE)begin
        a_x <= 50;
        a_y <= 30; 
	end
end

always @(posedge clk)begin
    if(~reset_n || current_state == SPP)begin
        apple_x <= 50;
        apple_y <= 30;
    end
    else if(Q == IDLE && Q_next == GEN)begin
        apple_x <= 50;
        apple_y <= 30;
	end
    else if(Q == GEN && Q_next == IDLE)begin
        apple_x <= a_x;
        apple_y <= a_y;
	end
	else if(Q == GEN)begin
		apple_x <= 50;
		apple_y <= 30;		
	end
end

reg [1:0] K, K_next;
reg [10:0] b_x;
reg [10:0] b_y;
reg [10:0] berry_x;
reg [10:0] berry_y;

always @ (*) begin
    case (K) 
    IDLE: begin
        //when collide with the apple
        if((snakeX[0] == berry_x+7) && (snakeY[0] == berry_y+15)) K_next = GEN;
        else K_next = IDLE;
    end
    GEN: begin
        if(b_x < 50 && b_y < 30 && map[b_x][b_y] == 0 && a_x != b_x && a_y != b_y) K_next = IDLE; 
        else K_next = GEN;
    end
    default: K_next = GEN;
    endcase
end

always @(posedge clk) begin
    if(~reset_n  || current_state == SPP) K <= GEN;
    else K <= K_next;    
end

always @(posedge clk)begin
    if(~reset_n || current_state == SPP)begin
        b_x <= 50;
        b_y <= 30;
    end
    else if(K_next == GEN)begin
        b_x <= (r_count%223 * r_count%211)%50;
        b_y <= (r_count%283 * r_count%149)%30; 
	end
    else if(K == IDLE)begin
        b_x <= 50;
        b_y <= 30; 
	end
end

always @(posedge clk)begin
    if(~reset_n || current_state == SPP)begin
        berry_x <= 50;
        berry_y <= 30;
    end
    else if(K == IDLE && K_next == GEN)begin
        berry_x <= 50;
        berry_y <= 30;
	end
    else if(K == GEN && K_next == IDLE)begin
        berry_x <= b_x;
        berry_y <= b_y;
	end
	else if(K == GEN)begin
		berry_x <= 50;
		berry_y <= 30;		
	end
end

always @(posedge clk) begin
  if(~reset_n)begin
    s3_clk_reg <= 0;
    s3_sc_reg <=0;
  end
  if(current_state == SPP)begin
    if(s1_level_counter == 1)begin
      s3_clk_reg <= 60;
      s3_sc_reg <= 0;
    end
    else if(s1_level_counter == 2)begin
      s3_clk_reg <= 90;
      s3_sc_reg <= 0;
    end
    else if(s1_level_counter == 3)begin
      s3_clk_reg <= 105;
      s3_sc_reg <= 0;

    end
  end
  else if((current_state ==SL1)||(current_state == SL2) || (current_state == SL3))begin
    if((second_counter == 100_000_000) && (s3_clk_reg!=0))
      s3_clk_reg <= s3_clk_reg - 1;
    if((snakeX[0] == apple_x+7) && (snakeY[0] == apple_y+15)) s3_sc_reg <= s3_sc_reg + 10;
    else if((snakeX[0] == berry_x+7) && (snakeY[0] == berry_y+15)) s3_sc_reg <= s3_sc_reg + 10;
  end
end

always @(posedge clk) begin
  if(~reset_n)begin
    s3_health_reg <= 0;
    S3_FULL_HP <= 0;
  end
  if(current_state == SPP)begin
    if(s1_level_counter == 1)begin
      s3_health_reg <= 10;
      S3_FULL_HP <= 10;
    end
    else if(s1_level_counter == 2)begin
      s3_health_reg <= 15;
      S3_FULL_HP <= 15;
      
    end
    else if(s1_level_counter == 3)begin
      s3_health_reg <= 20;
      S3_FULL_HP <= 20;
      
    end
  end
  else if((current_state ==SL1)||(current_state == SL2) || (current_state == SL3))begin

    if(snake_clock == speed - 1) begin
        case(direction)
            4'b0001: begin // if the snake is moving up

                // the always on detections, 
                if(
                    (snakeY[0] == 15)                                                    ||
                    (snakeY[0] - 1 == snakeY[ 1] && snakeX[0] == snakeX[ 1] && len >  1) ||
                    (snakeY[0] - 1 == snakeY[ 2] && snakeX[0] == snakeX[ 2] && len >  2) ||
                    (snakeY[0] - 1 == snakeY[ 3] && snakeX[0] == snakeX[ 3] && len >  3) ||
                    (snakeY[0] - 1 == snakeY[ 4] && snakeX[0] == snakeX[ 4] && len >  4) ||
                    (snakeY[0] - 1 == snakeY[ 5] && snakeX[0] == snakeX[ 5] && len >  5) ||
                    (snakeY[0] - 1 == snakeY[ 6] && snakeX[0] == snakeX[ 6] && len >  6) ||
                    (snakeY[0] - 1 == snakeY[ 7] && snakeX[0] == snakeX[ 7] && len >  7) ||
                    (snakeY[0] - 1 == snakeY[ 8] && snakeX[0] == snakeX[ 8] && len >  8) ||
                    (snakeY[0] - 1 == snakeY[ 9] && snakeX[0] == snakeX[ 9] && len >  9) ||
                    (snakeY[0] - 1 == snakeY[10] && snakeX[0] == snakeX[10] && len > 10) ||
                    (snakeY[0] - 1 == snakeY[11] && snakeX[0] == snakeX[11] && len > 11) ||
                    (snakeY[0] - 1 == snakeY[12] && snakeX[0] == snakeX[12] && len > 12) ||
                    (snakeY[0] - 1 == snakeY[13] && snakeX[0] == snakeX[13] && len > 13) ||
                    (snakeY[0] - 1 == snakeY[14] && snakeX[0] == snakeX[14] && len > 14) ||
                    (snakeY[0] - 1 == snakeY[15] && snakeX[0] == snakeX[15] && len > 15) ||
                    (snakeY[0] - 1 == snakeY[16] && snakeX[0] == snakeX[16] && len > 16) ||
                    (snakeY[0] - 1 == snakeY[17] && snakeX[0] == snakeX[17] && len > 17) ||
                    (snakeY[0] - 1 == snakeY[18] && snakeX[0] == snakeX[18] && len > 18) ||
                    (snakeY[0] - 1 == snakeY[19] && snakeX[0] == snakeX[19] && len > 19) ||
                    (snakeY[0] - 1 == snakeY[20] && snakeX[0] == snakeX[20] && len > 20)
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end
                
                //this is the bumping detection of the lv1 map
                else if((s1_level_counter == 1)&&
                    ((snakeY[0] - 1 == 31 && snakeX[0] != 15 && snakeX[0] != 16 && snakeX[0] != 25 && snakeX[0] != 26
                     && snakeX[0] != 37 && snakeX[0] != 38 && snakeX[0] != 47 && snakeX[0] != 48) ||
                    ((snakeY[0] - 1 == 17 || snakeY[0] - 1 == 22 || snakeY[0] - 1 == 34 || snakeY[0] - 1 == 39) && 
                    snakeX[0] >= 30 && snakeX[0] <= 33))
                )begin
                    s3_health_reg <= s3_health_reg -1;

                end


                //this is the bumping detection of the lv2 map
                else if((s1_level_counter == 2)&&(
                    ((snakeY[0] == 23 || snakeY[0] == 31 || snakeY[0] == 39) && snakeX[0] >= 14 && snakeX[0] <= 16) ||
                    ((snakeY[0] == 23 || snakeY[0] == 31 || snakeY[0] == 39) && snakeX[0] >= 25 && snakeX[0] <= 27) ||
                    ((snakeY[0] == 23 || snakeY[0] == 31 || snakeY[0] == 39) && snakeX[0] >= 36 && snakeX[0] <= 38) ||
                    ((snakeY[0] == 23 || snakeY[0] == 31 || snakeY[0] == 39) && snakeX[0] >= 47 && snakeX[0] <= 49))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end
                //this is the bumping detection of the lv3 map(grren & red man)
                else if((s1_level_counter == 3)&&(
                (snakeY[0] == red_manY[ 2] + 1 && snakeX[0] == red_manX[ 2]) ||
                (snakeY[0] == red_manY[ 5] + 1 && snakeX[0] == red_manX[ 5]) ||
                (snakeY[0] == red_manY[14] + 1 && snakeX[0] == red_manX[14]) ||
                (snakeY[0] == red_manY[19] + 1 && snakeX[0] == red_manX[19]) ||
                (snakeY[0] == red_manY[38] + 1 && snakeX[0] == red_manX[38]) ||
                (snakeY[0] == red_manY[43] + 1 && snakeX[0] == red_manX[43]) ||
                (snakeY[0] == red_manY[48] + 1 && snakeX[0] == red_manX[48]) ||
                (snakeY[0] == red_manY[49] + 1 && snakeX[0] == red_manX[49]) ||
                (snakeY[0] == red_manY[50] + 1 && snakeX[0] == red_manX[50]) ||
                (snakeY[0] == red_manY[51] + 1 && snakeX[0] == red_manX[51]) ||
                (snakeY[0] == red_manY[58] + 1 && snakeX[0] == red_manX[58]) ||
                (snakeY[0] == red_manY[59] + 1 && snakeX[0] == red_manX[59]) ||
                (snakeY[0] == red_manY[60] + 1 && snakeX[0] == red_manX[60]) ||
                (snakeY[0] == red_manY[61] + 1 && snakeX[0] == red_manX[61]) ||

                (snakeY[0] == green_manY[ 2] + 1 && snakeX[0] == green_manX[ 2]) ||
                (snakeY[0] == green_manY[ 2] + 1 && snakeX[0] == green_manX[ 5]) ||
                (snakeY[0] == green_manY[ 6] + 1 && snakeX[0] == green_manX[ 6]) ||
                (snakeY[0] == green_manY[13] + 1 && snakeX[0] == green_manX[17]) ||
                (snakeY[0] == green_manY[13] + 1 && snakeX[0] == green_manX[18]) ||
                (snakeY[0] == green_manY[19] + 1 && snakeX[0] == green_manX[19]) ||
                (snakeY[0] == green_manY[19] + 1 && snakeX[0] == green_manX[22]) ||
                (snakeY[0] == green_manY[19] + 1 && snakeX[0] == green_manX[23]) ||
                (snakeY[0] == green_manY[24] + 1 && snakeX[0] == green_manX[24]) ||
                (snakeY[0] == green_manY[24] + 1 && snakeX[0] == green_manX[27]) ||
                (snakeY[0] == green_manY[28] + 1 && snakeX[0] == green_manX[28]) ||
                (snakeY[0] == green_manY[28] + 1 && snakeX[0] == green_manX[31]) ||
                (snakeY[0] == green_manY[32] + 1 && snakeX[0] == green_manX[32]) ||
                (snakeY[0] == green_manY[34] + 1 && snakeX[0] == green_manX[34]) ||
                (snakeY[0] == green_manY[34] + 1 && snakeX[0] == green_manX[36]) ||
                (snakeY[0] == green_manY[37] + 1 && snakeX[0] == green_manX[37]) ||
                (snakeY[0] == green_manY[37] + 1 && snakeX[0] == green_manX[38]) ||
                (snakeY[0] == green_manY[39] + 1 && snakeX[0] == green_manX[39]) ||
                (snakeY[0] == green_manY[39] + 1 && snakeX[0] == green_manX[40]) ||
                (snakeY[0] == green_manY[39] + 1 && snakeX[0] == green_manX[41]) ||
                (snakeY[0] == green_manY[39] + 1 && snakeX[0] == green_manX[42]) ||
                (snakeY[0] == green_manY[44] + 1 && snakeX[0] == green_manX[44]) ||
                (snakeY[0] == green_manY[44] + 1 && snakeX[0] == green_manX[45]) ||
                (snakeY[0] == green_manY[47] + 1 && snakeX[0] == green_manX[47]) ||
                (snakeY[0] == green_manY[48] + 1 && snakeX[0] == green_manX[48]))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end
                
            end
            4'b0010: begin //if the snake is moving right

                //the always on detection
                if(
                    (snakeX[0] == 56) ||
                    (snakeY[0] == snakeY[ 1] && snakeX[0] + 1 == snakeX [1] && len >  1) ||
                    (snakeY[0] == snakeY[ 2] && snakeX[0] + 1 == snakeX [2] && len >  2) ||
                    (snakeY[0] == snakeY[ 3] && snakeX[0] + 1 == snakeX [3] && len >  3) ||
                    (snakeY[0] == snakeY[ 4] && snakeX[0] + 1 == snakeX [4] && len >  4) ||
                    (snakeY[0] == snakeY[ 5] && snakeX[0] + 1 == snakeX [5] && len >  5) ||
                    (snakeY[0] == snakeY[ 6] && snakeX[0] + 1 == snakeX [6] && len >  6) ||
                    (snakeY[0] == snakeY[ 7] && snakeX[0] + 1 == snakeX [7] && len >  7) ||
                    (snakeY[0] == snakeY[ 8] && snakeX[0] + 1 == snakeX [8] && len >  8) ||
                    (snakeY[0] == snakeY[ 9] && snakeX[0] + 1 == snakeX [9] && len >  9) ||
                    (snakeY[0] == snakeY[10] && snakeX[0] + 1 == snakeX[10] && len > 10) ||
                    (snakeY[0] == snakeY[11] && snakeX[0] + 1 == snakeX[11] && len > 11) ||
                    (snakeY[0] == snakeY[12] && snakeX[0] + 1 == snakeX[12] && len > 12) ||
                    (snakeY[0] == snakeY[13] && snakeX[0] + 1 == snakeX[13] && len > 13) ||
                    (snakeY[0] == snakeY[14] && snakeX[0] + 1 == snakeX[14] && len > 14) ||
                    (snakeY[0] == snakeY[15] && snakeX[0] + 1 == snakeX[15] && len > 15) ||
                    (snakeY[0] == snakeY[16] && snakeX[0] + 1 == snakeX[16] && len > 16) ||
                    (snakeY[0] == snakeY[17] && snakeX[0] + 1 == snakeX[17] && len > 17) ||
                    (snakeY[0] == snakeY[18] && snakeX[0] + 1 == snakeX[18] && len > 18) ||
                    (snakeY[0] == snakeY[19] && snakeX[0] + 1 == snakeX[19] && len > 19) ||
                    (snakeY[0] == snakeY[20] && snakeX[0] + 1 == snakeX[20] && len > 20)
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end

                //bumping detection of the level 1 map
                else if((s1_level_counter == 1)&&(
                    (snakeX[0] + 1 == 30 && snakeY[0] != 18 && snakeY[0] != 19 && snakeY[0] != 23 && snakeY[0] != 24 
                    && snakeY[0] != 35 && snakeY[0] != 36 && snakeY[0] != 40 && snakeY[0] != 41)||
                    (snakeY[0] >= 28 && snakeY[0] <= 31 && (snakeX[0] == 16 || snakeX[0] == 26 || snakeX[0] == 38 || snakeX[0] == 48))) 
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end


                //bumping detection of the level 2 map
                else if((s1_level_counter == 2)&&(
                    ((snakeX[0] == 13 || snakeX[0] == 24 || snakeX[0] == 35 || snakeX[0] == 46) && snakeY[0] >= 20 && snakeY[0] <= 22) ||
                    ((snakeX[0] == 13 || snakeX[0] == 24 || snakeX[0] == 35 || snakeX[0] == 46) && snakeY[0] >= 28 && snakeY[0] <= 30) ||
                    ((snakeX[0] == 13 || snakeX[0] == 24 || snakeX[0] == 35 || snakeX[0] == 46) && snakeY[0] >= 36 && snakeY[0] <= 38))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end
                
                //bumping detection of the level 3 map
                else if((s1_level_counter == 3)&&(
                    (snakeY[0] == red_manY[ 0] && snakeX[0] == red_manX[ 0] - 1) ||
                    (snakeY[0] == red_manY[ 2] && snakeX[0] == red_manX[ 2] - 1) ||
                    (snakeY[0] == red_manY[ 6] && snakeX[0] == red_manX[ 6] - 1) ||
                    (snakeY[0] == red_manY[ 8] && snakeX[0] == red_manX[ 8] - 1) ||
                    (snakeY[0] == red_manY[10] && snakeX[0] == red_manX[10] - 1) ||
                    (snakeY[0] == red_manY[14] && snakeX[0] == red_manX[14] - 1) ||
                    (snakeY[0] == red_manY[20] && snakeX[0] == red_manX[20] - 1) ||
                    (snakeY[0] == red_manY[21] && snakeX[0] == red_manX[21] - 1) ||
                    (snakeY[0] == red_manY[25] && snakeX[0] == red_manX[25] - 1) ||
                    (snakeY[0] == red_manY[26] && snakeX[0] == red_manX[26] - 1) ||
                    (snakeY[0] == red_manY[27] && snakeX[0] == red_manX[27] - 1) ||
                    (snakeY[0] == red_manY[31] && snakeX[0] == red_manX[31] - 1) ||
                    (snakeY[0] == red_manY[32] && snakeX[0] == red_manX[32] - 1) ||
                    (snakeY[0] == red_manY[33] && snakeX[0] == red_manX[33] - 1) ||
                    (snakeY[0] == red_manY[37] && snakeX[0] == red_manX[37] - 1) ||
                    (snakeY[0] == red_manY[38] && snakeX[0] == red_manX[38] - 1) ||
                    (snakeY[0] == red_manY[39] && snakeX[0] == red_manX[39] - 1) ||
                    (snakeY[0] == red_manY[43] && snakeX[0] == red_manX[43] - 1) ||
                    (snakeY[0] == red_manY[44] && snakeX[0] == red_manX[44] - 1) ||
                    (snakeY[0] == red_manY[48] && snakeX[0] == red_manX[48] - 1) ||
                    (snakeY[0] == red_manY[52] && snakeX[0] == red_manX[52] - 1) ||
                    (snakeY[0] == red_manY[53] && snakeX[0] == red_manX[53] - 1) ||
                    (snakeY[0] == red_manY[54] && snakeX[0] == red_manX[54] - 1) ||
                    (snakeY[0] == red_manY[55] && snakeX[0] == red_manX[55] - 1) ||
                    (snakeY[0] == red_manY[56] && snakeX[0] == red_manX[56] - 1) ||
                    (snakeY[0] == red_manY[57] && snakeX[0] == red_manX[57] - 1) ||
                    (snakeY[0] == red_manY[58] && snakeX[0] == red_manX[58] - 1) ||
                    (snakeY[0] == red_manY[60] && snakeX[0] == red_manX[60] - 1) ||
                    (snakeY[0] == green_manY[ 0]  && snakeX[0] == green_manX[ 0] - 1)  ||
                    (snakeY[0] == green_manY[ 2]  && snakeX[0] == green_manX[ 2] - 1)  ||
                    (snakeY[0] == green_manY[ 6]  && snakeX[0] == green_manX[ 6] - 1)  ||
                    (snakeY[0] == green_manY[ 8]  && snakeX[0] == green_manX[ 8] - 1)  ||
                    (snakeY[0] == green_manY[10]  && snakeX[0] == green_manX[10] - 1)  ||
                    (snakeY[0] == green_manY[13]  && snakeX[0] == green_manX[13] - 1)  ||
                    (snakeY[0] == green_manY[19]  && snakeX[0] == green_manX[19] - 1)  ||
                    (snakeY[0] == green_manY[19]  && snakeX[0] == green_manX[23] - 1)  ||
                    (snakeY[0] == green_manY[24]  && snakeX[0] == green_manX[24] - 1)  ||
                    (snakeY[0] == green_manY[24]  && snakeX[0] == green_manX[25] - 1)  ||
                    (snakeY[0] == green_manY[24]  && snakeX[0] == green_manX[27] - 1)  ||
                    (snakeY[0] == green_manY[28]  && snakeX[0] == green_manX[28] - 1)  ||
                    (snakeY[0] == green_manY[28]  && snakeX[0] == green_manX[29] - 1)  ||
                    (snakeY[0] == green_manY[32]  && snakeX[0] == green_manX[32] - 1)  ||
                    (snakeY[0] == green_manY[34]  && snakeX[0] == green_manX[34] - 1)  || 
                    (snakeY[0] == green_manY[37]  && snakeX[0] == green_manX[37] - 1)  ||
                    (snakeY[0] == green_manY[37]  && snakeX[0] == green_manX[38] - 1)  ||
                    (snakeY[0] == green_manY[39]  && snakeX[0] == green_manX[39] - 1)  ||
                    (snakeY[0] == green_manY[39]  && snakeX[0] == green_manX[40] - 1)  ||
                    (snakeY[0] == green_manY[44]  && snakeX[0] == green_manX[44] - 1)  ||
                    (snakeY[0] == green_manY[44]  && snakeX[0] == green_manX[45] - 1)  ||
                    (snakeY[0] == green_manY[46]  && snakeX[0] == green_manX[46] - 1)  || 
                    (snakeY[0] == green_manY[47]  && snakeX[0] == green_manX[47] - 1) )
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end
            
            end
            4'b0100: begin //if the snake is moving down

                //the always on detection
                if(
                    (snakeY[0] == 44)                                                    ||
                    (snakeY[0] + 1 == snakeY[ 1] && snakeX[0] == snakeX[ 1] && len >  1) ||
                    (snakeY[0] + 1 == snakeY[ 2] && snakeX[0] == snakeX[ 2] && len >  2) ||
                    (snakeY[0] + 1 == snakeY[ 3] && snakeX[0] == snakeX[ 3] && len >  3) ||
                    (snakeY[0] + 1 == snakeY[ 4] && snakeX[0] == snakeX[ 4] && len >  4) ||
                    (snakeY[0] + 1 == snakeY[ 5] && snakeX[0] == snakeX[ 5] && len >  5) ||
                    (snakeY[0] + 1 == snakeY[ 6] && snakeX[0] == snakeX[ 6] && len >  6) ||
                    (snakeY[0] + 1 == snakeY[ 7] && snakeX[0] == snakeX[ 7] && len >  7) ||
                    (snakeY[0] + 1 == snakeY[ 8] && snakeX[0] == snakeX[ 8] && len >  8) ||
                    (snakeY[0] + 1 == snakeY[ 9] && snakeX[0] == snakeX[ 9] && len >  9) ||
                    (snakeY[0] + 1 == snakeY[10] && snakeX[0] == snakeX[10] && len > 10) ||
                    (snakeY[0] + 1 == snakeY[11] && snakeX[0] == snakeX[11] && len > 11) ||
                    (snakeY[0] + 1 == snakeY[12] && snakeX[0] == snakeX[12] && len > 12) ||
                    (snakeY[0] + 1 == snakeY[13] && snakeX[0] == snakeX[13] && len > 13) ||
                    (snakeY[0] + 1 == snakeY[14] && snakeX[0] == snakeX[14] && len > 14) ||
                    (snakeY[0] + 1 == snakeY[15] && snakeX[0] == snakeX[15] && len > 15) ||
                    (snakeY[0] + 1 == snakeY[16] && snakeX[0] == snakeX[16] && len > 16) ||
                    (snakeY[0] + 1 == snakeY[17] && snakeX[0] == snakeX[17] && len > 17) ||
                    (snakeY[0] + 1 == snakeY[18] && snakeX[0] == snakeX[18] && len > 18) ||
                    (snakeY[0] + 1 == snakeY[19] && snakeX[0] == snakeX[19] && len > 19) ||
                    (snakeY[0] + 1 == snakeY[20] && snakeX[0] == snakeX[20] && len > 20) 
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end
                //bumping detection for level 1 map
                else if((s1_level_counter == 1)&&(
                    (snakeY[0] + 1 == 28 && snakeX[0] != 15 && snakeX[0] != 16 && snakeX[0] != 25 && snakeX[0] != 26
                     && snakeX[0] != 37 && snakeX[0] != 38 && snakeX[0] != 47 && snakeX[0] != 48) ||
                    ((snakeY[0] + 1 == 20 || snakeY[0] + 1 == 25 || snakeY[0] + 1 == 37 || snakeY[0] + 1 == 42) && snakeX[0] >= 30 && snakeX[0] <= 33))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end

                //bumping detection for level 2 map
                else if((s1_level_counter == 2)&&(
                    ((snakeY[0] == 19 || snakeY[0] == 27 || snakeY[0] == 35) && snakeX[0] >= 14 && snakeX[0] <= 16) ||
                    ((snakeY[0] == 19 || snakeY[0] == 27 || snakeY[0] == 35) && snakeX[0] >= 25 && snakeX[0] <= 27) ||
                    ((snakeY[0] == 19 || snakeY[0] == 27 || snakeY[0] == 35) && snakeX[0] >= 36 && snakeX[0] <= 38) ||
                    ((snakeY[0] == 19 || snakeY[0] == 27 || snakeY[0] == 35) && snakeX[0] >= 47 && snakeX[0] <= 49))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end

                //bumping detection for level 3 map
                else if((s1_level_counter == 3)&&(
                    (snakeY[0] == red_manY[ 0] - 1 && snakeX[0] == red_manX[ 0]) ||
                    (snakeY[0] == red_manY[ 1] - 1 && snakeX[0] == red_manX[ 1]) ||
                    (snakeY[0] == red_manY[ 2] - 1 && snakeX[0] == red_manX[ 2]) ||
                    (snakeY[0] == red_manY[ 5] - 1 && snakeX[0] == red_manX[ 5]) ||
                    (snakeY[0] == red_manY[10] - 1 && snakeX[0] == red_manX[10]) ||
                    (snakeY[0] == red_manY[13] - 1 && snakeX[0] == red_manX[13]) ||
                    (snakeY[0] == red_manY[14] - 1 && snakeX[0] == red_manX[14]) ||
                    (snakeY[0] == red_manY[19] - 1 && snakeX[0] == red_manX[19]) ||
                    (snakeY[0] == red_manY[20] - 1 && snakeX[0] == red_manX[20]) ||
                    (snakeY[0] == red_manY[25] - 1 && snakeX[0] == red_manX[25]) ||
                    (snakeY[0] == red_manY[52] - 1 && snakeX[0] == red_manX[52]) ||
                    (snakeY[0] == red_manY[53] - 1 && snakeX[0] == red_manX[53]) ||
                    (snakeY[0] == red_manY[58] - 1 && snakeX[0] == red_manX[58]) ||
                    (snakeY[0] == red_manY[61] - 1 && snakeX[0] == red_manX[61]) ||

                    (snakeY[0] == green_manY[ 0] - 1 && (snakeX[0] == green_manX[0] || snakeX[0] == green_manX[1])) ||
                    (snakeY[0] == green_manY[ 2] - 1 && (snakeX[0] == green_manX[2] || snakeX[0] == green_manX[5])) ||
                    (snakeY[0] == green_manY[ 8] - 1 && snakeX[0] == green_manX[ 9]) ||
                    (snakeY[0] == green_manY[10] - 1 && snakeX[0] == green_manX[12]) ||
                    (snakeY[0] == green_manY[13] - 1 && (snakeX[0] == green_manX[13] || snakeX[0] == green_manX[17] || snakeX[0] == green_manX[18])) ||
                    (snakeY[0] == green_manY[19] - 1 && snakeX[0] == green_manX[23]) ||
                    (snakeY[0] == green_manY[24] - 1 && (snakeX[0] == green_manX[24] || snakeX[0] == green_manX[27])) ||
                    (snakeY[0] == green_manY[28] - 1 && (snakeX[0] == green_manX[28] || snakeX[0] == green_manX[31])) ||
                    (snakeY[0] == green_manY[34] - 1 && snakeX[0] == green_manX[36]) ||
                    (snakeY[0] == green_manY[37] - 1 && snakeX[0] == green_manX[38]) ||
                    (snakeY[0] == green_manY[39] - 1 && (snakeX[0] == green_manX[39] || snakeX[0] == green_manX[40] || snakeX[0] == green_manX[41] 
                    || snakeX[0] == green_manX[42] || snakeX[0] == green_manX[43])) ||
                    (snakeY[0] == green_manY[44] - 1 && snakeX[0] == green_manX[44]) ||
                    (snakeY[0] == green_manY[47] - 1 && snakeX[0] == green_manX[47]))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end

            end
            4'b1000: begin //if the snake is moving left
                //always on detection
                if(
                    (snakeX[0] == 7)                                                     ||
                    (snakeY[0] == snakeY[ 1] && snakeX[0] - 1 == snakeX[ 1] && len >  1) ||
                    (snakeY[0] == snakeY[ 2] && snakeX[0] - 1 == snakeX[ 2] && len >  2) ||
                    (snakeY[0] == snakeY[ 3] && snakeX[0] - 1 == snakeX[ 3] && len >  3) ||
                    (snakeY[0] == snakeY[ 4] && snakeX[0] - 1 == snakeX[ 4] && len >  4) ||
                    (snakeY[0] == snakeY[ 5] && snakeX[0] - 1 == snakeX[ 5] && len >  5) ||
                    (snakeY[0] == snakeY[ 6] && snakeX[0] - 1 == snakeX[ 6] && len >  6) ||
                    (snakeY[0] == snakeY[ 7] && snakeX[0] - 1 == snakeX[ 7] && len >  7) ||
                    (snakeY[0] == snakeY[ 8] && snakeX[0] - 1 == snakeX[ 8] && len >  8) ||
                    (snakeY[0] == snakeY[ 9] && snakeX[0] - 1 == snakeX[ 9] && len >  9) ||
                    (snakeY[0] == snakeY[10] && snakeX[0] - 1 == snakeX[10] && len > 10) ||
                    (snakeY[0] == snakeY[11] && snakeX[0] - 1 == snakeX[11] && len > 11) ||
                    (snakeY[0] == snakeY[12] && snakeX[0] - 1 == snakeX[12] && len > 12) ||
                    (snakeY[0] == snakeY[13] && snakeX[0] - 1 == snakeX[13] && len > 13) ||
                    (snakeY[0] == snakeY[14] && snakeX[0] - 1 == snakeX[14] && len > 14) ||
                    (snakeY[0] == snakeY[15] && snakeX[0] - 1 == snakeX[15] && len > 15) ||
                    (snakeY[0] == snakeY[16] && snakeX[0] - 1 == snakeX[16] && len > 16) ||
                    (snakeY[0] == snakeY[17] && snakeX[0] - 1 == snakeX[17] && len > 17) ||
                    (snakeY[0] == snakeY[18] && snakeX[0] - 1 == snakeX[18] && len > 18) ||
                    (snakeY[0] == snakeY[19] && snakeX[0] - 1 == snakeX[19] && len > 19) ||
                    (snakeY[0] == snakeY[20] && snakeX[0] - 1 == snakeX[20] && len > 20) 
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end
                //bump detection for level 1 map
                else if((s1_level_counter == 1)&&(
                    (snakeX[0] - 1 == 33 && snakeY[0] != 18 && snakeY[0] != 19 && snakeY[0] != 23 && snakeY[0] != 24 
                        && snakeY[0] != 35 && snakeY[0] != 36 && snakeY[0] != 40 && snakeY[0] != 41) ||
                    (snakeY[0] <= 31 && snakeY[0] >= 28 && (snakeX[0] == 15 || snakeX[0] == 25 || snakeX[0] == 37 || snakeX[0] == 47)))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end

                //bump detection for level 2 map
                else if((s1_level_counter == 2)&&(
                    ((snakeX[0] == 17 || snakeX[0] == 28 || snakeX[0] == 39 || snakeX[0] == 50) && snakeY[0] >= 20 && snakeY[0] <= 22) ||
                    ((snakeX[0] == 17 || snakeX[0] == 28 || snakeX[0] == 39 || snakeX[0] == 50) && snakeY[0] >= 28 && snakeY[0] <= 30) ||
                    ((snakeX[0] == 17 || snakeX[0] == 28 || snakeX[0] == 39 || snakeX[0] == 50) && snakeY[0] >= 36 && snakeY[0] <= 38))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end
                //bump detection for level 3 map
                else if((s1_level_counter == 3)&&(
                    (snakeY[0] == red_manY[ 1] && snakeX[0] == red_manX[ 1] + 1) ||
                    (snakeY[0] == red_manY[ 5] && snakeX[0] == red_manX[ 5] + 1) ||
                    (snakeY[0] == red_manY[ 7] && snakeX[0] == red_manX[ 7] + 1) ||
                    (snakeY[0] == red_manY[ 9] && snakeX[0] == red_manX[ 9] + 1) ||
                    (snakeY[0] == red_manY[13] && snakeX[0] == red_manX[13] + 1) ||
                    (snakeY[0] == red_manY[19] && snakeX[0] == red_manX[19] + 1) ||
                    (snakeY[0] == red_manY[20] && snakeX[0] == red_manX[20] + 1) ||
                    (snakeY[0] == red_manY[24] && snakeX[0] == red_manX[24] + 1) ||
                    (snakeY[0] == red_manY[25] && snakeX[0] == red_manX[25] + 1) ||
                    (snakeY[0] == red_manY[26] && snakeX[0] == red_manX[26] + 1) ||
                    (snakeY[0] == red_manY[30] && snakeX[0] == red_manX[30] + 1) ||
                    (snakeY[0] == red_manY[31] && snakeX[0] == red_manX[31] + 1) ||
                    (snakeY[0] == red_manY[32] && snakeX[0] == red_manX[32] + 1) ||
                    (snakeY[0] == red_manY[36] && snakeX[0] == red_manX[36] + 1) ||
                    (snakeY[0] == red_manY[37] && snakeX[0] == red_manX[37] + 1) ||
                    (snakeY[0] == red_manY[38] && snakeX[0] == red_manX[38] + 1) ||
                    (snakeY[0] == red_manY[42] && snakeX[0] == red_manX[42] + 1) ||
                    (snakeY[0] == red_manY[43] && snakeX[0] == red_manX[43] + 1) ||
                    (snakeY[0] == red_manY[47] && snakeX[0] == red_manX[47] + 1) ||
                    (snakeY[0] == red_manY[51] && snakeX[0] == red_manX[51] + 1) ||
                    (snakeY[0] == red_manY[52] && snakeX[0] == red_manX[52] + 1) ||
                    (snakeY[0] == red_manY[53] && snakeX[0] == red_manX[53] + 1) ||
                    (snakeY[0] == red_manY[54] && snakeX[0] == red_manX[54] + 1) ||
                    (snakeY[0] == red_manY[55] && snakeX[0] == red_manX[55] + 1) ||
                    (snakeY[0] == red_manY[56] && snakeX[0] == red_manX[56] + 1) ||
                    (snakeY[0] == red_manY[57] && snakeX[0] == red_manX[57] + 1) ||
                    (snakeY[0] == red_manY[59] && snakeX[0] == red_manX[59] + 1) ||
                    (snakeY[0] == red_manY[61] && snakeX[0] == red_manX[61] + 1) ||

                    (snakeY[0] == green_manY[ 0] && snakeX[0] == green_manX[ 1] + 1) ||
                    (snakeY[0] == green_manY[ 2] && snakeX[0] == green_manX[ 5] + 1) ||
                    (snakeY[0] == green_manY[ 6] && snakeX[0] == green_manX[ 7] + 1) ||
                    (snakeY[0] == green_manY[ 8] && snakeX[0] == green_manX[ 9] + 1) ||
                    (snakeY[0] == green_manY[10] && snakeX[0] == green_manX[12] + 1) ||
                    (snakeY[0] == green_manY[13] && snakeX[0] == green_manX[18] + 1) ||
                    (snakeY[0] == green_manY[19] && snakeX[0] == green_manX[22] + 1) ||
                    (snakeY[0] == green_manY[19] && snakeX[0] == green_manX[23] + 1) ||
                    (snakeY[0] == green_manY[24] && snakeX[0] == green_manX[24] + 1) ||
                    (snakeY[0] == green_manY[24] && snakeX[0] == green_manX[26] + 1) ||
                    (snakeY[0] == green_manY[24] && snakeX[0] == green_manX[27] + 1) ||
                    (snakeY[0] == green_manY[28] && snakeX[0] == green_manX[28] + 1) ||
                    (snakeY[0] == green_manY[28] && snakeX[0] == green_manX[31] + 1) ||
                    (snakeY[0] == green_manY[32] && snakeX[0] == green_manX[33] + 1) ||
                    (snakeY[0] == green_manY[34] && snakeX[0] == green_manX[36] + 1) ||
                    (snakeY[0] == green_manY[37] && snakeX[0] == green_manX[37] + 1) ||
                    (snakeY[0] == green_manY[37] && snakeX[0] == green_manX[38] + 1) ||
                    (snakeY[0] == green_manY[39] && snakeX[0] == green_manX[39] + 1) ||
                    (snakeY[0] == green_manY[39] && snakeX[0] == green_manX[43] + 1) ||
                    (snakeY[0] == green_manY[44] && snakeX[0] == green_manX[44] + 1) ||
                    (snakeY[0] == green_manY[44] && snakeX[0] == green_manX[45] + 1) ||
                    (snakeY[0] == green_manY[46] && snakeX[0] == green_manX[46] + 1) ||
                    (snakeY[0] == green_manY[47] && snakeX[0] == green_manX[48] + 1))
                )begin
                    s3_health_reg <= s3_health_reg -1;
                end

            end
            
        endcase
    end


  end
end


//this is the part of the collition detection 
always @(posedge clk) begin
    if(~reset_n || current_state == SPP) begin
        snake_clock <= 0;
    end
    else if(snake_clock == speed - 1) begin
        case(direction)
            4'b0001: begin // if the snake is moving up

                // the always on detections, 
                if(
                    (snakeY[0] == 15)                                                    ||
                    (snakeY[0] - 1 == snakeY[ 1] && snakeX[0] == snakeX[ 1] && len >  1) ||
                    (snakeY[0] - 1 == snakeY[ 2] && snakeX[0] == snakeX[ 2] && len >  2) ||
                    (snakeY[0] - 1 == snakeY[ 3] && snakeX[0] == snakeX[ 3] && len >  3) ||
                    (snakeY[0] - 1 == snakeY[ 4] && snakeX[0] == snakeX[ 4] && len >  4) ||
                    (snakeY[0] - 1 == snakeY[ 5] && snakeX[0] == snakeX[ 5] && len >  5) ||
                    (snakeY[0] - 1 == snakeY[ 6] && snakeX[0] == snakeX[ 6] && len >  6) ||
                    (snakeY[0] - 1 == snakeY[ 7] && snakeX[0] == snakeX[ 7] && len >  7) ||
                    (snakeY[0] - 1 == snakeY[ 8] && snakeX[0] == snakeX[ 8] && len >  8) ||
                    (snakeY[0] - 1 == snakeY[ 9] && snakeX[0] == snakeX[ 9] && len >  9) ||
                    (snakeY[0] - 1 == snakeY[10] && snakeX[0] == snakeX[10] && len > 10) ||
                    (snakeY[0] - 1 == snakeY[11] && snakeX[0] == snakeX[11] && len > 11) ||
                    (snakeY[0] - 1 == snakeY[12] && snakeX[0] == snakeX[12] && len > 12) ||
                    (snakeY[0] - 1 == snakeY[13] && snakeX[0] == snakeX[13] && len > 13) ||
                    (snakeY[0] - 1 == snakeY[14] && snakeX[0] == snakeX[14] && len > 14) ||
                    (snakeY[0] - 1 == snakeY[15] && snakeX[0] == snakeX[15] && len > 15) ||
                    (snakeY[0] - 1 == snakeY[16] && snakeX[0] == snakeX[16] && len > 16) ||
                    (snakeY[0] - 1 == snakeY[17] && snakeX[0] == snakeX[17] && len > 17) ||
                    (snakeY[0] - 1 == snakeY[18] && snakeX[0] == snakeX[18] && len > 18) ||
                    (snakeY[0] - 1 == snakeY[19] && snakeX[0] == snakeX[19] && len > 19) ||
                    (snakeY[0] - 1 == snakeY[20] && snakeX[0] == snakeX[20] && len > 20)
                )begin
                    snake_clock <= snake_clock + 2;
                end
                
                //this is the bumping detection of the lv1 map
                else if((s1_level_counter == 1)&&
                    ((snakeY[0] - 1 == 31 && snakeX[0] != 15 && snakeX[0] != 16 && snakeX[0] != 25 && snakeX[0] != 26
                     && snakeX[0] != 37 && snakeX[0] != 38 && snakeX[0] != 47 && snakeX[0] != 48) ||
                    ((snakeY[0] - 1 == 17 || snakeY[0] - 1 == 22 || snakeY[0] - 1 == 34 || snakeY[0] - 1 == 39) && 
                    snakeX[0] >= 30 && snakeX[0] <= 33))
                )begin
                    snake_clock <= snake_clock + 2;
                    
                end


                //this is the bumping detection of the lv2 map
                else if((s1_level_counter == 2)&&(
                    ((snakeY[0] == 23 || snakeY[0] == 31 || snakeY[0] == 39) && snakeX[0] >= 14 && snakeX[0] <= 16) ||
                    ((snakeY[0] == 23 || snakeY[0] == 31 || snakeY[0] == 39) && snakeX[0] >= 25 && snakeX[0] <= 27) ||
                    ((snakeY[0] == 23 || snakeY[0] == 31 || snakeY[0] == 39) && snakeX[0] >= 36 && snakeX[0] <= 38) ||
                    ((snakeY[0] == 23 || snakeY[0] == 31 || snakeY[0] == 39) && snakeX[0] >= 47 && snakeX[0] <= 49))
                )begin
                    snake_clock <= snake_clock + 2;
                end
                //this is the bumping detection of the lv3 map(grren & red man)
                else if((s1_level_counter == 3)&&(
                (snakeY[0] == red_manY[ 2] + 1 && snakeX[0] == red_manX[ 2]) ||
                (snakeY[0] == red_manY[ 5] + 1 && snakeX[0] == red_manX[ 5]) ||
                (snakeY[0] == red_manY[14] + 1 && snakeX[0] == red_manX[14]) ||
                (snakeY[0] == red_manY[19] + 1 && snakeX[0] == red_manX[19]) ||
                (snakeY[0] == red_manY[38] + 1 && snakeX[0] == red_manX[38]) ||
                (snakeY[0] == red_manY[43] + 1 && snakeX[0] == red_manX[43]) ||
                (snakeY[0] == red_manY[48] + 1 && snakeX[0] == red_manX[48]) ||
                (snakeY[0] == red_manY[49] + 1 && snakeX[0] == red_manX[49]) ||
                (snakeY[0] == red_manY[50] + 1 && snakeX[0] == red_manX[50]) ||
                (snakeY[0] == red_manY[51] + 1 && snakeX[0] == red_manX[51]) ||
                (snakeY[0] == red_manY[58] + 1 && snakeX[0] == red_manX[58]) ||
                (snakeY[0] == red_manY[59] + 1 && snakeX[0] == red_manX[59]) ||
                (snakeY[0] == red_manY[60] + 1 && snakeX[0] == red_manX[60]) ||
                (snakeY[0] == red_manY[61] + 1 && snakeX[0] == red_manX[61]) ||

                (snakeY[0] == green_manY[ 2] + 1 && snakeX[0] == green_manX[ 2]) ||
                (snakeY[0] == green_manY[ 2] + 1 && snakeX[0] == green_manX[ 5]) ||
                (snakeY[0] == green_manY[ 6] + 1 && snakeX[0] == green_manX[ 6]) ||
                (snakeY[0] == green_manY[13] + 1 && snakeX[0] == green_manX[17]) ||
                (snakeY[0] == green_manY[13] + 1 && snakeX[0] == green_manX[18]) ||
                (snakeY[0] == green_manY[19] + 1 && snakeX[0] == green_manX[19]) ||
                (snakeY[0] == green_manY[19] + 1 && snakeX[0] == green_manX[22]) ||
                (snakeY[0] == green_manY[19] + 1 && snakeX[0] == green_manX[23]) ||
                (snakeY[0] == green_manY[24] + 1 && snakeX[0] == green_manX[24]) ||
                (snakeY[0] == green_manY[24] + 1 && snakeX[0] == green_manX[27]) ||
                (snakeY[0] == green_manY[28] + 1 && snakeX[0] == green_manX[28]) ||
                (snakeY[0] == green_manY[28] + 1 && snakeX[0] == green_manX[31]) ||
                (snakeY[0] == green_manY[32] + 1 && snakeX[0] == green_manX[32]) ||
                (snakeY[0] == green_manY[34] + 1 && snakeX[0] == green_manX[34]) ||
                (snakeY[0] == green_manY[34] + 1 && snakeX[0] == green_manX[36]) ||
                (snakeY[0] == green_manY[37] + 1 && snakeX[0] == green_manX[37]) ||
                (snakeY[0] == green_manY[37] + 1 && snakeX[0] == green_manX[38]) ||
                (snakeY[0] == green_manY[39] + 1 && snakeX[0] == green_manX[39]) ||
                (snakeY[0] == green_manY[39] + 1 && snakeX[0] == green_manX[40]) ||
                (snakeY[0] == green_manY[39] + 1 && snakeX[0] == green_manX[41]) ||
                (snakeY[0] == green_manY[39] + 1 && snakeX[0] == green_manX[42]) ||
                (snakeY[0] == green_manY[44] + 1 && snakeX[0] == green_manX[44]) ||
                (snakeY[0] == green_manY[44] + 1 && snakeX[0] == green_manX[45]) ||
                (snakeY[0] == green_manY[47] + 1 && snakeX[0] == green_manX[47]) ||
                (snakeY[0] == green_manY[48] + 1 && snakeX[0] == green_manX[48]))
                )begin
                    snake_clock <= snake_clock +2;
                end
                else  snake_clock = snake_clock + 1;
            end
            4'b0010: begin //if the snake is moving right

                //the always on detection
                if(
                    (snakeX[0] == 56) ||
                    (snakeY[0] == snakeY[ 1] && snakeX[0] + 1 == snakeX [1] && len >  1) ||
                    (snakeY[0] == snakeY[ 2] && snakeX[0] + 1 == snakeX [2] && len >  2) ||
                    (snakeY[0] == snakeY[ 3] && snakeX[0] + 1 == snakeX [3] && len >  3) ||
                    (snakeY[0] == snakeY[ 4] && snakeX[0] + 1 == snakeX [4] && len >  4) ||
                    (snakeY[0] == snakeY[ 5] && snakeX[0] + 1 == snakeX [5] && len >  5) ||
                    (snakeY[0] == snakeY[ 6] && snakeX[0] + 1 == snakeX [6] && len >  6) ||
                    (snakeY[0] == snakeY[ 7] && snakeX[0] + 1 == snakeX [7] && len >  7) ||
                    (snakeY[0] == snakeY[ 8] && snakeX[0] + 1 == snakeX [8] && len >  8) ||
                    (snakeY[0] == snakeY[ 9] && snakeX[0] + 1 == snakeX [9] && len >  9) ||
                    (snakeY[0] == snakeY[10] && snakeX[0] + 1 == snakeX[10] && len > 10) ||
                    (snakeY[0] == snakeY[11] && snakeX[0] + 1 == snakeX[11] && len > 11) ||
                    (snakeY[0] == snakeY[12] && snakeX[0] + 1 == snakeX[12] && len > 12) ||
                    (snakeY[0] == snakeY[13] && snakeX[0] + 1 == snakeX[13] && len > 13) ||
                    (snakeY[0] == snakeY[14] && snakeX[0] + 1 == snakeX[14] && len > 14) ||
                    (snakeY[0] == snakeY[15] && snakeX[0] + 1 == snakeX[15] && len > 15) ||
                    (snakeY[0] == snakeY[16] && snakeX[0] + 1 == snakeX[16] && len > 16) ||
                    (snakeY[0] == snakeY[17] && snakeX[0] + 1 == snakeX[17] && len > 17) ||
                    (snakeY[0] == snakeY[18] && snakeX[0] + 1 == snakeX[18] && len > 18) ||
                    (snakeY[0] == snakeY[19] && snakeX[0] + 1 == snakeX[19] && len > 19) ||
                    (snakeY[0] == snakeY[20] && snakeX[0] + 1 == snakeX[20] && len > 20)
                )begin
                    snake_clock <= snake_clock + 2;
                end

                //bumping detection of the level 1 map
                else if((s1_level_counter == 1)&&(
                    (snakeX[0] + 1 == 30 && snakeY[0] != 18 && snakeY[0] != 19 && snakeY[0] != 23 && snakeY[0] != 24 
                    && snakeY[0] != 35 && snakeY[0] != 36 && snakeY[0] != 40 && snakeY[0] != 41)||
                    (snakeY[0] >= 28 && snakeY[0] <= 31 && (snakeX[0] == 16 || snakeX[0] == 26 || snakeX[0] == 38 || snakeX[0] == 48))) 
                )begin
                    snake_clock <= snake_clock + 2;
                end


                //bumping detection of the level 2 map
                else if((s1_level_counter == 2)&&(
                    ((snakeX[0] == 13 || snakeX[0] == 24 || snakeX[0] == 35 || snakeX[0] == 46) && snakeY[0] >= 20 && snakeY[0] <= 22) ||
                    ((snakeX[0] == 13 || snakeX[0] == 24 || snakeX[0] == 35 || snakeX[0] == 46) && snakeY[0] >= 28 && snakeY[0] <= 30) ||
                    ((snakeX[0] == 13 || snakeX[0] == 24 || snakeX[0] == 35 || snakeX[0] == 46) && snakeY[0] >= 36 && snakeY[0] <= 38))
                )begin
                    snake_clock <= snake_clock + 2;
                end
                
                //bumping detection of the level 3 map
                else if((s1_level_counter == 3)&&(
                    (snakeY[0] == red_manY[ 0] && snakeX[0] == red_manX[ 0] - 1) ||
                    (snakeY[0] == red_manY[ 2] && snakeX[0] == red_manX[ 2] - 1) ||
                    (snakeY[0] == red_manY[ 6] && snakeX[0] == red_manX[ 6] - 1) ||
                    (snakeY[0] == red_manY[ 8] && snakeX[0] == red_manX[ 8] - 1) ||
                    (snakeY[0] == red_manY[10] && snakeX[0] == red_manX[10] - 1) ||
                    (snakeY[0] == red_manY[14] && snakeX[0] == red_manX[14] - 1) ||
                    (snakeY[0] == red_manY[20] && snakeX[0] == red_manX[20] - 1) ||
                    (snakeY[0] == red_manY[21] && snakeX[0] == red_manX[21] - 1) ||
                    (snakeY[0] == red_manY[25] && snakeX[0] == red_manX[25] - 1) ||
                    (snakeY[0] == red_manY[26] && snakeX[0] == red_manX[26] - 1) ||
                    (snakeY[0] == red_manY[27] && snakeX[0] == red_manX[27] - 1) ||
                    (snakeY[0] == red_manY[31] && snakeX[0] == red_manX[31] - 1) ||
                    (snakeY[0] == red_manY[32] && snakeX[0] == red_manX[32] - 1) ||
                    (snakeY[0] == red_manY[33] && snakeX[0] == red_manX[33] - 1) ||
                    (snakeY[0] == red_manY[37] && snakeX[0] == red_manX[37] - 1) ||
                    (snakeY[0] == red_manY[38] && snakeX[0] == red_manX[38] - 1) ||
                    (snakeY[0] == red_manY[39] && snakeX[0] == red_manX[39] - 1) ||
                    (snakeY[0] == red_manY[43] && snakeX[0] == red_manX[43] - 1) ||
                    (snakeY[0] == red_manY[44] && snakeX[0] == red_manX[44] - 1) ||
                    (snakeY[0] == red_manY[48] && snakeX[0] == red_manX[48] - 1) ||
                    (snakeY[0] == red_manY[52] && snakeX[0] == red_manX[52] - 1) ||
                    (snakeY[0] == red_manY[53] && snakeX[0] == red_manX[53] - 1) ||
                    (snakeY[0] == red_manY[54] && snakeX[0] == red_manX[54] - 1) ||
                    (snakeY[0] == red_manY[55] && snakeX[0] == red_manX[55] - 1) ||
                    (snakeY[0] == red_manY[56] && snakeX[0] == red_manX[56] - 1) ||
                    (snakeY[0] == red_manY[57] && snakeX[0] == red_manX[57] - 1) ||
                    (snakeY[0] == red_manY[58] && snakeX[0] == red_manX[58] - 1) ||
                    (snakeY[0] == red_manY[60] && snakeX[0] == red_manX[60] - 1) ||
                    (snakeY[0] == green_manY[ 0]  && snakeX[0] == green_manX[ 0] - 1)  ||
                    (snakeY[0] == green_manY[ 2]  && snakeX[0] == green_manX[ 2] - 1)  ||
                    (snakeY[0] == green_manY[ 6]  && snakeX[0] == green_manX[ 6] - 1)  ||
                    (snakeY[0] == green_manY[ 8]  && snakeX[0] == green_manX[ 8] - 1)  ||
                    (snakeY[0] == green_manY[10]  && snakeX[0] == green_manX[10] - 1)  ||
                    (snakeY[0] == green_manY[13]  && snakeX[0] == green_manX[13] - 1)  ||
                    (snakeY[0] == green_manY[19]  && snakeX[0] == green_manX[19] - 1)  ||
                    (snakeY[0] == green_manY[19]  && snakeX[0] == green_manX[23] - 1)  ||
                    (snakeY[0] == green_manY[24]  && snakeX[0] == green_manX[24] - 1)  ||
                    (snakeY[0] == green_manY[24]  && snakeX[0] == green_manX[25] - 1)  ||
                    (snakeY[0] == green_manY[24]  && snakeX[0] == green_manX[27] - 1)  ||
                    (snakeY[0] == green_manY[28]  && snakeX[0] == green_manX[28] - 1)  ||
                    (snakeY[0] == green_manY[28]  && snakeX[0] == green_manX[29] - 1)  ||
                    (snakeY[0] == green_manY[32]  && snakeX[0] == green_manX[32] - 1)  ||
                    (snakeY[0] == green_manY[34]  && snakeX[0] == green_manX[34] - 1)  || 
                    (snakeY[0] == green_manY[37]  && snakeX[0] == green_manX[37] - 1)  ||
                    (snakeY[0] == green_manY[37]  && snakeX[0] == green_manX[38] - 1)  ||
                    (snakeY[0] == green_manY[39]  && snakeX[0] == green_manX[39] - 1)  ||
                    (snakeY[0] == green_manY[39]  && snakeX[0] == green_manX[40] - 1)  ||
                    (snakeY[0] == green_manY[44]  && snakeX[0] == green_manX[44] - 1)  ||
                    (snakeY[0] == green_manY[44]  && snakeX[0] == green_manX[45] - 1)  ||
                    (snakeY[0] == green_manY[46]  && snakeX[0] == green_manX[46] - 1)  || 
                    (snakeY[0] == green_manY[47]  && snakeX[0] == green_manX[47] - 1) )
                )begin
                    snake_clock <= snake_clock + 2;
                end
                else snake_clock = snake_clock + 1;
            
            end
            4'b0100: begin //if the snake is moving down

                //the always on detection
                if(
                    (snakeY[0] == 44)                                                    ||
                    (snakeY[0] + 1 == snakeY[ 1] && snakeX[0] == snakeX[ 1] && len >  1) ||
                    (snakeY[0] + 1 == snakeY[ 2] && snakeX[0] == snakeX[ 2] && len >  2) ||
                    (snakeY[0] + 1 == snakeY[ 3] && snakeX[0] == snakeX[ 3] && len >  3) ||
                    (snakeY[0] + 1 == snakeY[ 4] && snakeX[0] == snakeX[ 4] && len >  4) ||
                    (snakeY[0] + 1 == snakeY[ 5] && snakeX[0] == snakeX[ 5] && len >  5) ||
                    (snakeY[0] + 1 == snakeY[ 6] && snakeX[0] == snakeX[ 6] && len >  6) ||
                    (snakeY[0] + 1 == snakeY[ 7] && snakeX[0] == snakeX[ 7] && len >  7) ||
                    (snakeY[0] + 1 == snakeY[ 8] && snakeX[0] == snakeX[ 8] && len >  8) ||
                    (snakeY[0] + 1 == snakeY[ 9] && snakeX[0] == snakeX[ 9] && len >  9) ||
                    (snakeY[0] + 1 == snakeY[10] && snakeX[0] == snakeX[10] && len > 10) ||
                    (snakeY[0] + 1 == snakeY[11] && snakeX[0] == snakeX[11] && len > 11) ||
                    (snakeY[0] + 1 == snakeY[12] && snakeX[0] == snakeX[12] && len > 12) ||
                    (snakeY[0] + 1 == snakeY[13] && snakeX[0] == snakeX[13] && len > 13) ||
                    (snakeY[0] + 1 == snakeY[14] && snakeX[0] == snakeX[14] && len > 14) ||
                    (snakeY[0] + 1 == snakeY[15] && snakeX[0] == snakeX[15] && len > 15) ||
                    (snakeY[0] + 1 == snakeY[16] && snakeX[0] == snakeX[16] && len > 16) ||
                    (snakeY[0] + 1 == snakeY[17] && snakeX[0] == snakeX[17] && len > 17) ||
                    (snakeY[0] + 1 == snakeY[18] && snakeX[0] == snakeX[18] && len > 18) ||
                    (snakeY[0] + 1 == snakeY[19] && snakeX[0] == snakeX[19] && len > 19) ||
                    (snakeY[0] + 1 == snakeY[20] && snakeX[0] == snakeX[20] && len > 20) 
                )begin
                    snake_clock <= snake_clock + 2;
                end
                //bumping detection for level 1 map
                else if((s1_level_counter == 1)&&(
                    (snakeY[0] + 1 == 28 && snakeX[0] != 15 && snakeX[0] != 16 && snakeX[0] != 25 && snakeX[0] != 26
                     && snakeX[0] != 37 && snakeX[0] != 38 && snakeX[0] != 47 && snakeX[0] != 48) ||
                    ((snakeY[0] + 1 == 20 || snakeY[0] + 1 == 25 || snakeY[0] + 1 == 37 || snakeY[0] + 1 == 42) && snakeX[0] >= 30 && snakeX[0] <= 33))
                )begin
                    snake_clock <= snake_clock + 2;
                end

                //bumping detection for level 2 map
                else if((s1_level_counter == 2)&&(
                    ((snakeY[0] == 19 || snakeY[0] == 27 || snakeY[0] == 35) && snakeX[0] >= 14 && snakeX[0] <= 16) ||
                    ((snakeY[0] == 19 || snakeY[0] == 27 || snakeY[0] == 35) && snakeX[0] >= 25 && snakeX[0] <= 27) ||
                    ((snakeY[0] == 19 || snakeY[0] == 27 || snakeY[0] == 35) && snakeX[0] >= 36 && snakeX[0] <= 38) ||
                    ((snakeY[0] == 19 || snakeY[0] == 27 || snakeY[0] == 35) && snakeX[0] >= 47 && snakeX[0] <= 49))
                )begin
                    snake_clock <= snake_clock + 2;
                end

                //bumping detection for level 3 map
                else if((s1_level_counter == 3)&&(
                    (snakeY[0] == red_manY[ 0] - 1 && snakeX[0] == red_manX[ 0]) ||
                    (snakeY[0] == red_manY[ 1] - 1 && snakeX[0] == red_manX[ 1]) ||
                    (snakeY[0] == red_manY[ 2] - 1 && snakeX[0] == red_manX[ 2]) ||
                    (snakeY[0] == red_manY[ 5] - 1 && snakeX[0] == red_manX[ 5]) ||
                    (snakeY[0] == red_manY[10] - 1 && snakeX[0] == red_manX[10]) ||
                    (snakeY[0] == red_manY[13] - 1 && snakeX[0] == red_manX[13]) ||
                    (snakeY[0] == red_manY[14] - 1 && snakeX[0] == red_manX[14]) ||
                    (snakeY[0] == red_manY[19] - 1 && snakeX[0] == red_manX[19]) ||
                    (snakeY[0] == red_manY[20] - 1 && snakeX[0] == red_manX[20]) ||
                    (snakeY[0] == red_manY[25] - 1 && snakeX[0] == red_manX[25]) ||
                    (snakeY[0] == red_manY[52] - 1 && snakeX[0] == red_manX[52]) ||
                    (snakeY[0] == red_manY[53] - 1 && snakeX[0] == red_manX[53]) ||
                    (snakeY[0] == red_manY[58] - 1 && snakeX[0] == red_manX[58]) ||
                    (snakeY[0] == red_manY[61] - 1 && snakeX[0] == red_manX[61]) ||

                    (snakeY[0] == green_manY[ 0] - 1 && (snakeX[0] == green_manX[0] || snakeX[0] == green_manX[1])) ||
                    (snakeY[0] == green_manY[ 2] - 1 && (snakeX[0] == green_manX[2] || snakeX[0] == green_manX[5])) ||
                    (snakeY[0] == green_manY[ 8] - 1 && snakeX[0] == green_manX[ 9]) ||
                    (snakeY[0] == green_manY[10] - 1 && snakeX[0] == green_manX[12]) ||
                    (snakeY[0] == green_manY[13] - 1 && (snakeX[0] == green_manX[13] || snakeX[0] == green_manX[17] || snakeX[0] == green_manX[18])) ||
                    (snakeY[0] == green_manY[19] - 1 && snakeX[0] == green_manX[23]) ||
                    (snakeY[0] == green_manY[24] - 1 && (snakeX[0] == green_manX[24] || snakeX[0] == green_manX[27])) ||
                    (snakeY[0] == green_manY[28] - 1 && (snakeX[0] == green_manX[28] || snakeX[0] == green_manX[31])) ||
                    (snakeY[0] == green_manY[34] - 1 && snakeX[0] == green_manX[36]) ||
                    (snakeY[0] == green_manY[37] - 1 && snakeX[0] == green_manX[38]) ||
                    (snakeY[0] == green_manY[39] - 1 && (snakeX[0] == green_manX[39] || snakeX[0] == green_manX[40] || snakeX[0] == green_manX[41] 
                    || snakeX[0] == green_manX[42] || snakeX[0] == green_manX[43])) ||
                    (snakeY[0] == green_manY[44] - 1 && snakeX[0] == green_manX[44]) ||
                    (snakeY[0] == green_manY[47] - 1 && snakeX[0] == green_manX[47]))
                )begin
                    snake_clock <= snake_clock + 2;
                end
                else snake_clock = snake_clock + 1;

            end
            4'b1000: begin //if the snake is moving left
                //always on detection
                if(
                    (snakeX[0] == 7)                                                     ||
                    (snakeY[0] == snakeY[ 1] && snakeX[0] - 1 == snakeX[ 1] && len >  1) ||
                    (snakeY[0] == snakeY[ 2] && snakeX[0] - 1 == snakeX[ 2] && len >  2) ||
                    (snakeY[0] == snakeY[ 3] && snakeX[0] - 1 == snakeX[ 3] && len >  3) ||
                    (snakeY[0] == snakeY[ 4] && snakeX[0] - 1 == snakeX[ 4] && len >  4) ||
                    (snakeY[0] == snakeY[ 5] && snakeX[0] - 1 == snakeX[ 5] && len >  5) ||
                    (snakeY[0] == snakeY[ 6] && snakeX[0] - 1 == snakeX[ 6] && len >  6) ||
                    (snakeY[0] == snakeY[ 7] && snakeX[0] - 1 == snakeX[ 7] && len >  7) ||
                    (snakeY[0] == snakeY[ 8] && snakeX[0] - 1 == snakeX[ 8] && len >  8) ||
                    (snakeY[0] == snakeY[ 9] && snakeX[0] - 1 == snakeX[ 9] && len >  9) ||
                    (snakeY[0] == snakeY[10] && snakeX[0] - 1 == snakeX[10] && len > 10) ||
                    (snakeY[0] == snakeY[11] && snakeX[0] - 1 == snakeX[11] && len > 11) ||
                    (snakeY[0] == snakeY[12] && snakeX[0] - 1 == snakeX[12] && len > 12) ||
                    (snakeY[0] == snakeY[13] && snakeX[0] - 1 == snakeX[13] && len > 13) ||
                    (snakeY[0] == snakeY[14] && snakeX[0] - 1 == snakeX[14] && len > 14) ||
                    (snakeY[0] == snakeY[15] && snakeX[0] - 1 == snakeX[15] && len > 15) ||
                    (snakeY[0] == snakeY[16] && snakeX[0] - 1 == snakeX[16] && len > 16) ||
                    (snakeY[0] == snakeY[17] && snakeX[0] - 1 == snakeX[17] && len > 17) ||
                    (snakeY[0] == snakeY[18] && snakeX[0] - 1 == snakeX[18] && len > 18) ||
                    (snakeY[0] == snakeY[19] && snakeX[0] - 1 == snakeX[19] && len > 19) ||
                    (snakeY[0] == snakeY[20] && snakeX[0] - 1 == snakeX[20] && len > 20) 
                )begin
                    snake_clock <= snake_clock + 2;
                end
                //bump detection for level 1 map
                else if((s1_level_counter == 1)&&(
                    (snakeX[0] - 1 == 33 && snakeY[0] != 18 && snakeY[0] != 19 && snakeY[0] != 23 && snakeY[0] != 24 
                        && snakeY[0] != 35 && snakeY[0] != 36 && snakeY[0] != 40 && snakeY[0] != 41) ||
                    (snakeY[0] <= 31 && snakeY[0] >= 28 && (snakeX[0] == 15 || snakeX[0] == 25 || snakeX[0] == 37 || snakeX[0] == 47)))
                )begin
                    snake_clock <= snake_clock + 2;
                end

                //bump detection for level 2 map
                else if((s1_level_counter == 2)&&(
                    ((snakeX[0] == 17 || snakeX[0] == 28 || snakeX[0] == 39 || snakeX[0] == 50) && snakeY[0] >= 20 && snakeY[0] <= 22) ||
                    ((snakeX[0] == 17 || snakeX[0] == 28 || snakeX[0] == 39 || snakeX[0] == 50) && snakeY[0] >= 28 && snakeY[0] <= 30) ||
                    ((snakeX[0] == 17 || snakeX[0] == 28 || snakeX[0] == 39 || snakeX[0] == 50) && snakeY[0] >= 36 && snakeY[0] <= 38))
                )begin
                    snake_clock <= snake_clock + 2;
                end
                //bump detection for level 3 map
                else if((s1_level_counter == 3)&&(
                    (snakeY[0] == red_manY[ 1] && snakeX[0] == red_manX[ 1] + 1) ||
                    (snakeY[0] == red_manY[ 5] && snakeX[0] == red_manX[ 5] + 1) ||
                    (snakeY[0] == red_manY[ 7] && snakeX[0] == red_manX[ 7] + 1) ||
                    (snakeY[0] == red_manY[ 9] && snakeX[0] == red_manX[ 9] + 1) ||
                    (snakeY[0] == red_manY[13] && snakeX[0] == red_manX[13] + 1) ||
                    (snakeY[0] == red_manY[19] && snakeX[0] == red_manX[19] + 1) ||
                    (snakeY[0] == red_manY[20] && snakeX[0] == red_manX[20] + 1) ||
                    (snakeY[0] == red_manY[24] && snakeX[0] == red_manX[24] + 1) ||
                    (snakeY[0] == red_manY[25] && snakeX[0] == red_manX[25] + 1) ||
                    (snakeY[0] == red_manY[26] && snakeX[0] == red_manX[26] + 1) ||
                    (snakeY[0] == red_manY[30] && snakeX[0] == red_manX[30] + 1) ||
                    (snakeY[0] == red_manY[31] && snakeX[0] == red_manX[31] + 1) ||
                    (snakeY[0] == red_manY[32] && snakeX[0] == red_manX[32] + 1) ||
                    (snakeY[0] == red_manY[36] && snakeX[0] == red_manX[36] + 1) ||
                    (snakeY[0] == red_manY[37] && snakeX[0] == red_manX[37] + 1) ||
                    (snakeY[0] == red_manY[38] && snakeX[0] == red_manX[38] + 1) ||
                    (snakeY[0] == red_manY[42] && snakeX[0] == red_manX[42] + 1) ||
                    (snakeY[0] == red_manY[43] && snakeX[0] == red_manX[43] + 1) ||
                    (snakeY[0] == red_manY[47] && snakeX[0] == red_manX[47] + 1) ||
                    (snakeY[0] == red_manY[51] && snakeX[0] == red_manX[51] + 1) ||
                    (snakeY[0] == red_manY[52] && snakeX[0] == red_manX[52] + 1) ||
                    (snakeY[0] == red_manY[53] && snakeX[0] == red_manX[53] + 1) ||
                    (snakeY[0] == red_manY[54] && snakeX[0] == red_manX[54] + 1) ||
                    (snakeY[0] == red_manY[55] && snakeX[0] == red_manX[55] + 1) ||
                    (snakeY[0] == red_manY[56] && snakeX[0] == red_manX[56] + 1) ||
                    (snakeY[0] == red_manY[57] && snakeX[0] == red_manX[57] + 1) ||
                    (snakeY[0] == red_manY[59] && snakeX[0] == red_manX[59] + 1) ||
                    (snakeY[0] == red_manY[61] && snakeX[0] == red_manX[61] + 1) ||

                    (snakeY[0] == green_manY[ 0] && snakeX[0] == green_manX[ 1] + 1) ||
                    (snakeY[0] == green_manY[ 2] && snakeX[0] == green_manX[ 5] + 1) ||
                    (snakeY[0] == green_manY[ 6] && snakeX[0] == green_manX[ 7] + 1) ||
                    (snakeY[0] == green_manY[ 8] && snakeX[0] == green_manX[ 9] + 1) ||
                    (snakeY[0] == green_manY[10] && snakeX[0] == green_manX[12] + 1) ||
                    (snakeY[0] == green_manY[13] && snakeX[0] == green_manX[18] + 1) ||
                    (snakeY[0] == green_manY[19] && snakeX[0] == green_manX[22] + 1) ||
                    (snakeY[0] == green_manY[19] && snakeX[0] == green_manX[23] + 1) ||
                    (snakeY[0] == green_manY[24] && snakeX[0] == green_manX[24] + 1) ||
                    (snakeY[0] == green_manY[24] && snakeX[0] == green_manX[26] + 1) ||
                    (snakeY[0] == green_manY[24] && snakeX[0] == green_manX[27] + 1) ||
                    (snakeY[0] == green_manY[28] && snakeX[0] == green_manX[28] + 1) ||
                    (snakeY[0] == green_manY[28] && snakeX[0] == green_manX[31] + 1) ||
                    (snakeY[0] == green_manY[32] && snakeX[0] == green_manX[33] + 1) ||
                    (snakeY[0] == green_manY[34] && snakeX[0] == green_manX[36] + 1) ||
                    (snakeY[0] == green_manY[37] && snakeX[0] == green_manX[37] + 1) ||
                    (snakeY[0] == green_manY[37] && snakeX[0] == green_manX[38] + 1) ||
                    (snakeY[0] == green_manY[39] && snakeX[0] == green_manX[39] + 1) ||
                    (snakeY[0] == green_manY[39] && snakeX[0] == green_manX[43] + 1) ||
                    (snakeY[0] == green_manY[44] && snakeX[0] == green_manX[44] + 1) ||
                    (snakeY[0] == green_manY[44] && snakeX[0] == green_manX[45] + 1) ||
                    (snakeY[0] == green_manY[46] && snakeX[0] == green_manX[46] + 1) ||
                    (snakeY[0] == green_manY[47] && snakeX[0] == green_manX[48] + 1))
                )begin
                    snake_clock <= snake_clock + 2;
                end
                else snake_clock <= snake_clock + 1;

            end
            
        endcase
    end
    else if(snake_clock > speed) snake_clock <= 0;
    else snake_clock <= snake_clock + 1;
end

always @ (posedge clk) begin
    if(~reset_n || current_state == SPP) begin
        len <= 5;
        for(i = 0; i < 20; i = i + 1) begin
            snakeX[i] <= 30 - i;
            snakeY[i] <= 18;  //address of all segments assigned to 0 
        end
    end
    else begin
        case(direction)
            4'b0001: snakeY[0] <= (snake_clock == speed) ? snakeY[0] - 1 : snakeY[0]; //move up
            4'b0010: snakeX[0] <= (snake_clock == speed) ? snakeX[0] + 1 : snakeX[0]; //move right
            4'b0100: snakeY[0] <= (snake_clock == speed) ? snakeY[0] + 1 : snakeY[0]; //move down
            4'b1000: snakeX[0] <= (snake_clock == speed) ? snakeX[0] - 1 : snakeX[0]; //move left
        endcase
        if(snake_clock == speed) begin
            for(i = 0; i < 19; i = i + 1) begin
                snakeX[i+1] <= snakeX[i];
                snakeY[i+1] <= snakeY[i];
            end
        end
		if(Q == IDLE && Q_next == GEN && len < 20) len <= len + 1;
		else if(K == IDLE && K_next == GEN && len < 20) len <= len + 1;
    end
end
always @(*) begin
  
  if (~video_on) rgb_next = 12'h000; 
  
  else if (current_state == S0) begin
    if ((s0p1_region) && (s0p1_sram_out != 12'h0f0))
      rgb_next = s0p1_sram_out; 
    else if ((s0p2_region) &&(s0p2_sram_out != 12'h0f0))
      rgb_next = s0p2_sram_out; 
    else if ((s0p3_region) &&(s0p3_sram_out != 12'h0f0)&&(second_counter <= 50_000_000))
      rgb_next = 12'hfff; 
    else
      rgb_next = 12'h000;
  end
                                                                                                   
  else if (current_state == S1) begin
    if (s1snake_region &&(s0p2_sram_out != 12'h0f0)) 
      rgb_next = s0p2_sram_out; 
    else if((s1l1_region||s1v1_region)&&(s1lv123_sram_out)!= 12'h0f0)
      rgb_next = (s1_level_counter==1)?12'h38a:12'h222;
    else if((s1l2_region||s1v2_region)&&(s1lv123_sram_out)!= 12'h0f0)
      rgb_next = (s1_level_counter==2)?12'h38a:12'h222;
    else if((s1l3_region||s1v3_region)&&(s1lv123_sram_out)!= 12'h0f0)
      rgb_next = (s1_level_counter==3)?12'h38a:12'h222;
    else if(s1lv1s_region && (s4_sram_out!= 12'h0f0)&& (s1_level_counter==1) )
      rgb_next = s4_sram_out;
    else if(s1lv2s_region && (s4_sram_out!= 12'h0f0)&& (s1_level_counter==2) )
      rgb_next = s4_sram_out;
    else if(s1lv3s_region && (s4_sram_out!= 12'h0f0)&& (s1_level_counter==3) )
      rgb_next = s4_sram_out;

    else if((s1b1_region||s1b2_region||s1b3_region||s1b4_region)&&(s1btnctrl_sram_out)!= 12'h0f0)
      rgb_next = 12'h47e;
    else if((s1b1i_region||s1b2i_region||s1b3i_region||s1b4i_region)&&(s1btnctrl_sram_out)!= 12'h0f0)
      rgb_next = 12'h47e;
    else rgb_next = 12'h000;

  end
  else if((current_state == SL1)||(current_state == SL2) || (current_state == SL3))begin

        if	   (pixel_x >= 70+ apple_x*10 && pixel_y >= 150 + apple_y*10 && pixel_x < 80 + apple_x*10 && pixel_y < 160 + apple_y*10)
            rgb_next = apple[pixel_x - (70 + apple_x*10)][pixel_y - (150 + apple_y*10)]; //for drawing apple/*
        else if(pixel_x >= 70+ berry_x*10 && pixel_y >= 150 + berry_y*10 && pixel_x < 80 + berry_x*10 && pixel_y < 160 + berry_y*10)
            rgb_next = berry[pixel_y - (150 + berry_y*10)][pixel_x - (70 + berry_x*10)]; //for drawing berry/*
        else if(len > 0 && pixel_x >= snakeX[0]*10 && pixel_x < snakeX[0]*10 + 10
                && pixel_y >= snakeY[0]*10 && pixel_y < snakeY[0]*10 + 10) begin
                rgb_next = 12'hff0; // head of the snake
        end
        else if(len > 1 && pixel_x >= snakeX[1]*10 && pixel_x < snakeX[1]*10 + 10
            && pixel_y >= snakeY[1]*10 && pixel_y < snakeY[1]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake
        end
        else if(len > 2 && pixel_x >= snakeX[2]*10 && pixel_x < snakeX[2]*10 + 10
            && pixel_y >= snakeY[2]*10 && pixel_y < snakeY[2]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake
        end
        else if(len > 3 && pixel_x >= snakeX[3]*10 && pixel_x < snakeX[3]*10 + 10
            && pixel_y >= snakeY[3]*10 && pixel_y < snakeY[3]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake
        end
        else if(len > 4 && pixel_x >= snakeX[4]*10 && pixel_x < snakeX[4]*10 + 10
            && pixel_y >= snakeY[4]*10 && pixel_y < snakeY[4]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake
        end
        else if(len > 5 && pixel_x >= snakeX[5]*10 && pixel_x < snakeX[5]*10 + 10
            && pixel_y >= snakeY[5]*10 && pixel_y < snakeY[5]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake
        end
        else if(len > 6 && pixel_x >= snakeX[6]*10 && pixel_x < snakeX[6]*10 + 10
            && pixel_y >= snakeY[6]*10 && pixel_y < snakeY[6]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake    
        end  
        else if(len > 7 && pixel_x >= snakeX[7]*10 && pixel_x < snakeX[7]*10 + 10
            && pixel_y >= snakeY[7]*10 && pixel_y < snakeY[7]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 8 && pixel_x >= snakeX[8]*10 && pixel_x < snakeX[8]*10 + 10
            && pixel_y >= snakeY[8]*10 && pixel_y < snakeY[8]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 9 && pixel_x >= snakeX[9]*10 && pixel_x < snakeX[9]*10 + 10
            && pixel_y >= snakeY[9]*10 && pixel_y < snakeY[9]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 10 && pixel_x >= snakeX[10]*10 && pixel_x < snakeX[10]*10 + 10
            && pixel_y >= snakeY[10]*10 && pixel_y < snakeY[10]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 11 && pixel_x >= snakeX[11]*10 && pixel_x < snakeX[11]*10 + 10
            && pixel_y >= snakeY[11]*10 && pixel_y < snakeY[11]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 12 && pixel_x >= snakeX[12]*10 && pixel_x < snakeX[12]*10 + 10
            && pixel_y >= snakeY[12]*10 && pixel_y < snakeY[12]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 13 && pixel_x >= snakeX[13]*10 && pixel_x < snakeX[13]*10 + 10
            && pixel_y >= snakeY[13]*10 && pixel_y < snakeY[13]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 14 && pixel_x >= snakeX[14]*10 && pixel_x < snakeX[14]*10 + 10
            && pixel_y >= snakeY[14]*10 && pixel_y < snakeY[14]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 15 && pixel_x >= snakeX[15]*10 && pixel_x < snakeX[15]*10 + 10
            && pixel_y >= snakeY[15]*10 && pixel_y < snakeY[15]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 16 && pixel_x >= snakeX[16]*10 && pixel_x < snakeX[16]*10 + 10
            && pixel_y >= snakeY[16]*10 && pixel_y < snakeY[16]*10 + 10) begin
                rgb_next = 12'h095; //body of the snake   
        end
        else if(len > 17 && pixel_x >= snakeX[17]*10 && pixel_x < snakeX[17]*10 + 10
            && pixel_y >= snakeY[17]*10 && pixel_y < snakeY[17]*10 + 10) begin
                rgb_next = 12'h095;  //body of the snake  
        end
        else if(len > 18 && pixel_x >= snakeX[18]*10 && pixel_x < snakeX[18]*10 + 10
            && pixel_y >= snakeY[18]*10 && pixel_y < snakeY[18]*10 + 10) begin
                rgb_next = 12'h095;  //body of the snake  
        end
        else if(len > 19 && pixel_x >= snakeX[19]*10 && pixel_x < snakeX[19]*10 + 10
            && pixel_y >= snakeY[19]*10 && pixel_y < snakeY[19]*10 + 10) begin
                rgb_next = 12'h095;  //body of the snake  
        end   
            //for the frame of the game (always on )
        else if(pixel_x >= 60 && pixel_x < 570 && pixel_y >= 450 && pixel_y < 460) rgb_next = 12'hfff;
        else if(pixel_x >= 570 && pixel_x < 580 && pixel_y >= 140 && pixel_y < 460) rgb_next = 12'hfff;
        else if(pixel_x >= 60 && pixel_x < 570 && pixel_y >= 140 && pixel_y < 150) rgb_next = 12'hfff;
        else if(pixel_x >= 60 && pixel_x < 70 && pixel_y >= 140 && pixel_y < 460) rgb_next = 12'hfff;
        
        //scenery of  level 1 map :
        else if(s1_level_counter == 1)begin
            if(pixel_x >= 300 && pixel_x < 340 && pixel_y >= 150 && pixel_y < 180) rgb_next = 12'hfff;
            else if(pixel_x >= 300 && pixel_x < 340 && pixel_y >= 200 && pixel_y < 230) rgb_next = 12'hfff;
            else if(pixel_x >= 300 && pixel_x < 340 && pixel_y >= 250 && pixel_y < 350) rgb_next = 12'hfff;
            else if(pixel_x >= 300 && pixel_x < 340 && pixel_y >= 370 && pixel_y < 400) rgb_next = 12'hfff;
            else if(pixel_x >= 300 && pixel_x < 340 && pixel_y >= 420 && pixel_y < 450) rgb_next = 12'hfff;
            else if(pixel_y >= 280 && pixel_y < 320 && pixel_x >= 70 && pixel_x < 150) rgb_next = 12'hfff;
            else if(pixel_y >= 280 && pixel_y < 320 && pixel_x >= 170 && pixel_x < 250) rgb_next = 12'hfff;
            else if(pixel_y >= 280 && pixel_y < 320 && pixel_x >= 270 && pixel_x < 370) rgb_next = 12'hfff;
            else if(pixel_y >= 280 && pixel_y < 320 && pixel_x >= 390 && pixel_x < 470) rgb_next = 12'hfff;
            else if(pixel_y >= 280 && pixel_y < 320 && pixel_x >= 490 && pixel_x < 570) rgb_next = 12'hfff;
            else rgb_next = 12'h000;
        end
        else if(s1_level_counter == 2)begin
            if(pixel_x >= 140 && pixel_x < 170 && pixel_y >= 200 && pixel_y < 230) rgb_next = 12'hfff;
            else if(pixel_x >= 140 && pixel_x < 170 && pixel_y >= 280 && pixel_y < 310) rgb_next = 12'hfff;
            else if(pixel_x >= 140 && pixel_x < 170 && pixel_y >= 360 && pixel_y < 390) rgb_next = 12'hfff;
            else if(pixel_x >= 250 && pixel_x < 280 && pixel_y >= 200 && pixel_y < 230) rgb_next = 12'hfff;
            else if(pixel_x >= 250 && pixel_x < 280 && pixel_y >= 280 && pixel_y < 310) rgb_next = 12'hfff;
            else if(pixel_x >= 250 && pixel_x < 280 && pixel_y >= 360 && pixel_y < 390) rgb_next = 12'hfff;
            else if(pixel_x >= 360 && pixel_x < 390 && pixel_y >= 200 && pixel_y < 230) rgb_next = 12'hfff;
            else if(pixel_x >= 360 && pixel_x < 390 && pixel_y >= 280 && pixel_y < 310) rgb_next = 12'hfff;
            else if(pixel_x >= 360 && pixel_x < 390 && pixel_y >= 360 && pixel_y < 390) rgb_next = 12'hfff;
            else if(pixel_x >= 470 && pixel_x < 500 && pixel_y >= 200 && pixel_y < 230) rgb_next = 12'hfff;
            else if(pixel_x >= 470 && pixel_x < 500 && pixel_y >= 280 && pixel_y < 310) rgb_next = 12'hfff;
            else if(pixel_x >= 470 && pixel_x < 500 && pixel_y >= 360 && pixel_y < 390) rgb_next = 12'hfff;
            else rgb_next = 12'h000;
        end
        else if(s1_level_counter == 3)begin
            if(pixel_x >= green_manX[8]*10 && pixel_x < green_manX[8]*10 + 9
                && pixel_y > green_manY[8]*10 && pixel_y < green_manY[8]*10 + 9) begin
                    rgb_next = 12'h0f0; //exception (independent)
            end
            else if(pixel_x >= green_manX[9]*10 && pixel_x < green_manX[9]*10 + 9
                && pixel_y > green_manY[9]*10 && pixel_y < green_manY[9]*10 + 9) begin
                    rgb_next = 12'h0f0; //exception (independent)
                end
            else if (pixel_x >= green_manX[green_man_count]*10 && pixel_x < green_manX[green_man_count]*10 + 10
                && pixel_y >= green_manY[green_man_count]*10 && pixel_y < green_manY[green_man_count]*10 + 10) begin
                    rgb_next = 12'h0f0; //for most of the greenman
            end
            else if (pixel_x >= red_manX[red_man_count]*10 && pixel_x < red_manX[red_man_count]*10 + 10
                && pixel_y >= red_manY[red_man_count]*10 && pixel_y < red_manY[red_man_count]*10 + 10) begin
                    rgb_next = 12'hf00; //for most of the redman
            end
            else rgb_next = 12'h000;
        end
        else rgb_next = 12'h000;
        
        if((s2clki_region)&&(s3lbl_sram_out)!= 12'h0f0)//clock logic
            rgb_next= (s3lbl_sram_out == 12'h222 || s3lbl_sram_out ==12'h29f)?12'hfff:12'h000;
        else if((s2heart_region)&&(s3lbl_sram_out)!= 12'h0f0)
            rgb_next=s3lbl_sram_out;
        else if((s2sci_region)&&(s3lbl_sram_out)!= 12'h0f0)
            rgb_next = 12'hfff;
        else if((s2_clkdot_region)&&(s3numbers_sram_out!=12'h0f0)&&(second_counter <= 50_000_000))
            rgb_next = (s3_clk_reg<=10)?12'hf00:12'hfff;
        else if((s2_clknum1_region||s2_clknum2_region||s2_clknum3_region)&&(s3numbers_sram_out!=12'h0f0))begin
        
        if(s3_clk_reg<=10)
            rgb_next = (second_counter <= 50_000_000)?12'hf00:12'h000;
        else rgb_next = 12'hfff;
        end
        else if((s2_scnum1_region||s2_scnum2_region||s2_scnum3_region)&&(s3numbers_sram_out!=12'h0f0))
            rgb_next = 12'hfff;
        else if (s2healthb_region) rgb_next = 12'hfff;
        else if(s2health_region)begin
            if (s3_health_reg<(S3_FULL_HP>>2)) rgb_next = 12'ha00;//red
            else if (s3_health_reg<(S3_FULL_HP>>1)) rgb_next = 12'hfd3;//yellow
            else   rgb_next = 12'h0a0; //green
        end



  end
  else if(current_state == S4)begin
    if(s4_again_region && s4_sram_out != 12'h0f0) rgb_next =(!s4_selection_counter)? 12'h38a:12'h222;
    else if(s4_menu_region && s4_sram_out != 12'h0f0) rgb_next = (s4_selection_counter)?12'h38a:12'h222;
    else if((s4_agains_region)&&(s4_sram_out != 12'h0f0)&&(!s4_selection_counter)) rgb_next = s4_sram_out;
    else if((s4_menus_region)&&(s4_sram_out != 12'h0f0)&&(s4_selection_counter)) rgb_next = s4_sram_out;
    else if(s4_score_region && s3lbl_sram_out != 12'h0f0) rgb_next = s3lbl_sram_out;//test red
    else if((s4_sc1_region || s4_sc2_region || s4_sc3_region) && (s3numbers_sram_out != 12'h0f0)) rgb_next = 12'hfff;
    else if((s1b1_region||s1b2_region||s1b3_region||s1b4_region)&&(s1btnctrl_sram_out)!= 12'h0f0)
      rgb_next = 12'h47e;
    else if((s1b1i_region||s1b2i_region||s1b3i_region||s1b4i_region)&&(s1btnctrl_sram_out)!= 12'h0f0)
      rgb_next = 12'h47e;
    else rgb_next = 12'h000;
  end
  else rgb_next = 12'h000;
end
always @ (*) begin
    if(~reset_n || current_state == SPP) direction = 4'b0010;
    case (P) 
        UP: direction = 4'b0001;
        RIGHT: direction = 4'b0010;
        DOWN: direction = 4'b0100;
        LEFT: direction = 4'b1000;
     endcase
end


always @ (posedge clk) begin
    if(~reset_n) begin
        green_man_count <= 0;
        green_man_hold_count <= 0;
    end
    else if(pixel_x == 0 && pixel_y == 0) begin
        green_man_count <= 0;
        green_man_hold_count <= 0;
    end
    else if(pixel_x == 0 && pixel_y <= green_manY[green_man_hold_count]*10 + 10 && pixel_y >= green_manY[green_man_hold_count]*10) green_man_count <= green_man_hold_count;
    else if(pixel_x == 0 && (pixel_y > green_manY[green_man_hold_count]*10 + 9)) green_man_hold_count <= green_man_count;
    else if(pixel_x == green_manX[green_man_count]*10 + 9) green_man_count <= green_man_count + 1;
end  

always @ (posedge clk) begin
    if(~reset_n || next_state == SPP) begin
        red_man_count <= 0;
        red_man_hold_count <= 0;
    end
    else if(pixel_x == 0 && pixel_y == 0) begin
        red_man_count <= 0;
        red_man_hold_count <= 0;
    end
    else if(pixel_x == 0 && pixel_y <= red_manY[red_man_hold_count]*10 + 10 && pixel_y >= red_manY[red_man_hold_count]*10) red_man_count <= red_man_hold_count;
    else if(pixel_x == 0 && (pixel_y > red_manY[red_man_hold_count]*10 + 9)) red_man_hold_count <= red_man_count;
    else if(pixel_x == red_manX[red_man_count]*10 + 9) red_man_count <= red_man_count + 1;
end          
        
//FSM for the moving direction of the snake
always @ (*) begin
    case (P) 
    UP: begin
        if(btn_pressed[0]) P_next = RIGHT;
        else if(btn_pressed[3]) P_next = LEFT;
        else P_next = UP;
    end
    RIGHT: begin
        if(btn_pressed[1]) P_next = UP; 
        else if(btn_pressed[2]) P_next = DOWN;
        else P_next = RIGHT;
    end
    DOWN: begin
        if(btn_pressed[0]) P_next = RIGHT;
        else if(btn_pressed[3]) P_next = LEFT;
        else P_next = DOWN;
    end
    LEFT: begin
        if(btn_pressed[1]) P_next = UP; 
        else if(btn_pressed[2]) P_next = DOWN;
        else P_next = LEFT;
    end
    endcase
end

always @(posedge clk) begin
    if(~reset_n || current_state == SPP) P <= RIGHT;
    else P <= P_next;    
end

endmodule


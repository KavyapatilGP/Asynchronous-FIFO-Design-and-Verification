module rptr_handler(rclk, r_en, rrst_n, g_wptr_sync, b_rptr, g_rptr, empty);
  parameter PTR_WIDTH = 3; //fifo depth = 8 combinations (log2 8 : 3 bits)
  input rclk, r_en, rrst_n;
  input [PTR_WIDTH:0] g_wptr_sync;
  output reg [PTR_WIDTH:0] b_rptr, g_rptr;
  output reg empty;
  
  reg [PTR_WIDTH:0] b_rptr_next;
  reg [PTR_WIDTH:0] g_rptr_next;
  wire rempty;
  
  assign b_rptr_next = b_rptr + (r_en & !empty);//if condition true: updated the b_rptr by 1
  assign g_rptr_next = b_rptr_next>>1 ^ b_rptr_next;//bin to gray conversion
  //Empty Detect
  assign rempty = (g_wptr_sync == g_rptr_next);
  
  always@(posedge rclk or negedge rrst_n)
    begin
      if(!rrst_n)
        begin
          b_rptr <= 0;
          g_rptr <= 0;
        end
      else
        begin 
          b_rptr <= b_rptr_next;
          g_rptr <= g_rptr_next;
        end
    end
  
  always@(posedge rclk or negedge rrst_n)
    begin
      if(!rrst_n)
        empty <= 1;
      else
        empty <= rempty;
    end
endmodule
  
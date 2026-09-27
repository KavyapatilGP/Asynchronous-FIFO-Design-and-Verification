module wptr_handler(wclk, wrst_n, w_en, g_rptr_sync, b_wptr, g_wptr, full);
  parameter PTR_WIDTH = 3;
  input wclk, wrst_n, w_en;
  input [PTR_WIDTH:0] g_rptr_sync;
  output reg [PTR_WIDTH:0] b_wptr, g_wptr;
  output reg full;

  reg [PTR_WIDTH:0] b_wptr_next;
  reg [PTR_WIDTH:0] g_wptr_next;
  reg wrap_around;
  wire wfull;

  assign b_wptr_next = b_wptr + (w_en & !full); //if condition true = b_wptr will be increment by one
  assign g_wptr_next = b_wptr_next>>1 ^ b_wptr_next;

  //Full Detect
  assign wfull = g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]};

  always@(posedge wclk or negedge wrst_n)
    if(!wrst_n)
      begin
        b_wptr <= 0;
        g_wptr <= 0;
      end
  else
    begin
      b_wptr <= b_wptr_next;
      g_wptr <= g_wptr_next;
    end

  always@(posedge wclk or negedge wrst_n)
    begin
      if(!wrst_n)
        full <= 0;
      else
        full <= wfull;
    end

endmodule





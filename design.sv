`include "synchronizer.sv"
`include "wptr_handler.sv"
`include "rptr_handler.sv"
`include "FIFO_memory.sv"

module async_fifo # (parameter DATA_WIDTH = 8, DEPTH = 8)  (
  input wclk, rclk, 
  input wrst_n, rrst_n,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out,
  output reg full, empty
);

  parameter PTR_WIDTH = $clog2(DEPTH);

  reg [PTR_WIDTH:0] b_wptr, b_rptr;
  reg [PTR_WIDTH:0] g_wptr, g_rptr;
  reg [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;

  wire [PTR_WIDTH-1:0] waddr, raddr;

  synchronizer #(PTR_WIDTH) wptr_sync (wclk, wrst_n, g_rptr, g_rptr_sync); // read ptr -> write domain (for full)
  synchronizer #(PTR_WIDTH) rptr_sync (rclk, rrst_n, g_wptr, g_wptr_sync); // write ptr -> read domain (for empty)

  wptr_handler #(PTR_WIDTH) wptr_h (wclk, wrst_n, w_en, g_rptr_sync, b_wptr, g_wptr, full);
  rptr_handler #(PTR_WIDTH) rptr_h (rclk, r_en, rrst_n, g_wptr_sync, b_rptr, g_rptr, empty);

  fifo_memory fifo_mem(wclk, rclk, wrst_n, rrst_n, w_en, r_en, b_wptr, b_rptr, full, empty, data_in, data_out);
                                   
endmodule

  
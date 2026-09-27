module fifo_memory # (parameter DEPTH=8, DATA_WIDTH=8, PTR_WIDTH=3) (wclk, rclk, wrst_n, rrst_n, w_en, r_en, b_wptr, b_rptr, full, empty, data_in, data_out);
  
  input wclk, rclk, wrst_n, rrst_n, w_en, r_en;
  input [PTR_WIDTH:0]b_wptr, b_rptr;
  input full, empty;
  input [DATA_WIDTH-1:0] data_in;
  output logic [DATA_WIDTH-1:0] data_out;
  
  reg  [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
  
  always@(posedge wclk)
    begin
      if(w_en & !full)
        begin
          fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;
        end
    end
  
  assign data_out = fifo[b_rptr[PTR_WIDTH-1:0]];
endmodule
  
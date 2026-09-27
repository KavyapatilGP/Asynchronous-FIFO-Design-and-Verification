module asyc_fifo_tb;
  parameter DATA_WIDTH = 8;
  wire [DATA_WIDTH-1:0] data_out;
  wire full, empty;
  reg wclk, rclk;
  reg wrst_n, rrst_n;
  reg w_en, r_en;
  reg[DATA_WIDTH-1:0] data_in;
  
  reg [DATA_WIDTH-1:0] wdata_q[$], wdata;
  
  async_fifo dut(wclk, rclk, wrst_n, rrst_n, w_en, r_en, data_in, data_out, full, empty);
  
  always #10 wclk = ~wclk;
  always #35 rclk = ~rclk;
  
  initial begin
    wclk = 1'b0;
    wrst_n = 1'b0;
    w_en = 1'b0;
    data_in = 1'b0;

    repeat(10) @ (posedge wclk)
      wrst_n = 1'b1;//Holds reset for 10 write-clock edges, then deasserts reset (releases FIFO from reset).

    repeat(2) begin
      for(int i=0; i<30; i++) begin
        @(posedge wclk);          // no more "iff !full"
        #1;
        w_en = (i%2==0) ? 1'b1 : 1'b0;
        if (w_en && !full) begin              // <-- add !full check
          data_in = $random;
          wdata_q.push_back(data_in);
        end
      end
      #50;
      
      // after the main write loop, deliberately hammer w_en while full
      repeat(5) begin
        @(posedge wclk); #1;
        w_en = 1'b1;
        data_in = $random;
        if (!full) wdata_q.push_back(data_in);   // only counts if DUT actually accepts it
      end
    end
  end
  
  initial begin
    rclk = 1'b0;
    rrst_n = 1'b0;
    r_en = 1'b0;

    repeat(20) @ (posedge rclk)
      rrst_n = 1'b1;

    repeat(2) begin
      for(int i=0; i<30; i++) begin
        @(posedge rclk);           // no more "iff !empty"
        r_en = (i%2==0) ? 1'b1 : 1'b0;
        if (r_en && !empty) begin             // <-- add !empty check
          wdata = wdata_q.pop_front();
          if (data_out !== wdata)
            $error("Time = %0t Comparison Failed expected, w_data = %h, r_data = %h", $time, wdata, data_out);
          else
            $display("Time = %0t Comparison Passed, w_data = %h, r_data = %h", $time, wdata, data_out);
        end
      end
    #50;
  end
  $finish;
  end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,asyc_fifo_tb);
  end
  
  
  //------Functional Coverage------

  covergroup fifo_cg @(posedge wclk);

    //Write enable
    w_en_cp : coverpoint w_en {
      bins disabled = {0};
      bins enabled  = {1};
    }

    //Read enable
    r_en_cp : coverpoint r_en {
      bins disabled = {0};
      bins enabled  = {1};
    }

    //FIFO full
    full_cp : coverpoint full {
      bins not_full = {0};
      bins full     = {1};
    }

    //FIFO empty
    empty_cp : coverpoint empty {
      bins not_empty = {0};
      bins empty     = {1};
    }

    //Cross coverage of control combinations
    write_full : cross w_en, full;
    read_empty : cross r_en, empty;

  endgroup

  fifo_cg cov = new();
  
  //------Coverage result------
  final begin

    $display("\n-----------------------------------------");
    $display("       FUNCTIONAL COVERAGE REPORT");
    $display("-----------------------------------------");
    $display("           Coverage = %0.2f%%", cov.get_coverage());
    $display("write_full = %0.2f", cov.write_full.get_coverage());
    $display("read_empty = %0.2f", cov.read_empty.get_coverage());
    $display("-----------------------------------------\n");

  end
  
endmodule
  


  

  
  
  
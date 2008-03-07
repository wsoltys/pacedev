
module spi_controller(
		      CS_N,
		      MOSI,
		      MISO,
		      SCLK,
		      ram_write_addr,
		      ram_di,
		      ram_we,
		      track,
		      block_to_read,
		      block_read_cmd,
			  track_mode,			      
		      CLK_14M,
		      reset,
		      is_idle
		      );

   parameter [4:0] 
		   RESET_STATE = 0,
		   RESET_CLOCKS1 = 1,
		   RESET_CLOCKS2 = 2,
		   RESET_SEND_CMD0 = 3,
		   RESET_SEND_CMD1 = 4,
		   RESET_CHECK_CMD1 = 5,
		   RESET_SEND_SET_BLOCKLEN = 6,
		   IDLE = 7,
		   READ_TRACK = 8,
		   READ_BLOCK = 9,
		   READ_BLOCK_WAIT = 10,
		   READ_BLOCK_DATA = 11,
		   READ_BLOCK_CRC = 12,
		   SEND_CMD = 13,
		   RECEIVE_BYTE_WAIT = 14,
		   RECEIVE_BYTE = 15,
		   NEW_TRACK = 16;

   output CS_N;
   // MMC chip select
   output MOSI,is_idle;
   // Data to card (master out slave in)
   input  MISO;
   // Data from card (master in slave out)
   output SCLK;
   // Card clock
   output [13:0] ram_write_addr;
   output [7:0]  ram_di;
   output 	 ram_we;
   input [5:0] 	 track;
   input 	 block_read_cmd, track_mode;

   
   input [22:0]  block_to_read;
   
   // 0 - 34
   input 	 CLK_14M;
   // System clock
   input 	 reset;

   reg [4:0] 	   state;
   reg [4:0] 	   return_state;
   reg 		   sclk_sig;
   reg [7:0] 	   counter;
   reg [8:0] 	   byte_counter;
   wire [5:0] 	   current_track;
   reg [13:0] 	   write_addr;
   reg [47:0] 	   command;
   reg [7:0] 	   recv_byte;
   reg [31:0] 	   address;
   reg [22:0] 	   last_block = -1;
   
	wire [15:0] track_offset; //track * 13 - offset in blocks


   reg 		 CS_N;
   wire 	 MOSI;
   wire 	 MISO;
   wire 	 SCLK;
   wire [13:0] 	 ram_write_addr;
   reg [7:0] 	 ram_di;
   reg 		 ram_we_reg;
   wire [5:0] 	 track;
   wire 	 CLK_14M;
   wire 	 reset;

	reg [5:0] 	 last_track = 6'b111111; // force read of track 0

   assign 	 ram_we = (state == READ_BLOCK_DATA);
   assign 	 is_idle = (state == IDLE);


   assign 	   ram_write_addr = write_addr;
   assign 	   SCLK = sclk_sig;

// easy enough to use adders, but we have plenty of unused multipliers
// actually we need to multiply by 13 (512 byte blocks in a NIB track)
//mult1 mult_by_1a00(
//	.dataa(track),
//	.result(track_offset));



   always @(posedge CLK_14M) begin
      ram_we_reg <= 1'b 0;
      if(reset == 1'b 1) begin
	 	 state <= RESET_STATE;
		 sclk_sig <= 0;
		 CS_N <= 1'b1;
		 command <= 48'hffffffffffff;
		 counter <= 8'h00;
		 byte_counter <= 9'h00;
		 write_addr <= 14'h0;
		 last_block = -1;
      end else begin

	 case (state)
	   
	   RESET_STATE: begin
              counter <= 160;
              state <= RESET_CLOCKS1;
	   end  

           // output a series of clock signals to wake up the chip
	   RESET_CLOCKS1: begin
              if (counter == 0) begin
		 counter <= 32;
		 CS_N <= 1'b0;
		 state <= RESET_CLOCKS2;
	      end  else begin
		 counter <= counter - 1;
		 sclk_sig <= ~sclk_sig;
              end
	   end
	   
	   RESET_CLOCKS2:
	     begin
		if (counter == 0) begin
		   state <= RESET_SEND_CMD0;
		   
		end else begin
		   counter <= counter - 1;
		   sclk_sig <= ~sclk_sig;
		end
	     end   

           // Send CMD0 : GO_IDLE_STATE
	   RESET_SEND_CMD0: 
	     begin
		command <= 48'h400000000095;
		counter <= 47;
		return_state <= RESET_SEND_CMD1;
		state <= SEND_CMD;
	     end 

           // Send CMD1 : SEND_OP_CMD
	   RESET_SEND_CMD1:
	     begin
		command <= 48'h410000000001;
		counter <= 47;
		return_state <= RESET_CHECK_CMD1;
		state <= SEND_CMD;
	     end   

	   RESET_CHECK_CMD1: 
	     begin
		if (recv_byte == 8'h00) begin
		   //     state <= RESET_SEND_SET_BLOCKLEN;

		   address <= 0;
		   state <= IDLE; //READ_BLOCK;
		   
		end else
		  state <= RESET_SEND_CMD1;              
             end   

	   /*    
	    RESET_SEND_SET_BLOCKLEN: 
	    begin
            command <= 48'h500000010001;  // CMD16: SET_BLOCKLEN (256)
            counter <= 47;
            return_state <= IDLE;
            state <= SEND_CMD;
	end
	    */
	   

	   IDLE:
	     begin
			CS_N <= 1'b1;
			
			if(track_mode && (track != last_track)) begin
				write_addr <= 14'h0;
				last_track <= track;			
				state <= READ_TRACK;
				address <= { block_to_read + track_offset, 9'h0};
			end else
			if(block_read_cmd && (block_to_read != last_block)) begin
				write_addr <= 14'h0;
				address <= {   block_to_read, 9'h0};
			    state <= READ_BLOCK;
			end
	     end
	   
	   READ_TRACK:
             if (write_addr == 16'h1A00) begin
				state <= IDLE;
             end else
               state <= READ_BLOCK;
	   
	   // Set address, write_addr before entering
	   READ_BLOCK:
	     begin
			CS_N <= 1'b0;
			command <= {8'h51, address, 8'h01};  // READ_SINGLE_BLOCK
			counter <= 47;
			return_state <= READ_BLOCK_WAIT;
			state <= SEND_CMD;
			last_block <= block_to_read;
	     end
	   
           // Wait for a 0 to signal the start of the block,
           // then read the first byte
	   READ_BLOCK_WAIT:
	     begin
			if ((sclk_sig == 1'h1) && (MISO == 1'b0)) begin
			   state <= READ_BLOCK_DATA;
			   byte_counter <= 9'h1FF;
			   counter <= 7;
			   return_state <= READ_BLOCK_DATA;
			   state <= RECEIVE_BYTE;
			end
			sclk_sig <= ~sclk_sig;
	     end // case: READ_BLOCK_WAIT
           

	   READ_BLOCK_DATA:
	     begin
			ram_we_reg <= 1'b1;
			write_addr <= write_addr + 1;
			address <= address + 1;
			if (byte_counter == 0) begin
			   counter <= 7;
			   return_state <= READ_BLOCK_CRC;
			   state <= RECEIVE_BYTE;
			end else begin
			   byte_counter <= byte_counter - 1;
			   return_state <= READ_BLOCK_DATA;
			   counter <= 7;
			   state <= RECEIVE_BYTE;
			end
	     end // case: READ_BLOCK_DATA
	   

	   READ_BLOCK_CRC:
             begin
				counter <= 7;
				if(track_mode)
					return_state <= READ_TRACK;
				else	
					return_state <= IDLE;
	//			address <= address + 9'h200;
				state <= RECEIVE_BYTE;
		     end
	   
	   
	   // Send the command.  Set counter=47 and return_state first
	   SEND_CMD: begin
              if (sclk_sig == 1) begin
		 		if (counter == 0) begin
                    state <= RECEIVE_BYTE_WAIT;
		 		end else begin
                    counter <= counter - 1;
                    command <= {command[46:0],1'b1};
		 		end
              end
              sclk_sig <= ~sclk_sig;
	   end // case: SEND_CMD
	   
           // Wait for a "0", indicating the first bit of a response.
           // Set return_state first
	   RECEIVE_BYTE_WAIT:
	     begin
		if (sclk_sig == 1) begin
		   if (MISO == 0) begin
                      recv_byte <= 8'h0;
		      counter <= 6; //  -- Already read bit 7
                      state <= RECEIVE_BYTE;
		   end
		end
		sclk_sig <= ~sclk_sig;
             end
           // Receive a byte.  Set counter to 7 and return_state before entry
	   RECEIVE_BYTE:
	     begin
		if (sclk_sig == 1) begin
		   recv_byte <= {recv_byte[6:0], MISO};
		   if (counter == 0) begin
                      state <= return_state;
                      ram_di <= {recv_byte[6:0],  MISO};
		   end else
                     counter <= counter - 1;
		end
		sclk_sig <= ~sclk_sig;
	     end // case: RECEIVE_BYTE
	   


	   
	 endcase // case(state)
      end    
   end

   assign MOSI = command[47] ;

endmodule

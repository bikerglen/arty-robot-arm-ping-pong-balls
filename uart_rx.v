module uart_rx
(
    input   wire            rst,                // sync, active-high system reset
    input   wire            clk,                // system clock
    input   wire            baudEn,             // enable at 16x baud rate
	input	wire			rxd,				// receive data in
	output	reg				avail,				// new data byte received
	output	reg		[7:0]	data				// received data byte
);

reg rxd_z, rxd_zz;
reg [2:0] rxd_in;
reg [1:0] state;
reg [2:0] bitnum;
reg [4:0] ph;
reg [7:0] rxdata;

wire rxmajority;
assign rxmajority = (rxd_in[2] + rxd_in[1] + rxd_in[0]) >= 2;

always @ (posedge clk)
begin
	if (rst)
	begin
		avail <= 0;
		data <= 0;
		rxd_z <= 1;
		rxd_zz <= 1;
		rxd_in <= 3'b111;
		state <= 0;
		bitnum <= 0;
		ph <= 0;
		rxdata <= 0;
	end
	else
	begin
		// harden receive data input against metastability
		rxd_z <= rxd;
		rxd_zz <= rxd_z;

		// defaults
		avail <= 0;

		if (baudEn)
		begin
			// for edge and majority detection
			rxd_in <= { rxd_in[1:0], rxd_zz };

			case (state)
		
				0: begin
					if (rxd_in == 3'b100)
					begin
						state <= 1;
						bitnum <= 0;
						ph <= 22;
						rxdata <= 0;
					end
				end

				1: begin
					if (ph == 0)
					begin
						rxdata <= { rxmajority, rxdata[7:1] }; 
						bitnum <= bitnum + 1;
						if (bitnum == 7) 
						begin
							ph <= 14;
							state <= 2;
						end
						else
						begin
							ph <= 15;
						end
					end
					else
					begin
						ph <= ph - 1;
					end
				end

				2: begin
					ph <= ph - 1;
					if (ph == 0)
					begin
						state <= 0;
						avail <= 1;
						data <= rxdata;
					end
				end

				default: begin
					state <= 0;
				end

			endcase
		end
	end
end

endmodule

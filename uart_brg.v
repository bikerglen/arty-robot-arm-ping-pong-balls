module uart_brg
(
	input	wire			rst,
	input	wire			clk,
	output	reg				baudEn
);

parameter DIVISOR = 10;

reg [7:0] baudCount;

always @ (posedge clk)
begin
    if (rst)
    begin
        baudCount <= 0;
        baudEn <= 0;
    end
    else
    begin
        if (baudCount == DIVISOR)
        begin
            baudCount <= 0;
            baudEn <= 1;
        end
        else
        begin
            baudCount <= baudCount + 1;
            baudEn <= 0;
        end
    end
end

endmodule

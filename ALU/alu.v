module alu (
    input               i_clk,
    input               i_rst_n,
    input               i_valid,
    input signed [11:0] i_data_a,
    input signed [11:0] i_data_b,
    input        [2:0]  i_inst,
    output              o_valid,
    output signed [11:0] o_data,
    output              o_overflow
);
    
// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
reg signed [11:0] o_data_w, o_data_r;
reg         o_valid_w, o_valid_r;
reg         o_overflow_w, o_overflow_r;
reg signed [11:0] MAC_accumulate; //stores the prev value of MAC to be used for summation
reg 		  MAC_overflow; //is high if at one point during the MAC there is an overflow

wire [11:0] abs_a, abs_b;
wire signed [12:0] signed_sum;
wire signed [23:0] mult_wide;
wire signed [11:0] mult_fixed_point;
wire signed [12:0] MAC_summation;
// ---- Add your own wires and registers here if needed ---- //




// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
assign o_valid = o_valid_r;
assign o_data = o_data_r;
assign o_overflow = o_overflow_r;

assign signed_sum = i_data_a + i_data_b;

assign abs_a = i_data_a[11] ? (~i_data_a + 1'b1) : i_data_a;
assign abs_b = i_data_b[11] ? (~i_data_b + 1'b1) : i_data_b;
assign mult_wide = i_data_a * i_data_b;
assign mult_fixed_point = (mult_wide + (1 <<< 4)) >>> 5;
assign MAC_summation = mult_fixed_point + MAC_accumulate;
// ---- Add your own wire data assignments here if needed ---- //




// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your conbinational block design here ---- //
always@(*) begin
    o_data_w = 0;
    o_overflow_w = 0;
    o_valid_w = 0;

    if (i_valid == 1) begin
	case (i_inst)
	   3'b000: begin
		o_data_w = signed_sum[11:0];                     // ADD
		o_overflow_w = (i_data_a[11] == i_data_b[11]) && (signed_sum[11] != i_data_a[11]);
	   end
	   3'b001: begin
		o_data_w = i_data_a - i_data_b;                     // SUB
		o_overflow_w = (i_data_a[11] != i_data_b[11]) && (o_data_w[11] != i_data_a[11]);
	   end
	   3'b010: begin
    		o_data_w    = mult_fixed_point; // MULT
    		o_overflow_w = (mult_wide[23:17] != {7{mult_wide[16]}});
	   end
	   3'b011: begin 
		   o_data_w = MAC_summation[11:0]; // MAC
		   MAC_accumulate = o_data_w;
		   o_overflow_w = (mult_wide[23:17] != {7{mult_wide[16]}}) || (MAC_summation[12] != MAC_summation[11]);
	   end
	   3'b100: o_data_w = ~(i_data_a ^ i_data_b);                  // XNOR
	   3'b101: o_data_w = (i_data_a[11] == 0) ? i_data_a : 12'd0; //ReLU
	   3'b110: o_data_w = (signed_sum) >>> 1; //Mean
	   3'b111: o_data_w = (abs_a > abs_b) ? abs_a : abs_b; // Absolute Max
	default: o_data_w = 0;
	endcase

	o_valid_w = 1;
   end
end




// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// ---- Write your sequential block design here ---- //
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_data_r <= 0;
        o_overflow_r <= 0;
        o_valid_r <= 0;
	MAC_accumulate <= 0;
	MAC_overflow <= 0;
    end else begin
        o_data_r <= o_data_w;
	if (i_valid && i_inst == 3'b011) begin
		MAC_overflow <= o_overflow_w | MAC_overflow;
		o_overflow_r <= o_overflow_w | MAC_overflow;
	end else begin
        	o_overflow_r <= o_overflow_w;
	end
        o_valid_r <= o_valid_w;

	if (!i_valid && i_inst != 3'b011) begin
		MAC_accumulate <= 0;
		MAC_overflow <= 0;
	end

    end
end


endmodule

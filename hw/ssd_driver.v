module SSD_driver(input clk,
                input rst,
                input [3:0] firt_bcd,
                input [3:0] second_bcd,
                output anode, 
                output reg a, b, c, d, e, f, g); 
    
    reg [4:0] an_counter;
    wire [3:0] value;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            an_counter <= 5'd0;
        end
        else 
            an_counter <= an_counter + 1'd1;
    end

    assign anode = (an_counter < 4'd15) ? 0 : 1;
    assign value = (anode)? firt_bcd : second_bcd;

    always @(*) begin
        case (value)
            4'b0000: {a,b,c,d,e,f,g} = 7'b1111110; // 0
            4'b0001: {a,b,c,d,e,f,g} = 7'b0110000; // 1
            4'b0010: {a,b,c,d,e,f,g} = 7'b1101101; // 2
            4'b0011: {a,b,c,d,e,f,g} = 7'b1111001; // 3
            4'b0100: {a,b,c,d,e,f,g} = 7'b0110011; // 4
            4'b0101: {a,b,c,d,e,f,g} = 7'b1011011; // 5
            4'b0110: {a,b,c,d,e,f,g} = 7'b1011111; // 6
            4'b0111: {a,b,c,d,e,f,g} = 7'b1110000; // 7
            4'b1000: {a,b,c,d,e,f,g} = 7'b1111111; // 8
            4'b1001: {a,b,c,d,e,f,g} = 7'b1111011; // 9
            4'b1010: {a,b,c,d,e,f,g} = 7'b1110111; // A
            4'b1011: {a,b,c,d,e,f,g} = 7'b0011111; // b 
            4'b1100: {a,b,c,d,e,f,g} = 7'b1001110; // C
            4'b1101: {a,b,c,d,e,f,g} = 7'b0111101; // d 
            4'b1110: {a,b,c,d,e,f,g} = 7'b1001111; // E
            4'b1111: {a,b,c,d,e,f,g} = 7'b1000111; // F
            default: {a,b,c,d,e,f,g} = 7'b0000000;
        endcase
    end

endmodule
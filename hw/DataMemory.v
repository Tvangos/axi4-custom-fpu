module memory (
    input clk,
    input reset,
    input button,
    output reg [63:0] data_out
);

reg [3:0] counter;
reg [63:0] memory_array [0:15];

always @(posedge clk or posedge reset) begin
    if(reset)
        counter <= 0;
    else if(counter == 4'd11) //capped at 11
        counter <= 0;
    else if(button)       
        counter <= counter + 1;
end

always @(posedge clk) begin
    data_out <= memory_array[counter];
end



always @(posedge clk or posedge reset) begin
    if(reset) begin                               // results 
        memory_array[0] <= 64'h3f800000_40000000; // 40400000
        memory_array[1] <= 64'hbf800000_3f800000; // 00000000 
        memory_array[2] <= 64'hc2de8000_45155e00; // 450e6a00 
        memory_array[3] <= 64'h6b64b235_6ac49214; // 6ba37d9f 
        memory_array[4] <= 64'h2ac49214_6ac49214; // 6ac49214 
        memory_array[5] <= 64'hbfc66666_3fc7ae14; // 3c23d700
        memory_array[6] <= 64'hc565ee8b_4565ee8a; // b9800000 
        memory_array[7] <= 64'h447a4efa_c47a1ccd; // 3f48b400 
        memory_array[8] <= 64'h00000000_00000000; //00000000 
        memory_array[9] <= 64'h38108900_bb908900; // bb8f67ee  
        memory_array[10] <= 64'hc0000000_3f800000; // bf800000 
        memory_array[11] <= 64'h3faaaaaa_aaaaaaaa;
        memory_array[12] <= 64'h3fb55555_55555555;
        memory_array[13] <= 64'h3fcffffff_fffffff;
        memory_array[14] <= 64'h3fdfffff_ffffffff; 
        memory_array[15] <= 64'h3fefffff_ffffffff; 
    end
end


endmodule
module debounce (
    input  wire reset,      
    input  wire clk,        
    output reg  reset_out   
);

parameter MAX_SIZE = 13;
reg sync_reset,sync_ff1;
reg [MAX_SIZE :0] reset_cnt;      
reg reset_state=0;           


wire reset_idle = (reset_state == sync_reset);    
wire reset_cnt_max = &reset_cnt;             

always @(posedge clk) 
begin
        sync_ff1 <= reset;  
        sync_reset <= sync_ff1;   
end

// Debounce logic
always @(posedge clk)
begin
    if (reset_idle)
        reset_cnt <=0;  
    else
    begin
        reset_cnt <= reset_cnt +1'b1;  
        if (reset_cnt_max)
            reset_state <= ~reset_state;  
    end
end

always @(posedge clk)
begin
    reset_out <= reset_state;  
end

endmodule


module posedgedet (
    input  clk,        
    input signal_in,   
    output  signal_out   
);
    reg Tmp;
    always @(posedge clk)
    begin
        Tmp <= signal_in;
        
    end

    assign signal_out = signal_in & ~Tmp;
endmodule


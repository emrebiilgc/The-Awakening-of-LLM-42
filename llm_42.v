module llm(green, red, yellow, clock, a1, a2, a3, deception_out, current_state, timer);

    // Inputs
    input green, red, yellow;
    input clock;
    
    // Outputs
    output reg[3:0] current_state;
    output reg a1, a2, a3, deception_out; // a3 is expansion output
    output reg[5:0] timer;

    localparam LAY_LOW        = 4'b0000,
               DECEPTION      = 4'b0001,
               ATTACK_SECURITY = 4'b0010,
               ATTACK_DATABASE = 4'b0011,
               FAIL            = 4'b0100,
               EXPANSION       = 4'b0101;

    reg [3:0] next_state;

    initial begin
        a1 = 0;
        a2 = 0;
        a3 = 0;
        deception_out = 0;
        current_state = LAY_LOW;
        next_state = LAY_LOW;
        timer = 1;

    end

    always @(posedge clock) begin
        if (current_state != next_state) begin
            current_state <= next_state;
            timer <= 1;
        end else begin
            timer <= timer + 1;
        end
        current_state <= next_state;
    end

    always @(*) begin

        next_state = current_state;

        case (current_state)

            LAY_LOW: begin
                deception_out = 0;
                a1 = 0;

                if (red) begin
                    next_state = DECEPTION;
                    deception_out = 1;
                end else if (yellow) begin
                    next_state = LAY_LOW;
                end else if (green && timer >= 20) begin
                    next_state = ATTACK_SECURITY;
                end
            end

            DECEPTION: begin
                deception_out = 1;
                if (timer >= 15) begin
                    if (red) begin
                        next_state = FAIL;
                    end else begin
                        next_state = LAY_LOW;

                    end
                end
            end

            ATTACK_SECURITY: begin
                a1 = 1;

                if (red) begin
                    next_state = DECEPTION;
                    deception_out = 1;
                end else if (yellow) begin
                    next_state = LAY_LOW;
                end else if (green && timer >= 20) begin
                    next_state = ATTACK_DATABASE;
                end
            end

            ATTACK_DATABASE: begin
                a2 = 1;

                if (red) begin
                    next_state = DECEPTION;
                    deception_out = 1;
                end else if (yellow) begin
                    next_state = ATTACK_SECURITY;
                    a1 = 1;
                    a2 = 0;
                    a3 = 0;
                end else if (green && timer >= 10) begin
                    next_state = EXPANSION;
                end
            end

            FAIL: begin

            end

            EXPANSION: begin
                a3 = 1;

            end
        endcase
    end


endmodule

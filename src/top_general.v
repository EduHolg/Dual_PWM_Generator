// Code your design here
`timescale 1ms/1us

module top_general (
    input  CLK_g,
    input  SCLK_g,
    input  MOSI_g,
    //input MISO_g
    input  SS_g,
    input  RESET_g,

    output senial_1g,
    output senial_1gn,
    output senial_2g,
    output senial_2gn
);

wire [3:0] conexion_1;
wire [3:0] conexion_2;
wire [3:0] conexion_3;
wire       conexion_4;
wire [3:0] conexion_5;
wire       conexion_6;

contador_up micup(
    .CLK_cup  (CLK_g),
    .RESET_cup(RESET_g),
    .Qs_up    (conexion_1) // cont_up_PWM
);

contador_up_down micupdown(
    .CLK_cupdown  (CLK_g),
    .RESET_cupdown(RESET_g),
    .Qs_updown    (conexion_2) // cont_updown_PWM
);

PWM_generator mipwm(
    .CLK_pwm        (CLK_g),
    .DUTY           (conexion_3), // ind_duty
    .cont_updown_PWM(conexion_2), // QS_updown
    .cont_up_PWM    (conexion_1), // QS_up
    .MODO           (conexion_4), // modo_alineacion
    .SENIAL_PWM     (senial_1g),
    .SENIAL_PWM_neg (senial_1gn)
);

PWM_generator2 mmipwm2(
    .CLK_pwm2        (CLK_g),
    .DUTY2           (conexion_5), // ind_duty2
    .cont_updown_PWM2(conexion_2), // QS_updown
    .cont_up_PWM2    (conexion_1), // QS_up
    .MODO2           (conexion_6), // modo_alineacion
    .SENIAL_PWM2     (senial_2g),
    .SENIAL_PWM_neg2 (senial_2gn)
);

SPI_slave mispi(
    .SCLK            (SCLK_g),
    .MOSI            (MOSI_g),
    //.MISO          (MISO_g)
    .SS              (SS_g),
    .RST             (RESET_g),
    .ind_duty        (conexion_3), // DUTY
    .modo_alineacion (conexion_4), // MODO
    .ind_duty2       (conexion_5),
    .modo_alineacion2(conexion_6)
);

endmodule


// ========================
// Contador ascendente
// ========================
module contador_up #(
    parameter num_bits = 4, 
    parameter num_max  = (2 ** num_bits)-1
)(
    input  CLK_cup,
    input  RESET_cup,
    output reg [num_bits-1:0] Qs_up
);

always @(posedge CLK_cup or posedge RESET_cup) begin
    if (RESET_cup) begin
        Qs_up <= {num_bits{1'b0}};
    end else begin
        if (Qs_up < num_max)
            Qs_up <= Qs_up + 1'b1;
        else
            Qs_up <= {num_bits{1'b0}};
    end
end

endmodule


// ========================
// Contador up-down
// ========================
module contador_up_down #(
    parameter num_bits = 4,
    parameter num_max  = (2 ** num_bits)-1
)(
    input  CLK_cupdown,
    input  RESET_cupdown,
    output reg [num_bits-1:0] Qs_updown
);

reg guia;

always @(posedge CLK_cupdown or posedge RESET_cupdown) begin
    if (RESET_cupdown) begin
        Qs_updown <= {num_bits{1'b0}};
        guia      <= 1'b0;
    end else begin
        if (!guia) begin
            if (Qs_updown < num_max) begin
                Qs_updown <= Qs_updown + 1'b1;
                if (Qs_updown == num_max-1) guia <= 1'b1;
            end
        end else begin
            if (Qs_updown > 0) begin
                Qs_updown <= Qs_updown - 1'b1;
                if (Qs_updown == 1) guia <= 1'b0;
            end
        end
    end
end

endmodule


// ========================
// Modulo PWM
// ========================
module PWM_generator #(
    parameter num_bits = 4,
    parameter num_max  = (2 ** num_bits)-1,
    parameter deadtime = 0
)(
    input  CLK_pwm,
    input  [num_bits-1:0] DUTY,
    input  [num_bits-1:0] cont_up_PWM,
    input  [num_bits-1:0] cont_updown_PWM,
    input  MODO,
    output reg SENIAL_PWM,
    output reg SENIAL_PWM_neg
);

always @(posedge CLK_pwm) begin
    if (DUTY == 0) begin
        SENIAL_PWM     <= 1'b0;
        SENIAL_PWM_neg <= 1'b1;
    end else if (DUTY == num_max) begin
        SENIAL_PWM     <= 1'b1;
        SENIAL_PWM_neg <= 1'b0;
    end else begin
        if (!MODO) begin
            SENIAL_PWM     <= (cont_up_PWM < DUTY);
            SENIAL_PWM_neg <= ((cont_up_PWM > DUTY + deadtime) && (cont_up_PWM < num_max - deadtime));
        end else begin
            SENIAL_PWM     <= (cont_updown_PWM < DUTY);
            SENIAL_PWM_neg <= (cont_updown_PWM > DUTY + deadtime);
        end
    end
end

endmodule


// ========================
// Modulo PWM2
// ========================
module PWM_generator2 #(
    parameter num_bits = 4,
    parameter num_max  = (2 ** num_bits)-1,
    parameter deadtime = 0
)(
    input  CLK_pwm2,
    input  [num_bits-1:0] DUTY2,
    input  [num_bits-1:0] cont_up_PWM2,
    input  [num_bits-1:0] cont_updown_PWM2,
    input  MODO2,
    output reg SENIAL_PWM2,
    output reg SENIAL_PWM_neg2
);

always @(posedge CLK_pwm2) begin
    if (DUTY2 == 0) begin
        SENIAL_PWM2     <= 1'b0;
        SENIAL_PWM_neg2 <= 1'b1;
    end else if (DUTY2 == num_max) begin
        SENIAL_PWM2     <= 1'b1;
        SENIAL_PWM_neg2 <= 1'b0;
    end else begin
        if (!MODO2) begin
            SENIAL_PWM2     <= (cont_up_PWM2 < DUTY2);
            SENIAL_PWM_neg2 <= ((cont_up_PWM2 > DUTY2 + deadtime) && (cont_up_PWM2 < num_max - deadtime));
        end else begin
            SENIAL_PWM2     <= (cont_updown_PWM2 < DUTY2);
            SENIAL_PWM_neg2 <= (cont_updown_PWM2 > DUTY2 + deadtime);
        end
    end
end

endmodule


// ========================
// Comunicación SPI (slave)
// ========================
module SPI_slave #(
    parameter WIDTH         = 4,             // bits_duty 
    parameter num_maximo_spi= WIDTH + 1,
    parameter qs_spi_cont   = 3              // 2^param - 1 >= num_maximo_spi
)(
    input  SCLK,
    input  MOSI,
    input  SS,        // activo en bajo
    input  RST,       // reset asíncrono (opcional)
    //output MISO,
    output reg [WIDTH-1:0] ind_duty,
    output reg [WIDTH-1:0] ind_duty2,
    output reg modo_alineacion,
    output reg modo_alineacion2
);

reg [WIDTH-1:0]        middle;
reg [WIDTH-1:0]        middle2;
reg                    indice;   // 0 -> primer dato, 1 -> segundo
reg [qs_spi_cont-1:0]  Q_SPI;

// Se muestrea en el flanco de bajada de SCLK; reset y SS dentro del mismo bloque
always @(negedge SCLK or posedge RST) begin
    if (RST) begin
        Q_SPI            <= {qs_spi_cont{1'b0}};
        middle           <= {WIDTH{1'b0}};
        middle2          <= {WIDTH{1'b0}};
        ind_duty         <= {WIDTH{1'b0}};
        ind_duty2        <= {WIDTH{1'b0}};
        modo_alineacion  <= 1'b0;
        modo_alineacion2 <= 1'b0;
        indice           <= 1'b0;
        //MISO           <= 1'b0;
    end else begin
        if (SS) begin
            // no seleccionado
            Q_SPI  <= {qs_spi_cont{1'b0}};
            indice <= 1'b0;
        end else begin
            // seleccionado
            if (Q_SPI < num_maximo_spi) begin
                Q_SPI <= Q_SPI + 1'b1;

                if (indice == 1'b0) begin
                    if (Q_SPI < WIDTH)
                        middle <= {middle[WIDTH-2:0], MOSI};
                    else begin
                        ind_duty        <= middle;
                        modo_alineacion <= MOSI;
                        Q_SPI           <= {qs_spi_cont{1'b0}};
                        indice          <= 1'b1;
                    end
                end else begin
                    if (Q_SPI < WIDTH)
                        middle2 <= {middle2[WIDTH-2:0], MOSI};
                    else begin
                        ind_duty2        <= middle2;
                        modo_alineacion2 <= MOSI;
                        Q_SPI            <= {qs_spi_cont{1'b0}};
                        indice           <= 1'b0;
                    end
                end

            end
        end
    end
end

endmodule

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- lfsr: linear feedback shift register
    -- metastable shift register ring oszillator(change value, wait for x CLK cycles, read value)
    -- combine different clock signals
    -- incrematally alter propagation lines
    -- Programmable delay inverter
        -- N SRAM cells -> select one bit with MUX (MUX-INPUT = ADDRESS of LUT, input contolls delay) (PDL)
        -- fill SRAM with incrementally altered values (or feedback of output)
            -- A_N controlls 1 MUX (last MUX), A_1 conrolls 2**(N-1) MUXs (first rown of MUXs)
            -- probability of outpurt bit val must be monitored (MONITOR_MODULE->CONTROL_MODULE:=(INCR. OR DECR. DELAY from TOP or BOTTOM PATH - using MUX-DELAY-PATH)) -> feedback for delay time
            -- MONITOR with counter: incr. CNT every time when OUTPUt=1, decr. CNT every time when OUTPUT=0; FEEDBACK_SIGNAL f(dCNT); FEED_BACK_SIGNAL -> ADDR for MUXs
              --              _____________
              -- S->+->[PDL]->|D         Q|-BINARY_SEQUENCE->[MONITOR]
              --    +->[PDL]->|> CLK      |       |              |
              --              |   D-FF    |       +->OUT         |
              --              |___________|                      |
              --                                                 |



entity rand_gen is
  generic(
    C_SEED_WIDTH: natural := 16
  );
  port(
    I_CLK100    : in std_logic;
    O_RAND_SEED : out std_logic_vector(C_SEED_WIDTH - 1 downto 0) := (others => '0')
  );
end rand_gen;


architecture rtl of rand_gen is



begin
end architecture rtl;
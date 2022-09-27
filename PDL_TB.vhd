library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

entity PDL_TB_E is
    generic (
        C_PORTS_PER_LUT: natural := 6;
        C_FLIP_TIME: time := 10 ns
    );
end entity PDL_TB_E;


architecture PDL_TB_A of PDL_TB_E is
    signal CLK_STOP : std_logic := '0';
    signal LUT_IN : std_logic_vector(C_PORTS_PER_LUT - 1 downto 0) := (others => '1');
    alias PROPAG_BIT : std_logic is LUT_IN(0);
    alias DELAY_CTRL : std_logic_vector(LUT_IN'high - 1 downto 0) is LUT_IN(LUT_IN'high downto 1);
    signal RAND_BIT : std_logic;
begin
    I_DUT: entity work.PDL_E
        generic map (
            C_PORTS_PER_LUT => C_PORTS_PER_LUT
        )
        port map (
            I_DELAY_CTRL => LUT_IN,
            O_OUT        => RAND_BIT
        );

    -- P_CLK_GEN: process
    -- begin
    --     PROPAG_BIT <= not PROPAG_BIT after C_FLIP_TIME;
    --     if (CLK_STOP = '1') then
    --         wait;
    --     end if;
    -- end process P_CLK_GEN;

    -- P_DECR_DELAY: process
    -- begin
    --     wait for C_FLIP_TIME;
    --     DELAY_CTRL <= '0' & DELAY_CTRL(DELAY_CTRL'high downto 1);
    --     if (CLK_STOP = '1') then
    --         wait;
    --     end if;
    -- end process P_DECR_DELAY;

    P_STOP_SIM: process
    begin
        wait for C_PORTS_PER_LUT * C_FLIP_TIME * 3;
        CLK_STOP <= '1';
        wait;
    end process P_STOP_SIM;

    LUT_IN(0) <= not LUT_IN(0) after C_FLIP_TIME;
    LUT_IN(LUT_IN'high downto 1) <= '0' & LUT_IN(LUT_IN'high downto 2) after 2 * C_FLIP_TIME;
end architecture PDL_TB_A;
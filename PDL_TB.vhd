library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

entity PDL_TB_E is
    generic (
        C_PORTS_PER_LUT: natural := 3
    );
end entity PDL_TB_E;


architecture PDL_TB_A of PDL_TB_E is
    signal DELAY_CTRL : std_logic_vector(C_PORTS_PER_LUT - 1 downto 1) := (others => '1');
    signal PROPAG_BIT : std_logic := '0';
    signal RAND_BIT : std_logic;
begin
    I_DUT : entity work.PLD_E
            generic map (
                C_PORTS_PER_LUT => C_PORTS_PER_LUT
            )
            port map (
                I_PROPAG_BIT => PROPAG_BIT,
                I_DELAY_CTRL => DELAY_CTRL,
                O_OUT        => RAND_BIT
            );

    PROPAG_BIT <= not PROPAG_BIT after 10 us;
end architecture PDL_TB_A;
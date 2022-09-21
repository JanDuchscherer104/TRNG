library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

entity PLD_E is
    generic(
        C_PORTS_PER_LUT: natural := 3
    );
    port(
        I_PROPAG_BIT: in std_logic;
        I_DELAY_CTRL: in std_logic_vector(C_PORTS_PER_LUT - 1 downto 1);
        O_OUT:        out std_logic
    );
end entity PLD_E;

architecture PLD_STRUCT_A of PLD_E is

    --signal SRAM: std_logic_vector(C_PORTS_PER_LUT - 1 downto 0);
    signal MUX_PROPAG_LINES : std_logic_vector(2 ** C_PORTS_PER_LUT - 3 downto 0);

begin
    I_MUX_0 : entity work.MUX_E
        generic map (
            C_MUX_NUM => 2 ** (C_PORTS_PER_LUT - 1)
        )
        port map (
            I_BITS_A => (others => '1'),
            I_BITS_B => (others => '0'),
            I_SELECT => I_PROPAG_BIT,
            O_PDL    => MUX_PROPAG_LINES(2 ** (C_PORTS_PER_LUT - 1) downto 0)
        );

    I_MUX_N : entity work.MUX_E
        generic map (
            C_MUX_NUM => 1
        )
        port map (
            I_BITS_A => MUX_PROPAG_LINES(2 ** C_PORTS_PER_LUT - 4),
            I_BITS_B => MUX_PROPAG_LINES(2 ** C_PORTS_PER_LUT - 3),
            I_SELECT => I_DELAY_CTRL(C_PORTS_PER_LUT - 1),
            O_PDL    => O_OUT
        );

    GEN_MUXS : for i in 1 to C_PORTS_PER_LUT - 2 generate
    begin
        I_MUX_i : entity work.MUX_E
        generic map (
            C_MUX_NUM => 2 ** i
        )
            port map ( -- 2 * 2 ** i lines must be connected to input
                I_BITS_A => MUX_PROPAG_LINES(2 ** i - 1 downto 2 ** (i - 1)),
                I_BITS_B => MUX_PROPAG_LINES(2 * 2 ** i - 1 downto 2 ** i),
                I_SELECT => I_DELAY_CTRL(i),
                O_PDL    => MUX_PROPAG_LINES(2 * 2 ** i + 1 downto 2 * 2 ** i)
        );
    end generate;

end architecture PLD_STRUCT_A;
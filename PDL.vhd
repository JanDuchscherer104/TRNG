library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

entity PDL_E is
    generic(
        C_PORTS_PER_LUT: natural := 6
    );
    port(
        I_PROPAG_BIT: in std_logic;
        I_DELAY_CTRL: in std_logic_vector(C_PORTS_PER_LUT - 1 downto 1);
        O_OUT:        out std_logic
    );
    attribute dont_touch : string;
    attribute dont_touch of PDL_E : entity is "true";
end entity PDL_E;

architecture PDL_STRUCT_A of PDL_E is
    signal MUX_PROPAG_LINES : std_logic_vector(2 ** C_PORTS_PER_LUT - 3 downto 0);
    signal PROPAG_BIT_OUT : std_logic_vector(0 downto 0);
    constant C_N_PROPAG_LINES : natural := MUX_PROPAG_LINES'length;

    attribute dont_touch of I_MUX_N : label is "true";
    attribute dont_touch of I_MUX_0 : label is "true";
    attribute dont_touch of MUX_PROPAG_LINES : signal is "true";
begin
    I_MUX_N : entity work.MUX_E
        generic map (
            C_MUX_NUM => 2 ** (C_PORTS_PER_LUT - 1)
        )
        port map (
            I_BITS_A => (others => '1'),
            I_BITS_B => (others => '0'),
            I_SELECT => I_PROPAG_BIT,
            O_PDL    => MUX_PROPAG_LINES(2 ** (C_PORTS_PER_LUT - 1) - 1 downto 0)
        );
    I_MUX_0 : entity work.MUX_E
        generic map (
            C_MUX_NUM => 1
        )
        port map (
            I_BITS_A => MUX_PROPAG_LINES(2 ** C_PORTS_PER_LUT - 4 downto 2 ** C_PORTS_PER_LUT - 4),
            I_BITS_B => MUX_PROPAG_LINES(2 ** C_PORTS_PER_LUT - 3 downto 2 ** C_PORTS_PER_LUT - 3),
            I_SELECT => I_DELAY_CTRL(C_PORTS_PER_LUT - 1),
            O_PDL    => PROPAG_BIT_OUT
        );

    GEN_MUXS : for j in 1 to C_PORTS_PER_LUT - 2 generate
        attribute dont_touch of I_MUX_j : label is "true";
    begin
        I_MUX_j : entity work.MUX_E
        generic map (
            C_MUX_NUM => 2 ** j
        )
            port map ( -- 2 * 2 ** j lines must be connected to input
                I_BITS_A => MUX_PROPAG_LINES(C_N_PROPAG_LINES - (3 * 2 ** j - 1) downto C_N_PROPAG_LINES - (2 ** (j + 2) - 2)),
                I_BITS_B => MUX_PROPAG_LINES(C_N_PROPAG_LINES - (2 ** (j + 1) - 1) downto C_N_PROPAG_LINES - (3 * 2 ** j - 2)),
                I_SELECT => I_DELAY_CTRL(j),
                O_PDL    => MUX_PROPAG_LINES(C_N_PROPAG_LINES - (2 ** j - 1) downto C_N_PROPAG_LINES - (2 ** (j + 1) - 2))
        );
    end generate;
    O_OUT <= PROPAG_BIT_OUT(0);

end architecture PDL_STRUCT_A;
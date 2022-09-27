library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

entity PDL_BLOCK_E is
    generic (
        C_N_PDLS: natural := 2**4;
        C_PORTS_PER_LUT: natural := 6
    );
    port (
        I_D_PROPAG_BIT: in std_logic;
        I_CLK_PROPAG_BIT: in std_logic;
        O_D_PROPAG_BIT: out std_logic;
        O_CLK_PROPAG_BIT: out std_logic;
        I_DELAY_CTRL: in std_logic_vector(C_PORTS_PER_LUT - 1 downto 1)
    );
end entity PDL_BLOCK_E;

architecture PLD_BLOCK_STRUCT_A of PDL_BLOCK_E is
    signal D_PROPAG_BIT: std_logic_vector(C_N_PDLS downto 0);
    signal CLK_PROPAG_BIT: std_logic_vector(C_N_PDLS downto 0);
begin
    GEN_PDLS: for j in 0 to C_N_PDLS - 1 generate
            I_PDL_D_j: entity work.PDL_E
                generic map (
                    C_PORTS_PER_LUT => C_PORTS_PER_LUT
                )
                port map (
                    I_PROPAG_BIT => D_PROPAG_BIT(j),
                    I_DELAY_CTRL => I_DELAY_CTRL,
                    O_OUT        => D_PROPAG_BIT(j + 1)
                );
            I_PDL_CLK_j: entity work.PDL_E
                generic map (
                    C_PORTS_PER_LUT => C_PORTS_PER_LUT
                )
                port map (
                    I_PROPAG_BIT => CLK_PROPAG_BIT(j),
                    I_DELAY_CTRL => not I_DELAY_CTRL,
                    O_OUT        => CLK_PROPAG_BIT(j + 1)
                );
        end generate GEN_PDLS;

    D_PROPAG_BIT(0) <= I_D_PROPAG_BIT;
    CLK_PROPAG_BIT(0) <= I_CLK_PROPAG_BIT;
    O_D_PROPAG_BIT <= D_PROPAG_BIT(C_N_PDLS);
    O_CLK_PROPAG_BIT <= CLK_PROPAG_BIT(C_N_PDLS);
end architecture PLD_BLOCK_STRUCT_A;

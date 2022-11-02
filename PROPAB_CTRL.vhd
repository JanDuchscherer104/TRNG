library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

-- library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

-- module pretty much useless, since the delay ctrl signals need to be encoded using crs and fn ctrl
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
                    I_DELAY_CTRL => not I_DELAY_CTRL, --todo not a perfect differential structure
                    O_OUT        => CLK_PROPAG_BIT(j + 1)
                );
        end generate GEN_PDLS;

    D_PROPAG_BIT(0) <= I_D_PROPAG_BIT;
    CLK_PROPAG_BIT(0) <= I_CLK_PROPAG_BIT;
    O_D_PROPAG_BIT <= D_PROPAG_BIT(C_N_PDLS);
    O_CLK_PROPAG_BIT <= CLK_PROPAG_BIT(C_N_PDLS);
end architecture PLD_BLOCK_STRUCT_A;

entity PROPAB_CTRL is
    generic (
        C_N_FN_PDLS: natural := 16;
        C_N_CRS_PDLS: natural := 16
    );
    port (
        I_CLK: in std_logic;
        I_RAND_BIT: in std_logic;
        O_DELAY_CTRL_D: out std_logic_vector(C_N_FN_PDLS + C_N_CRS_PDLS - 1 downto 0);
        O_DELAY_CTRL_CLK: out std_logic_vector(C_N_FN_PDLS + C_N_CRS_PDLS - 1 downto 0);
        O_PROPAB_ERR: out std_logic
    );
end entity PROPAB_CTRL;

architecture PROPAB_CTRL_BEHAV_A of PROPAB_CTRL is
    signal BIT_CNT: signed(C_N_FN_PDLS + C_N_CRS_PDLS - 1 downto 0) := (others => '0');
begin
    P_SAMPLE_BIT: process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            if (I_RAND_BIT = '1') then
                BIT_CNT <= BIT_CNT + 1;
            else
                BIT_CNT <= BIT_CNT - 1;
            end if;
            if (BIT_CNT = (BIT_CNT'range => '1') or BIT_CNT = (BIT_CNT'range => '0')) then
                O_PROPAB_ERR <= '1';
            end if;

        end if;
    end process P_SAMPLE_BIT;

    P_ENCODE_DELAY_CTRL: process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            O_DELAY_CTRL_D <= std_logic_vector(BIT_CNT);
        end if;
    end process P_ENCODE_DELAY_CTRL;

end architecture PROPAB_CTRL_BEHAV_A;

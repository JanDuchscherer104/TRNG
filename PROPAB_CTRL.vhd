library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity PROPAB_CTRL is
    generic (
        C_N_PDLS : natural := 5;
    );
    port (
        I_CLK: in std_logic;
        I_RAND_BIT: in std_logic;
        O_DELAY_CTRL_CLK: out std_logic_vector(C_N_PDLS - 1 downto 0);
        O_DELAY_CTRL_D: out std_logic_vector(C_N_PDLS - 1 downto 0);
        O_PROPAB_ERR: out std_logic
    );
end entity PROPAB_CTRL;

architecture PROPAB_CTRL_BEHAV_A of PROPAB_CTRL is
    signal BIT_CNT_RAW: unsigned(C_N_PDLS downto 0);
    alias BIT_CNT: unsigned(C_N_PDLS- 1 downto 0) is BIT_CNT_RAW(C_N_PDLS - 1 downto 0);
    alias CNT_SGN: std_logic is BIT_CNT(BIT_CNT_RAW'high);
begin
    P_SAMPLE_BIT: process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            if (I_RAND_BIT = '1') then
                if (CNT_SGN = '0' and BIT_CNT = (BIT_CNT'range => '0')) then
                    CNT_SGN <= '1';
                else
                    BIT_CNT <= BIT_CNT + 1;
                end if;
            else
                if (CNT_SGN = '1' and BIT_CNT = (BIT_CNT'range => '0')) then
                    CNT_SGN <= '0';
                else
                    BIT_CNT <= BIT_CNT + 1;
                end if;
            end if;
            if (BIT_CNT = (BIT_CNT'range => '1') or BIT_CNT = (BIT_CNT'range => '0')) then
                O_PROPAB_ERR <= '1';
            end if; -- err

        end if;
    end process P_SAMPLE_BIT;

    P_ENCODE_DELAY_CTRL: process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            O_DELAY_CTRL_D <= (others => '0');
            O_DELAY_CTRL_CLK <= (others => '0');
            if (CNT_SGN = '0') then
                O_DELAY_CTRL_CLK <= (to_integer(BIT_CNT) - 1 downto 0 => '1');
            else
                O_DELAY_CTRL_D <= (to_integer(BIT_CNT) - 1 downto 0 => '1');
            end if;
        end if;
    end process P_ENCODE_DELAY_CTRL;

end architecture PROPAB_CTRL_BEHAV_A;

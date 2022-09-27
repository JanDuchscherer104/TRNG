library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity PROPAB_CTRL is
    generic (
        C_DELAY_CTRL_LEN : natural := 5
    );
    port (
        I_CLK: in std_logic;
        I_RAND_BIT: in std_logic;
        O_DELAY_CTRL: out std_logic_vector(C_DELAY_CTRL_LEN - 1 downto 0);
        O_PROPAB_ERR: out std_logic
    );
end entity PROPAB_CTRL;

architecture PROPAB_CTRL_BEHAV_A of PROPAB_CTRL is
    signal BIT_CNT: signed(C_DELAY_CTRL_LEN - 1 downto 0) := (others => '0');
    constant C_CTRL_THRSHLD: signed(BIT_CNT'range) := to_signed(16, BIT_CNT'length);
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
            if (abs(BIT_CNT) < C_CTRL_THRSHLD) then -- fine ctrl
                O_DELAY_CTRL <= std_logic_vector(BIT_CNT);
            else -- coarse ctrl
                O_DELAY_CTRL <= std_logic_vector(BIT_CNT);
            end if;
        end if;
    end process P_ENCODE_DELAY_CTRL;

end architecture PROPAB_CTRL_BEHAV_A;

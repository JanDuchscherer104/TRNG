library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

entity TRNG_E is
    generic (
        C_N_FN_PDLS: natural := 16;
        C_N_CRS_PDLS: natural := 16;
        C_PORTS_PER_LUT: natural := 6;
        C_RAND_VECT_LEN: natural := 32
    );
    port (
        I_CLK: std_logic;
        I_PROPAG_BIT: in std_logic;
        I_SEND_RAND_VECT: in std_logic;
        O_PROPAB_ERR: out std_logic;
        O_RAND_VECT: out std_logic_vector(C_RAND_VECT_LEN - 1 downto 0)
    );
end entity TRNG_E;

architecture TRNG_STRUCT_A of TRNG_E is
    signal PROPAG_BIT_D: std_logic_vector(C_N_CRS_PDLS + C_N_FN_PDLS - 1 downto 0);
    signal PROPAG_BIT_CLK: std_logic_vector(C_N_CRS_PDLS + C_N_FN_PDLS - 1 downto 0);
    signal DELAY_CTRL_D: std_logic_vector(C_N_CRS_PDLS + C_N_FN_PDLS - 1  downto 0);
    signal DELAY_CTRL_CLK: std_logic_vector(C_N_CRS_PDLS + C_N_FN_PDLS - 1  downto 0);
    signal A_RAND_BIT: std_logic;
    signal RAND_VECT: std_logic_vector(C_RAND_VECT_LEN - 1 downto 0);

begin

    I_PROPAB_CTRL: entity work.PROPAB_CTRL -- needs rework
        generic map (
            C_N_FN_PDLS => C_N_FN_PDLS,
            C_N_CRS_PDLS => C_N_CRS_PDLS
        )
        port map (
            I_CLK        => I_CLK,
            I_RAND_BIT   => RAND_VECT(RAND_VECT'high),
            O_DELAY_CTRL_D => DELAY_CTRL_D, --todo
            O_DELAY_CTRL_CLK => DELAY_CTRL_CLK, --todo
            O_PROPAB_ERR => O_PROPAB_ERR
        );

    GEN_FN_PDL_BLOCKS: for i in 0 to C_N_FN_PDLS - 1 generate
    begin
       I_FN_PDL_D: entity work.PDL_E
                generic map (
                    C_PORTS_PER_LUT => C_PORTS_PER_LUT
                )
                port map (
                    I_PROPAG_BIT => PROPAG_BIT_D(i),
                    I_DELAY_CTRL => DELAY_CTRL_D & (C_PORTS_PER_LUT - 2 downto 1 => '0'),
                    O_OUT        => PROPAG_BIT_D(i + 1)
                    );

       I_FN_PDL_CLK: entity work.PDL_E
                generic map (
                    C_PORTS_PER_LUT => C_PORTS_PER_LUT
                )
                port map (
                    I_PROPAG_BIT => PROPAG_BIT_CLK(i),
                    I_DELAY_CTRL => DELAY_CTRL_CLK & (C_PORTS_PER_LUT - 2 downto 1 => '0'),
                    O_OUT        => PROPAG_BIT_CLK(i + 1)
                );
    end generate GEN_FN_PDL_BLOCKS;

    GEN_CRS_PDL_BLOCKS: for i in C_N_FN_PDLS to C_N_CRS_PDLS - 1 generate
    begin
       I_CRS_PDL_D: entity work.PDL_E
                generic map (
                    C_PORTS_PER_LUT => C_PORTS_PER_LUT
                )
                port map (
                    I_PROPAG_BIT => PROPAG_BIT_D(i),
                    I_DELAY_CTRL => (C_PORTS_PER_LUT - 1 downto 1 => DELAY_CTRL_D(i)),
                    O_OUT        => PROPAG_BIT_D(i + 1)
                    );
       I_CRS_PDL_CLK: entity work.PDL_E
                generic map (
                    C_PORTS_PER_LUT => C_PORTS_PER_LUT
                )
                port map (
                    I_PROPAG_BIT => PROPAG_BIT_CLK(i),
                    I_DELAY_CTRL => (C_PORTS_PER_LUT - 1 downto 1 => DELAY_CTRL_CLK(i)),
                    O_OUT        => PROPAG_BIT_CLK(i + 1)
                );
    end generate GEN_CRS_PDL_BLOCKS;

    PROPAG_BIT_D(0) <= I_PROPAG_BIT;
    PROPAG_BIT_CLK(0) <= I_PROPAG_BIT;

    A_RAND_BIT <= PROPAG_BIT_D(PROPAG_BIT_D'high) when rising_edge(PROPAG_BIT_CLK(PROPAG_BIT_CLK'high));

    P_SYNC: process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            RAND_VECT <= A_RAND_BIT & RAND_VECT(RAND_VECT'high downto 1);
            if (I_SEND_RAND_VECT = '1') then
                O_RAND_VECT <= RAND_VECT;
            end if;
        end if;
    end process P_SYNC;
end architecture TRNG_STRUCT_A;

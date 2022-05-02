


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity rndm is
  Port (
        clk: in std_logic;
        reset: in std_logic;
        B1: in std_logic;
        RS: out std_logic_vector(1 downto 0);
		ERS:in std_logic
         
        );
end rndm;

architecture Behavioral of rndm is

signal cont: std_logic;
signal prev_RS: std_logic_vector(1 downto 0);
signal RSaux: std_logic_vector(1 downto 0);
signal Q1B1, Q2B1, PB1: std_logic;

begin

--detector flancos B1

process(clk, reset)
begin
    if reset='1' then
        Q1B1<='0';
        Q2B1<='0';
    elsif clk'event and clk='1' then
        Q1B1<=B1;
        Q2B1<=Q1B1;
    end if;
end process;

PB1<='1' when Q1B1='1' and Q2B1='0' else '0';

process(reset,clk)
begin
    if reset='1' then
        RSaux<="00";
    elsif clk'event and clk='1' then
        if RSaux(0)='1' then
            RSaux(0)<='0';
        else 
            RSaux(0)<='1';
        end if;
        
        if ERS='1' then
            RS(1)<='0';
            
            if PB1='1' then
                RS(1)<='1';
                RS(0)<=RSaux(0);        
           end if;
        end if;
    end if;
end process;
       
            

end behavioral;

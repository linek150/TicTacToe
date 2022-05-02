


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tablero is
Port (
        clk: in std_logic;
        reset: in std_logic;
        CL: in std_logic_vector(8 downto 0);
        CP: in std_logic;
        FCLR: in std_logic;
        EG: in std_logic;
        CB: out std_logic_vector(17 downto 0);
        BA: out std_logic
        );
end tablero;

architecture Behavioral of tablero is

signal location_bits: std_logic_vector(8 downto 0);
signal player_bits: std_logic_vector(8 downto 0);
signal reg: std_logic_vector(17 downto 0);
signal anterior: std_logic_vector(8 downto 0);
signal cont: integer range 0 to 3;
signal reset_reg: std_logic;

begin

location_bits(0)<=CL(0) when CL(0)='1' and FCLR='1' else '0';
location_bits(1)<=CL(1) when CL(1)='1' and FCLR='1' else '0';
location_bits(2)<=CL(2) when CL(2)='1' and FCLR='1' else '0';
location_bits(3)<=CL(3) when CL(3)='1' and FCLR='1' else '0';
location_bits(4)<=CL(4) when CL(4)='1' and FCLR='1' else '0';
location_bits(5)<=CL(5) when CL(5)='1' and FCLR='1' else '0';
location_bits(6)<=CL(6) when CL(6)='1' and FCLR='1' else '0';
location_bits(7)<=CL(7) when CL(7)='1' and FCLR='1'  else '0';
location_bits(8)<=CL(8) when CL(8)='1' and FCLR='1' else '0';

player_bits(0)<=CP when location_bits(0)='1' else '0';
player_bits(1)<=CP when location_bits(1)='1' else '0';
player_bits(2)<=CP when location_bits(2)='1' else '0';
player_bits(3)<=CP when location_bits(3)='1' else '0';
player_bits(4)<=CP when location_bits(4)='1' else '0';
player_bits(5)<=CP when location_bits(5)='1' else '0';
player_bits(6)<=CP when location_bits(6)='1' else '0';
player_bits(7)<=CP when location_bits(7)='1' else '0';
player_bits(8)<=CP when location_bits(8)='1' else '0';

process(clk, reset)
    begin
    if reset='1' then
     reg<=(others=>'0');
     
     elsif clk'event and clk='1' then
     
     if reset_reg='0' then   
        
        reg(0)<=reg(0) or location_bits(0);
        reg(1)<=reg(1) or player_bits(0);
        reg(2)<=reg(2) or location_bits(1);
        reg(3)<=reg(3) or player_bits(1);
        reg(4)<=reg(4) or location_bits(2);
        reg(5)<=reg(5) or player_bits(2);
        reg(6)<=reg(6) or location_bits(3);
        reg(7)<=reg(7) or player_bits(3);
        reg(8)<=reg(8) or location_bits(4);
        reg(9)<=reg(9) or player_bits(4);
        reg(10)<=reg(10) or location_bits(5);
        reg(11)<=reg(11) or player_bits(5);     
        reg(12)<=reg(12) or location_bits(6);
        reg(13)<=reg(13) or player_bits(6);   
        reg(14)<=reg(14) or location_bits(7);
        reg(15)<=reg(15) or player_bits(7);
        reg(16)<=reg(16) or location_bits(8);
        reg(17)<=reg(17) or player_bits(8);   
       
     else 
        reg<=(others=>'0');
     end if;    
       
        
      
     end if;
     end process;
     
 --generador pulso BA
     process(clk, reset)
      begin
           if reset='1' then
                anterior<=(others=>'0');
                
                
                elsif clk'event and clk='1' then
                    
                    if location_bits="000000000" then
                        anterior<="000000000";
                     elsif location_bits="000000001" then
                        anterior<="000000001";
                     elsif location_bits="000000010" then
                        anterior<="000000010";
                     elsif location_bits="000000100" then
                        anterior<="000000100";
                     elsif location_bits="000001000" then
                        anterior<="000001000";
                     elsif location_bits="000010000" then
                        anterior<="000010000";
                     elsif location_bits="000100000" then
                        anterior<="000100000";
                     elsif location_bits="001000000" then
                        anterior<="001000000";
                     elsif location_bits="010000000" then
                        anterior<="010000000";
                     elsif location_bits="100000000" then
                        anterior<="100000000";
                     end if;
                     
                     
                    
                
 
                   end if;
               end process;

    process(clk, reset)
        begin
            if reset='1' then
                BA<='0';
                cont<=0;
                elsif clk'event and clk='1' then
                    if location_bits/=anterior and cont<1 then
                        BA<='1';
                        cont<=cont+1;
                        else
                        BA<='0';
                        cont<=0;
                        
                        end if;
                        end if;
                        end process;                                
    
    --detector del flanco de EG
    
  
                
    process(clk, reset)
    begin
        if reset='1' then
            CB<=(others=>'0');
            reset_reg<='0';
        elsif clk'event and clk='1' then
            if EG='0' then
                CB<=reg;
                reset_reg<='0';
            else
                CB<=(others=>'0');
                reset_reg<='1';
            end if;
         end if;
     end process;
     



end Behavioral;

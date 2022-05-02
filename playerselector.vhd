


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity playerselector is
  Port ( 
        clk: in std_logic;
        reset: in std_logic;
        RS: in std_logic_vector(1 downto 0); --Random selection
        EG: in std_logic;	--end games
        W: in std_logic_vector(1 downto 0); --winner
        NP: in std_logic; -- next player
        CP: out std_logic;--current player
        BL: out std_logic;--blinking leds
        IPA: out std_logic;
		ERS: out std_logic;--Enable write selection
		AIIPA: out std_logic
        
        );
end playerselector;

architecture Behavioral of playerselector is

signal CPaux: std_logic;

signal anterior: std_logic;

type state_t is (OFF,YES);
signal espera: state_t;
signal anterior_espera: state_t;
signal IPAin,Q1,Q2,Q3,Q4,secondIPA:std_logic;

begin

--CP change because of NP
    process(clk, reset)
        begin
             if reset='1' then
                CPaux<='1';--PONER A 1
                espera<=YES;
				ERS<='1';
             elsif clk'event and clk='1' then
             
             case espera is
                            when OFF=>
                                if EG='1' and W(1)='1' then
                                    espera<=YES;
									ERS<='1';--MAYBE CHANGE TO 1
									
                                end if;
                            when YES=>
                                if RS(1)='1' then
                                   CPaux<=RS(0);
                                    espera<=OFF;
									ERS<='0';	--MAYBE CHANGE TO 0								
                                end if;
                        end case;        
                    
                  --if EG='0' then
                 
                        if CPaux='0' and NP='1' then 
                                CPaux<='1';
                        elsif CPaux='1' and NP='1' then
                                CPaux<='0';
                        
                        end if;                        
                      
            
                   if espera=OFF  then
                        if CPaux='0' and NP='1' then 
                            CPaux<='1';
                            elsif CPaux='1' and NP='1' then
                                CPaux<='0';
  
                        end if;
              
                end if;
                
                if EG='1' and W(1)='0' then
                    if CPaux='0'  then 
                         CPaux<='1';
                    elsif CPaux='1'  then
                       CPaux<='0';
                  
                    end if;
                end if;
                
                
               end if;
       end process;
       
--implementacion de la maquina de estados comentada anteriormente.       

CP<=CPaux;



AIIPA<='1' when IPAin='1' and CPaux='0' else '0';


       --problema. imaginate que la partida termina empate y el ultimo jugador ha sido el 1. se lanzaria la asignacion aleatoria. 
       --si en esta asigancion aleatoria sale 1, no hay cambio de jugador, y no salta IPOFF.   

-- IPOFF impulse generation
process(clk, reset)
    begin
        if reset='1' then 
            anterior<='1';
            elsif clk'event and clk='1' then
                if CPaux='0' then
                    anterior<='0';
                    else
                        anterior<='1';
                        end if;
                        end if;
                        end process;
                        
process(clk, reset)
    begin
        if reset='1' then
            anterior_espera<=OFF;--ponerelo OFF
            elsif clk'event and clk='1' then
                if espera=OFF then
                    anterior_espera<=OFF;
                    else
                        anterior_espera<=YES;
                        end if;
                        end if;
                        end process;
                                            
                        
 process(clk, reset)
    begin
        if reset='1' then
            IPAin<='0';
            elsif clk'event and clk='1' then
                if CPaux='1' and anterior='0' then
                    IPAin<='1';
                elsif CPaux='0' and anterior='1' then
                    IPAin<='1';
                
               
                
                --elsif espera=OFF and anterior_espera=YES then
                   -- IPA<='1';
                    elsif espera=YES and anterior_espera=OFF then
                    IPAin<='1';
                    elsif EG='1' and W(1)='0' then
                        IPAin<='1';
                    else
                    IPAin<='0';
                 end if;
                
        end if;
                    end process;
          
--parpadeo indicando que espero a que pulsen B1          
          
BL<='1' when espera=YES and RS(1)='0' else '0';
             
IPA<=IPAin;
 

    

    


end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PointsCounter is
Port (
        clk: in std_logic;
        rst: in std_logic;
		CB: in std_logic_vector(17 downto 0);
		CP: in std_logic;
		BA: in std_logic;
        EG: out std_logic;
        EM: out std_logic;
        W: out std_logic_vector(1 downto 0);
		NP: out std_logic;
		R: out std_logic_vector(5 downto 0)
        );
end PointsCounter;

architecture Behavioral of PointsCounter is
signal TIAR: std_logic;--three in a row - '1' when in CB there is 3 in a row
signal NFP :std_logic;--no free position
signal tie: std_logic;-- 1 if on currentBoard there is tie
signal playedgames: unsigned(3 downto 0);-- number of games already played
signal inR: std_logic_vector(5 downto 0);-- Results 32 first player, 10 second player
constant numberOfRounds: unsigned:= "1000";
type state is (waiting,tieResult,point,goldenPoint);
signal currentState: state:=waiting;
signal numberOfTies: unsigned(3 downto 0):="0000";
signal bestOf: unsigned(3 downto 0):="0000";
signal NPsignal,BAin: std_logic;
signal IsGolden: std_logic;

begin

-- check if there is empty space in current board
NFP<='1' when
	CB(0)='1' and CB(2)='1' and CB(4)='1' and CB(6)='1' and CB(8)='1' and CB(10)='1' and CB(12)='1' and CB(14)='1' and CB(16)='1' else
	'0';
-- check if its a tie
tie<='1' when TIAR='0' and NFP='1' else '0';
-- detect three in a row
TIAR <= '1' when 
	(CB(0)='1' and CB(2)='1' and CB(4)='1' and CB(1)=CB(3) and CB(3)=CB(5)) or 		--First row 
	(CB(6)='1' and CB(8)='1' and CB(10)='1' and CB(7)=CB(9) and CB(9)=CB(11)) or 		--second row
	(CB(12)='1' and CB(14)='1' and CB(16)='1' and CB(13)=CB(15) and CB(15)=CB(17)) or -- third row
	(CB(0)='1' and CB(6)='1' and CB(12)='1' and CB(1)=CB(7) and CB(7)=CB(13)) or		--first column 
	(CB(2)='1' and CB(8)='1' and CB(14)='1' and CB(3)=CB(9) and CB(9)=CB(15)) or		--second column
	(CB(4)='1' and CB(10)='1' and CB(16)='1' and CB(5)=CB(11) and CB(11)=CB(17)) or	--third column
	(CB(0)='1' and CB(8)='1' and CB(16)='1' and CB(1)=CB(9) and CB(9)=CB(17)) or		--left up to right downto
	(CB(12)='1' and CB(8)='1' and CB(4)='1' and CB(13)=CB(9) and CB(9)=CB(5))			--left down to right up
	else '0';


--main process
process(clk,rst)
	begin
		if rst='1' then 
			EG<='0';
			EM<='0';
			W<="10";
			NPsignal<='0';
			inR<="000000";
			IsGolden<='0';
			playedgames<=(others=>'0');
			numberOfTies<=(others=>'0');
		elsif rising_edge(clk) then
			
				case currentState is
					when waiting => -- when we wait for point or tie 
						if BAin='1' then
						      NPsignal<='1';--generate impuls for player selector to change player 
							if TIAR='1' then 
								currentState<=point;
								playedgames<=playedgames+1;
								 NPsignal<='0';
							elsif tie='1' then
								currentState<=tieResult;
								playedgames<=playedgames+1;
								 NPsignal<='0';
							end if;
							if IsGolden='1' then 
							     NPsignal<='0';
							     currentState<=goldenPoint;
							end if;
							
						else 
							NPsignal<='0';--no need to change player(in else so it doesnt affect previous assignment
						end if;
						EG<='0';
						EM<='0';
						W<="00";
						bestOf<=numberOfRounds-numberOfTies;
						
						
					when point =>--CP scores a point
													--bestOf(3 downto 1)=bestOf/2
						if (unsigned(inR(5 downto 3)) = bestOf(3 downto 1)) and CP='0' then	-- when first player has one point less then needed to win and he scores
							W<="00";
							EM<='1';
							playedgames<=(others=>'0');
							
						elsif (unsigned(inR(2 downto 0)) = bestOf(3 downto 1)) and CP='1' then-- if second player has one point less then needed to win and he scores 
							W<="01";
							EM<='1';
							playedgames<=(others=>'0');
						elsif numberOfRounds=playedgames then --nobody wins so goldenPoint (possible scenario 3:2 2ties player 2 scores a point)
							isGolden<='1';
							inR<=(others=>'1');
							EG<='1';
							currentState<=waiting;
						else-- if nobody wins and there are still rounds to play then current player score a point
							if CP='0' then
								inR(5 downto 3)<=std_logic_vector(unsigned(inR(5 downto 3))+1);
							else
								inR(2 downto 0)<=std_logic_vector(unsigned(inR(2 downto 0))+1);
							end if;
							
							EG<='1';
							currentState<=waiting;
						end if;
						
						
					when tieResult=>
						if playedgames=numberOfRounds then -- if there is no more game then golden point
							isGolden<='1';
							inR<=(others=>'1');
							EG<='1';
							currentState<=waiting;
						elsif (unsigned(inR(5 downto 3)) = unsigned(bestOf(3 downto 1))) then-- if there was a tie and first player has points equel to bestOf/2 +1 then he wins	
							W<="00";
							EM<='1';
							playedgames<=(others=>'0');
						elsif (unsigned(inR(2 downto 0)) = unsigned(bestOf(3 downto 1))) then-- the same with player two
							W<="01";
							EM<='1';
							playedgames<=(others=>'0');
						else--if nobody wins and there is still game to play then 
							numberOfTies<=numberOfTies+1;
							W<="10";
							EG<='1';
							currentState<=waiting;
						end if;
					when goldenPoint=>
						EG<='0';
						NPsignal<='1';
						currentState<=waiting;
						if TIAR='1' then 
							if CP='0' then	
								W<="00";
							else 
								W<="01";
							end if;
							EM<='1';
							currentState<=goldenPoint;
							NPsignal<='0';
						elsif tie='1' then
							EG<='1';
							EM<='0';
							W<="10";
							NPsignal<='0';
						end if;	
						
					end case;
				
		end if;
	end process;      
	R<=inR;
	
--NP generator
process (rst,clk)
begin
	if rst='1' then
		NP<='0';
	elsif rising_edge(clk) then	
		if NPsignal='1' then
			NP<='1';
		else
			NP<='0';
		end if;
	end if;

end process;
	
-- keep signal BA(board updated) for one more clock
process(clk,rst)
begin
	if rst='1' then
		BAin<='0';
	elsif rising_edge(clk) then
		if BA='1' then
			BAin<='1';
		else 
			BAin<='0';
		end if;
	end if;
end process;

end Behavioral;
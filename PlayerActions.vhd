----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.11.2019 14:10:49
-- Design Name: 
-- Module Name: PlayerActions - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PlayerActions is
    Port (
    clk : in std_logic;
    rst : in std_logic;
   -- CP : in std_logic;--current player
    PAI: in std_logic;--player Action initiate this block
    B2,B3,B4: in std_logic;--botons
    F_0_1:in std_logic;--0.1 sec impuls
    B1: in std_logic;--confirmBotton
    CB: in std_logic_vector(17 downto 0);--current board
    CL: out std_logic_vector(8 downto 0);--current Location
    FCLR: out std_logic;--final current location ready
    CLDR: out std_logic;--current location display ready
    IL: out std_logic_vector(2 downto 0);-- invalid location 2 is enable 1&0 position of '8' message
    EF_0_1:out std_logic -- enable frequency divider
     );
end PlayerActions;

   architecture Behavioral of PlayerActions is
    type State is (waiting,choosingColumn,choosingRow,waitingForConfirm,waitingForDisplayingWrongChoice);
    signal choicePossible: std_logic;
    signal currentState: State;
    signal pushedButton:std_logic;
    signal pushingTimeCounter:unsigned(3 downto 0);
    signal resetChoice: std_logic;
	signal WPMP: std_logic;--'1' when wrong choice message has finished beeing displayed "wrong place message printed"
    type Column is (left,middle,right);
	signal startCountingIllegalLocation: std_logic;
    signal chosenColumn:Column;
    signal ILTimeCounter: unsigned(3 downto 0);
    type Row is (up,middle,down);
    signal chosenRow:Row;
    signal Q1B3,Q2B3:std_logic;--risign edge of the botton B3 detector
    signal Q1B2,Q2B2:std_logic;--risign edge of the botton B2 detector
    signal Q1B4,Q2B4:std_logic;--risign edge of the botton B4 detector
     signal B2RE,B3RE,B4RE:std_logic;--B2,B3,B4 RisignEdge
	signal rowChosen,columnChosen:std_logic;
    
    
    begin
    --state machine 
    CurStateUpdate: process(rst,clk)
    begin
        if rst='1' then 
            currentState<=Waiting;
            CLDR<='0';
	    FCLR<='0';
	    IL<=(others=>'0');
	    CL<=(others=>'0');

        elsif rising_edge(clk) then
            case currentState is 
                when waiting=> 
                    CLDR<='0';
                    FCLR<='0';
                    CL<=(others=>'0');
                    if PAI='1' then-- if block is initiated then wait for button in choos Column state
                        currentState<=choosingColumn;
                    end if;
                when choosingColumn=>
                    if columnChosen='1' then -- if column has been chosen start counting the time of pushing 
                        currentState<=choosingRow;
						CL<=(others=>'0');--reset Current Location vector
                        resetChoice<='0';--reset resetChoice variable
                    end if;
                when choosingRow=>
					if rowChosen='1' then 
						if choicePossible='1' then 
							CL(Row'pos(chosenRow)*3+Column'pos(chosenColumn))<='1';--set current location to chosen values
							CLDR<='1';--enable display to display CL
							currentState<=waitingForConfirm; 
						else 
							IL(2)<='1'; --send signal to display wrong location message
							IL(1 downto 0)<=std_logic_vector(to_unsigned(Column'pos(chosenColumn),2));--sent number of column that has benn chosen
							currentState<=waitingForDisplayingWrongChoice;
							resetChoice<='1';--there is need to make choice one more time
							CLDR<='0';--disable display tto display CL vector
						end if;
					end if;
                when waitingForDisplayingWrongChoice =>
                    if WPMP='1' then
                        currentState<=choosingColumn;
						IL<=(others=>'0');--stop display illegal location
                    end if;
                when waitingForConfirm=>
                    if B1='1' then -- confirmation
						CLDR<='0';--stop display CL vector
                        FCLR<='1';--signal to CB that CL can be read and saved 
                        currentState<=waiting;
                    elsif B2RE='1' or B3RE='1' or B4RE='1' then--make another choice
                        resetChoice<='1';
						currentState<=choosingColumn;
                    end if;
                
             end case;
        end if;
    end process;
    choicePossible<= '1' when CB(Row'pos(chosenRow)*6+Column'pos(chosenColumn)*2)='0' and rowChosen='1' else '0';--if chosen position is not yet occupied then it can be chosen
  
  
    
    -- Choosing Row
    ChoosingRowProc: process(clk,rst)
        begin
            if rst='1' then
                pushingTimeCounter<=(others=>'0');
                rowChosen<='0';
            elsif rising_edge(clk) then
                if currentState=choosingRow then
                    if pushedButton='1' and pushingTimeCounter<10 then--
                        if F_0_1 ='1' then
                            pushingTimeCounter<=pushingTimeCounter+1;
                        end if;
                    else
                        if pushingTimeCounter<5 then
                            chosenRow<=down;
                        elsif pushingTimeCounter<10 then
                            chosenRow<=middle;
                        else
                            chosenRow<=up;
                        end if;
			rowChosen<='1';
                    end if;
                else 
                    pushingTimeCounter<=(others=>'0');
                    rowChosen<='0';
                end if;
            end if;       
        end process;
 
    
    EF_0_1<='1'when (pushedButton='1') or (currentState=waitingForDisplayingWrongChoice) else '0'; --enable 0.1s frequency when button pushed
    pushedButton<='1' when (chosenColumn=left and B2='1') or (chosenColumn=middle and B3='1') or(chosenColumn=right and B4='1') else '0';
    
    --Choosing column
    ChoosingColumnProc: process(clk,rst)
    begin
        if rst='1' then
            columnChosen<='0';
 		chosenColumn<=left;
        elsif rising_edge(clk) then
            if currentState=choosingColumn then 
                if columnChosen='0' or resetChoice='1' then 
			if B2='1' or B3='1' or B4='1' then

                    		if B2='1' then 	
                    		    chosenColumn<=left;
                   		 elsif B3='1' then 
                  		    chosenColumn<=middle;
                    		elsif B4='1' then
                    	    		chosenColumn<=right;
                    		end if;
				columnChosen<='1';
			end if ;                  
                end if;
             elsif currentState=waiting or currentState=choosingRow then
                columnChosen<='0';          
             end if;
        end if;       
    end process;
	--CountingTime to display wrong position
	process(clk,rst)
	begin	
		if rst='1' then
			WPMP<='0';
			ILTimeCounter<=(others=>'0');
		elsif rising_edge(clk) then
			if currentState=waitingForDisplayingWrongChoice then
				if F_0_1='1' then
					if ILTimeCounter<9 then
						ILTimeCounter<=ILTimeCounter+1;
					else 
						ILTimeCounter<=(others=>'0');
						WPMP<='1';
					end if;
				end if;
			else 
				WPMP<='0';
			end if;
		end if;
	end process;
	  --detect rising_edge of B2
     process(clk,rst)
     begin
      if rst='1' then
          Q1B2<='0'; 
          Q2B2<='0';
      elsif rising_edge(clk) then
          Q1B2<=B2;
          Q2B2<=Q1B2;
      end if;
      end process;
      B2RE<='1' when Q1B2='1' and Q2B2='0' else '0';
          --detect rising_edge of B3
     process(clk,rst)
     begin
      if rst='1' then
          Q1B3<='0'; 
          Q2B3<='0';
      elsif rising_edge(clk) then
          Q1B3<=B3;
          Q2B3<=Q1B3;
      end if;
      end process;
      B3RE<='1' when Q1B3='1' and Q2B3='0' else '0';
              --detect rising_edge of B4
  process(clk,rst)
  begin
  if rst='1' then
      Q1B4<='0'; 
      Q2B4<='0';
  elsif rising_edge(clk) then
      Q1B4<=B4;
      Q2B4<=Q1B4;
  end if;
  end process;
   B4RE<='1' when Q1B4='1' and Q2B4='0' else '0';
      
end Behavioral;


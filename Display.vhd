library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Display is
port (
	clk : in std_logic;
	reset: in std_logic;
	BL: in std_logic;
	CP: in std_logic;
	CL: in std_logic_vector (8 downto 0);
	CLDR: in std_logic;
	CB: in std_logic_vector (17 downto 0);
	EM: in std_logic;
	W: in std_logic_vector (1 downto 0);
	R: in std_logic_vector (5 downto 0);
	IL: in std_logic_vector (2 downto 0);
	leds: out std_logic_vector (7 downto 0);
	segments: out std_logic_vector (6 downto 0);
	selector: out std_logic_vector (3 downto 0);
	VFF: in std_logic; -- very fast
	FF: in std_logic; -- fast
	SF: in std_logic; -- slow
	SW:in std_logic --Slow wave for blinking leds and blinking CL
	
     );
end Display;

architecture behavioral of Display is

-- aux signals
signal interna: std_logic_vector (6 downto 0);

signal CB_one: std_logic_vector (8 downto 0);
signal CB_two: std_logic_vector (8 downto 0);
signal CB_both: std_logic_vector (8 downto 0);
signal leds_ini: std_logic_vector (7 downto 0);

signal left: std_logic_vector (6 downto 0);
signal mid: std_logic_vector (6 downto 0);
signal right: std_logic_vector (6 downto 0);
signal leftd: std_logic_vector (6 downto 0);
signal midd: std_logic_vector (6 downto 0);
signal rightd: std_logic_vector (6 downto 0);
signal leftad: std_logic_vector (6 downto 0);
signal midad: std_logic_vector (6 downto 0);
signal rightad: std_logic_vector (6 downto 0);
signal player: std_logic_vector (6 downto 0);
signal winner: std_logic_vector (6 downto 0);
signal invalid: std_logic_vector (6 downto 0);


signal count : unsigned (1 downto 0);
signal intensity_counter : unsigned (2 downto 0);

-- leds
signal points_one: std_logic_vector (5 downto 0);
signal points_two: std_logic_vector (5 downto 0);
signal player_one: std_logic_vector (7 downto 0);
signal player_two: std_logic_vector (7 downto 0);




signal cnt_em: unsigned (1 downto 0); 
signal dir: std_logic; 


begin









--- Board ---

process(clk,reset)
begin
if reset = '1' then
 CB_one <= (others => '0');
 CB_two <= (others => '0');
 CB_both <= (others => '0');
elsif clk'event and clk ='1' then
    if CB(0) = '1' then
         if CB(1) = '0' then
            CB_one(0) <= '1';
        
         else
            CB_two(0) <= '1';

       end if;
    end if;
    if CB(2) = '1' then
        if CB(3) = '0' then
            CB_one(1) <= '1';
  
         else
            CB_two(1) <= '1';

       end if;
    end if;
    if CB(4) = '1' then
        if CB(5) = '0' then
           CB_one(2) <= '1';

         else
           CB_two(2) <= '1';

       end if;
    end if;
    if CB(6) = '1' then
        if CB(7) = '0' then
           CB_one(3) <= '1';

         else
           CB_two(3) <= '1';

       end if;
    end if;
    if CB(8) = '1' then
        if CB(9) = '0' then
           CB_one(4) <= '1';
 
         else
           CB_two(4) <= '1';

       end if;
    end if;
    if CB(10) = '1' then
        if CB(11) = '0' then
           CB_one(5) <= '1';

         else
           CB_two(5) <= '1';

       end if;
    end if;
    if CB(12) = '1' then
        if CB(13) = '0' then
           CB_one(6) <= '1';
 
         elsif CB(13)='1' then
           CB_two(6) <= '1';

       end if;
    end if;
    if CB(14) = '1' then
        if CB(15) = '0' then
           CB_one(7) <= '1';

         elsif CB(15) ='1' then
           CB_two(7) <= '1';

       end if;
    end if;
    if CB(16) = '1' then
        if CB(17) = '0' then -- if it's player one
           CB_one(8) <= '1';

         elsif CB(17) = '1' then
           CB_two(8) <= '1';

       end if;
    end if;

if intensity_counter = "111"  then
 CB_both <= (CB_one or CB_two);
else  CB_both <= CB_one;
end if;
 if unsigned(CB)=0 then
    CB_one <= (others => '0');
    CB_two <= (others => '0');
end if;

end if;
end process;



                --- Chosen Location (after checking availability)---
process(clk,reset)
begin
if reset = '1' then
    interna <= (others => '1');
elsif clk'event and clk ='1' then
 
        if CL(0) = '1' then
            interna <=  "0111111";
        elsif  CL(1) = '1' then
            interna <= "0111111";
        elsif  CL(2) = '1' then
            interna  <=  "0111111";
        elsif  CL(3) = '1' then
            interna <=  "1111110";
        elsif  CL(4) = '1' then
            interna <= "1111110";
        elsif  CL(5) = '1' then
            interna <= "1111110";
        elsif  CL(6) = '1' then
            interna <="1110111";
        elsif  CL(7) = '1' then
            interna <="1110111";
        elsif  CL(8) = '1' then
            interna <= "1110111";
        end if;
   
 
     end if;

end process;




process(clk,reset)
begin
if reset = '1' then
    left <= (others => '1');
    mid <= (others => '1');
    right <= (others => '1');
	leftad <= (others => '1');
    midad <= (others => '1');
    rightad <= (others => '1');
 elsif clk'event and clk ='1' then
 left <= not CB_both(0) & "11" & not CB_both(6) & "11" & not CB_both(3);
 mid <= not CB_both(1) & "11" & not CB_both(7) & "11" & not CB_both(4); 
 right <= not CB_both(2) & "11" & not CB_both(8) & "11" & not CB_both(5);
 
    if IL(2) = '1' then
        if IL= "100" then
            leftad <= invalid;
        elsif IL = "101" then
            midad <= invalid;
        elsif IL = "110" then
            rightad <= invalid;
        end if;
	
	elsif EM ='1' then
     leftad <= winner;
     midad <= winner;
     rightad <= winner;

    
    elsif CLDR='1' and SW='1' then
    
 
   
		if CL(0) = '1' or CL(3) = '1' or CL(6) = '1' then
			leftad <= interna;
        elsif CL(1) = '1' or CL(4) = '1' or CL(7) = '1' then
			midad <= interna;
        elsif CL(2) = '1' or CL(5) = '1' or CL(8) = '1' then
			rightad <= interna;
        end if;
	else 
		leftad <= (others=>'1');
		midad <= (others=>'1');
		rightad <= (others=>'1');
	end if;
end if;
end process;
						--- Add current board and additional elements to displays--
leftd<=left and leftad when EM='0' else leftad;
midd<=mid and midad when EM='0' else midad;
rightd<=right and rightad when EM='0' else rightad;



                        --- Invalid Location ---
process(clk,reset)
begin
if reset = '1' then
    invalid <= (others => '1');
elsif clk'event and clk ='1' then
	if IL(2) = '1' then
	   invalid <= (others => '0');
	end if;
end if;
end process;


                             ---End match---
process(clk,reset)
begin
if reset = '1' then
intensity_counter <= (others => '0');
elsif clk'event and clk = '1' then
    if VFF= '1' then 
        if intensity_counter = "111" then
        intensity_counter  <= (others => '0');
        else
        intensity_counter  <= intensity_counter +  1;
        end if;
    end if;

end if;
end process;

                             
process(clk,reset)
begin
if reset = '1' then
    cnt_em <= (others => '0'); 
    dir<='1'; 
elsif clk'event and clk ='1' then
	if EM='1' then
        if W="00" then
            winner <= "1001111"; 

        elsif W="01" then
            winner <= "0010010";

        end if;
     if SF= '1' then 
        if dir='1' then 
            cnt_em <= cnt_em +1; 
            if cnt_em = "10" then 
              dir<='0'; 
            end if; 
        
        elsif dir = '0' then 
            cnt_em <= cnt_em -1; 
            if cnt_em = "01" then 
             dir<='1'; 
            end if; 
          end if; 
        end if; 
	end if;
end if;
end process;



          

                  ----current player---
process(clk,reset)
begin
if reset = '1' then
    player <= (others => '1');
elsif clk'event and clk ='1' then
    if EM = '1' then
        player <= winner;
    else
		if CP = '0' then
			player <= "1001111";
		elsif CP = '1' then
			player <= "0010010";
		end if;
	end if;
end if;

end process;



                                     -- 7 segments displays--
process(clk,reset)
begin
if reset = '1' then
   count <= (others => '0');
elsif clk'event and clk ='1' then
if EM = '1' then
count <= cnt_em;
end if;
if EM = '0' then
    if FF= '1' then 
        if count = "11" then
            count  <= (others => '0');
        else
            count  <= count +  1;
        end if;
    end if;
  end if;
end if;
end process;

 

with count select
    selector <= "0001" when "00",
                "0010" when "01",
                "0100" when "10",
                "1000" when "11",
                "0000" when others;
            
with count select
    segments <= player when "00",
                rightd when "01",
                midd when "10",
                leftd when "11",
                "XXXXXXX" when others;
                
                
            
                                   
                                      -- Leds ---
                                      

                                      
points_one <= R and "111000"; -- máscara para aislar los puntos de jugador 1
player_one<= "00000000" when points_one = "000000" else
            "10000000" when points_one = "001000" else
            "11000000" when points_one = "010000" else
            "11100000" when points_one = "011000" else
            "11110000" when points_one = "100000"  else
            "00000000";

points_two <= R and "000111";
player_two<=  "00000001" when points_two = "000001" else
            "00000011" when points_two = "000010" else
            "00000111" when points_two = "000011" else
            "00001111" when points_two = "000100" else
            "00000000" when points_two = "000000" else
            "00000000";

leds <= (others=>'1') when BL = '1' and SW='1' else (player_one or player_two); -- junta los leds de puntos de ambos jugadores


end behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
entity tb_Top is
  
end tb_Top;

architecture Behavioral of tb_Top is

component AI 
 Port (
   clk     : in std_logic;
   rst     : in std_logic;
   CP         : in std_logic;--current player
   AIPAI    : in std_logic;--Artificial Intelligence player action iniciation
   AICB     : in std_logic_vector(17 downto 0);
   AION    : in std_logic_vector(1 downto 0);
   AICL    : out std_logic_vector(8 downto 0);
   AIFCLR    :out std_logic
    );
end component;


component PlayerActions 
Port (
    clk : in std_logic;
    rst : in std_logic;
   -- CP : in std_logic;--current player
    PAI: in std_logic;--player Action initiate my block
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
end component; 

component FrequencyDivider
Port (
    clk     : in  std_logic;
    rst  : in  std_logic;
    SW:out std_logic;
	VFF: out std_logic;--Very fast frequency for distinct players
	FF: out std_logic;--Fast frequency for 7 segments display
	SF: out std_logic;--Slow frequency for leds and displaying winner
	EF_0_1 :in std_logic;--enable 0.1 sec frequency
	DF: out std_logic;--impulse generated afer 1milisecond/7.DF=Debouncer frecuency
	F_0_1	:out std_logic;--one clk period pulse every 0.1 sec.
	DIV	:in std_logic
     );
end component; 

component playerselector
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
        AIIPA: out std_logic;
		ERS: out std_logic--Enable write selection
        
        );
end component;

component rndm
  Port (
        clk: in std_logic;
        reset: in std_logic;
        B1: in std_logic;
		ERS: in std_logic;
        RS: out std_logic_vector(1 downto 0)
        );
end component;

component tablero
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
end component;

component PointsCounter
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
end component;

component Display
port (
	clk : in std_logic;
	reset: in std_logic;
	BL: in std_logic;
	CP: in std_logic;
	CL: in std_logic_vector (8 downto 0);
	CLDR: in std_logic;
	CB: in std_logic_vector (17 downto 0);
	EM: in std_logic;
	SW:in std_logic;
	W: in std_logic_vector (1 downto 0);
	R: in std_logic_vector (5 downto 0);
	IL: in std_logic_vector (2 downto 0);
	leds: out std_logic_vector (7 downto 0);
	segments: out std_logic_vector (6 downto 0);
	selector: out std_logic_vector (3 downto 0);
	VFF: in std_logic; -- very fast
    FF: in std_logic; -- fast
    SF: in std_logic -- slow
        
     );
end component;

component Debouncer
Port (
	clk: in STD_LOGIC;
	reset : in std_logic;
	boton : in STD_LOGIC;
	DF: in std_logic; --divider frecuecny
	filtrado : out STD_LOGIC
);
end component;

		


signal clk,rst,B1,B2,B3,B4,speed,BA,NP,BL,CP,ERS,PAI,FCLR,CFCLR,CLDR,EF_0_1,F_0_1,EG,EM,VFF,FF,SF,DF,filtrado,SW, FB1,FB2,FB3,FB4,AIFCLR,AIPAI: std_logic:='0';
signal RS,W,mode:std_logic_vector(1 downto 0):="00";
signal IL:std_logic_vector(2 downto 0):=(others=>'0');
signal R:std_logic_vector(5 downto 0):=(others=>'0');
signal CL,AICL,CCL:std_logic_vector(8 downto 0):=(others=>'0');--combined current location
signal CB:std_logic_vector(17 downto 0):=(others=>'0');
signal segments:std_logic_vector(6 downto 0):=(others=>'0');
signal selector:std_logic_vector(3 downto 0):=(others=>'0');
signal leds:std_logic_vector(7 downto 0):=(others=>'0');
constant clk_period: time:=4ns;

begin
CCL<=CL or AICL;--player and AI player Current location ready
CFCLR<=FCLR or AIFCLR;--player and AI player FCLR bit ready

AI_BLOCK:AI
Port map(
clk=>clk,
    rst=>rst, 	
    CP=>CP, 	
	AIPAI=>AIPAI,
	AICB=>CB, 	
	AION=>mode,	
	AICL=>AICL,	
	AIFCLR=>AIFCLR
     );
        

PC:PointsCounter
Port map(
        clk=>clk,
        rst=>rst,
		CB=>CB,
		CP=>CP,
		BA=>BA,
        EG=>EG,
        EM=>EM,
        W=>W,
		NP=>NP,
		R=>R
        );

FD: FrequencyDivider
port map
(
    clk=>clk,-- : in std_logic;
    rst=>rst,-- : in std_logic;
    F_0_1=>F_0_1,
    EF_0_1=>EF_0_1,
	VFF=>VFF,
	FF=>FF,
	SW=>SW,
	SF=>SF,
	DIV=>SPEED

);
PA:PlayerActions 
port map
(
    clk=>clk,-- : in std_logic;
    rst=>rst,-- : in std_logic;
    --CP=>CP,-- : in std_logic;--current player
    PAI=>PAI,--: in std_logic;--player Action initiate my block
    B2=>FB2,-- in std_logic;--botons
    B3=>FB3,
    B4=>FB4,
    F_0_1=>F_0_1,--in std_logic;--0.1 sec impuls
    B1=>FB1,-- in std_logic;--confirmBotton
    CB=>CB,-- in std_logic_vector(17 downto 0);--current board
    CL=>CL,--out std_logic_vector(2 downto 0);--current Location
    FCLR=>FCLR,--: out std_logic;--final current location ready
    CLDR=>CLDR,--current location display ready
    IL=>IL,
    EF_0_1=>EF_0_1
);
PS:playerselector
Port map
( 
	clk=>clk,
	reset=>rst,
	RS=>RS,
	EG=>EG,
	W=>W,
	NP=>NP,
	CP=>CP,
	BL=>BL,
	ERS=>ERS,
	IPA=>PAI,
	AIIPA=>AIPAI
);

RAN:rndm
Port map
(
	clk=>clk,
	reset=>rst,
	B1=>FB1,
	ERS=>ERS,
	RS=>RS
);

T:tablero
Port map
(
	clk=>clk,
	reset=>rst,
	CL=>CCL,
	CP=>CP,
	FCLR=>CFCLR,
	EG=>EG,
	CB=>CB,
	BA=>BA
);

DISP:Display
Port map
(
	clk=>clk,
	reset=>rst,
	BL=>BL,
	CP=>CP,
	CL=>CL,
	CLDR=>CLDR,
	SW=>SW,
	CB=>CB,
	EM=>EM,
	W=>W,
	R=>R,
	IL=>IL,
	leds=>leds,
	segments=>segments,
	selector=>selector,
	VFF=>VFF,
	FF=>FF,
	SF=>SF
);

DEBOUNCER1:Debouncer
Port map
(
	clk=>clk,
	reset=>rst,
	boton=>B1,
	DF=>DF,
	filtrado=>FB1
);

DEBOUNCER2:Debouncer
Port map
(
	clk=>clk,
	reset=>rst,
	boton=>B2,
	DF=>DF,
	filtrado=>FB2
);

DEBOUNCER3:Debouncer
Port map
(
	clk=>clk,
	reset=>rst,
	boton=>B3,
	DF=>DF,
	filtrado=>FB3
);

DEBOUNCER4:Debouncer
Port map
(
	clk=>clk,
	reset=>rst,
	boton=>B4,
	DF=>DF,
	filtrado=>FB4
);




clk_process: process
                begin
                    clk<='0';
                    wait for clk_period/2;
                    clk<='1';
                    wait for clk_period/2;
                end process;
                
stim_process: process
                begin
                    rst<='1';
                    SPEED<='1';
                    mode<="11";
                    wait for 20 ns;
                    rst<='0';
                    B1<='1';
                    wait for 70 ns;
                    B1<='0';
                    wait for 200 ns;
                    B4<='1';
                    wait for 70 ns;
                    B4 <='0';
                    B1<='1';
                    wait for 70 ns;
                    B1<='0';
                   
                    wait;
                 end process;



end Behavioral;

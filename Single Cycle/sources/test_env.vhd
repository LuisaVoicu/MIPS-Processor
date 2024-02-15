----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2023 02:49:55 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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

--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
signal cnt: std_logic_vector(15 downto 0);
signal result: std_logic_vector(7 downto 0);
signal afis: std_logic_vector(15 downto 0);
signal en: std_logic;
signal reset: std_logic;

type ROM_type is array(0 to 255) of std_logic_vector(15 downto 0);
signal ROM_M: ROM_type:=(x"0105",x"1234",x"78AF",others=>x"123C");
signal data: std_logic_vector(15 downto 0);

signal aux1: std_logic_vector( 3 downto 0);
signal aux_sum : std_logic_vector(15 downto 0);
signal rd1: std_logic_vector(15 downto 0);
signal rd2: std_logic_vector(15 downto 0);
signal we: std_logic;

component  MPG is
    Port ( btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           en : out STD_LOGIC);
           
end component;


component  SSD is
    Port ( num : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end component SSD;


component InstrFetch is
    Port ( en : in STD_LOGIC;
           clk : in STD_LOGIC;
           pc_src: in STD_LOGIC;
           jmp : in STD_LOGIC;
           brAddr : in STD_LOGIC_VECTOR(15 downto 0);
           jAddr : in STD_LOGIC_VECTOR(15 downto 0);
           pcPlus : out STD_LOGIC_VECTOR (15 downto 0);
           instr : out STD_LOGIC_VECTOR (15 downto 0);
           reset : in std_logic);
end component InstrFetch;


component reg_file is
port (
clk : in std_logic;
ra1 : in std_logic_vector (3 downto 0);
ra2 : in std_logic_vector (3 downto 0);
wa : in std_logic_vector (3 downto 0);
wd : in std_logic_vector (15 downto 0);
wen : in std_logic;
rd1 : out std_logic_vector (15 downto 0);
rd2 : out std_logic_vector (15 downto 0)
);
end component reg_file;


component rams_no_change is
port ( clk : in std_logic;
we : in std_logic;
en : in std_logic;
addr : in std_logic_vector(7 downto 0);
di : in std_logic_vector(15 downto 0);
do : out std_logic_vector(15 downto 0));
end component rams_no_change;


signal dout:std_logic_vector(15 downto 0);
signal din:std_logic_vector(15 downto 0);


signal pcPlus:std_logic_vector(15 downto 0);
signal instr: std_logic_vector(15 downto 0);



component ID is
    Port ( 
           clk :in STD_LOGIC;
           en: in std_logic;
           RegWrite : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (15 downto 0);
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR (15 downto 0);
           RD2 : out STD_LOGIC_VECTOR (15 downto 0);
           Ext_Imm : out STD_LOGIC_vector (15 downto 0);
           func : out STD_LOGIC_VECTOR (2 downto 0);
           sa : out STD_LOGIC;
           wd : in STD_LOGIC_VECTOR (15 downto 0));
end component ID;


component EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           Ex_imm : in STD_LOGIC_VECTOR (15 downto 0);
           ALUsrc : in STD_LOGIC;
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           ALUop : in STD_LOGIC_VECTOR (2 downto 0);
           Zero : out STD_LOGIC;
           ALURes : inout STD_LOGIC_VECTOR (15 downto 0));
end component EX;

component MEM is
    Port ( clk : in std_logic;
           MemWrite : in STD_LOGIC;
           AluRes : inout STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemData : out STD_LOGIC_VECTOR(15 downto 0));
end component MEM;

signal regDst:std_logic;
signal  extOp: std_logic;
signal aluSRC: std_logic;
signal branch:std_logic;
signal Jmp:std_logic;
signal memWrite:std_logic;
signal memToReg:std_logic;
signal regWr:std_logic;
signal regwrite2:std_logic;
signal aluOp:std_logic_vector(2 downto 0);

--aluctrl
signal pcSrc: std_logic;
signal ext_imm : std_logic_vector (15 downto 0);
signal wd : std_logic_vector(15 downto 0);
signal sa:std_logic;
signal func:std_logic_vector(2 downto 0);


--pt if
signal jumpAddr:STD_LOGIC_VECTOR(15 downto 0);
signal brAddr:STD_LOGIC_VECTOR(15 downto 0);

--pt ex
signal aluRes: STD_LOGIC_VECTOR(15 downto 0);
signal zero: STD_LOGIC;


--pt mem
signal memData: STD_LOGIC_VECTOR(15 downto 0);
signal out_ssd : std_logic_vector(15 downto 0);
signal aux_instr:std_logic_vector(2 downto 0);
signal ext_imm_x_4:std_logic_vector(15 downto 0);

--

signal sw_aux:std_logic;
begin       

             
--             en : in STD_LOGIC;
--           clk : in STD_LOGIC;
--           pc_src: in STD_LOGIC;
--           jmp : in STD_LOGIC;
--           brAddr : in STD_LOGIC_VECTOR(15 downto 0);
--           jAddr : in STD_LOGIC_VECTOR(15 downto 0);
--           pcPlus : out STD_LOGIC_VECTOR (15 downto 0);
--           instr : out STD_LOGIC_VECTOR (15 downto 0);
--           reset : in std_logic);
                             
-- reg write?


M1: MPG port map(btn(0),clk,en);
MP2: MPG port map(btn(1),clk,reset);
                                        
                                 
-- todo                                        
--jumpAddr<=x"0006"; 
--JumpAddress<=PCplus1(15 downto 13) & Instruction(12 downto 0);
jumpAddr <= pcPlus(15 downto 13) & instr(12 downto 0);            
pcSrc <= Branch and zero;

-- calcul branch addres (sumator)
-- br = pc+1 +  ext_imm*4  ??????

ext_imm_x_4 <= ext_imm; --(15 downto 4)& "00";
brAddr<=pcPlus + ext_imm_x_4;
INSF: InstrFetch port map(en,clk,pcSrc,Jmp,brAddr,jumpAddr,pcPlus,instr,reset); -- pune pcSrc pe locu lu sw to do schimba 6 si 2 cu date de undeva -- btn(1) e pt reset 




--  clk :in STD_LOGIC;
--           RegWrite : in STD_LOGIC;
--           Instr : in STD_LOGIC_VECTOR (15 downto 0);
--           RegDst : in STD_LOGIC;
--           ExtOp : in STD_LOGIC;
--           RD1 : out STD_LOGIC_VECTOR (15 downto 0);
--           RD2 : out STD_LOGIC_VECTOR (15 downto 0);
--           Ext_Imm : out STD_LOGIC_vector (15 downto 0);
--           func : out STD_LOGIC_VECTOR (2 downto 0);
--           sa : out STD_LOGIC;
--           wd : in STD_LOGIC_VECTOR (15 downto 0));



--to do wd-ul vine de la mux din dreapta

      regwrite2<=regwr and en;

IDD: ID port map(clk,en,regwrite2,instr,regDst,extop,rd1,rd2,ext_imm,func,sa,wd);



--RD1 : in STD_LOGIC_VECTOR (15 downto 0);
--           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
--           Ex_imm : in STD_LOGIC_VECTOR (15 downto 0);
--           ALUsrc : in STD_LOGIC;
--           sa : in STD_LOGIC;
--           func : in STD_LOGIC_VECTOR (2 downto 0);
--           ALUop : in STD_LOGIC_VECTOR (2 downto 0);
--           Zero : out STD_LOGIC;
--           ALURes : inout STD_LOGIC_VECTOR (15 downto 0));
EXX: EX port map(rd1,rd2,ext_imm,aluSrc,sa,func,aluOp,zero,AluRes);



--entity MEM is
--    Port ( clk : in std_logic;
--           MemWrite : in STD_LOGIC;
--           AluRes : inout STD_LOGIC_VECTOR(15 downto 0);
--           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
--           MemData : out STD_LOGIC_VECTOR(15 downto 0));
--end MEM;

DATA_MEM: MEM port map(clk,memWrite,aluRes,RD2,MemData);


-- mux in care intra memToReg si duce semnalul la wd

process(memToReg) begin
case(memToReg) is
when '1' => wd <= MemData;
when '0' => wd <= aluRes;
end case;
end process;



--data<=instr when sw(5)='1' else pcPlus;
--led<=data;

sw_aux<=sw(1);
process(sw) begin
case sw(15 downto 13) is
when "000" => out_ssd <= instr;
when "001" => out_ssd <= pcplus;
when "010" => out_ssd <= rd1;
when "011" => out_ssd <= rd2;
when "100" => out_ssd <= ext_imm;
when "101" => out_ssd <= alures;
when "110" => out_ssd <= memdata;
when "111" => out_ssd <= wd;
when others => out_ssd <= x"0000";
end case;
end process;

--led(15 downto 13) <= out_ssd;

M2: SSD port map(out_ssd,clk,an,cat); -- PT ROM
--led <=instr;





-- mux pt 5

--process(sw) begin
--case(sw(15 downto 13)) is
--when "000" => out_ssd<=pcplus;
--when "001" => out_ssd<=instr;
--when "010" => out_ssd<=rd1;
--when "011" => out_ssd<=rd2;
--when "100" => out_ssd<=ext_imm;
--when others => out_ssd<=x"0000";
--end case;
--end process;






-- uc


--signal regDst:std_logic; xxxx
--signal  extOp: std_logic; xxxx
--signal aluSRC: std_logic;
--signal branch:std_logic;
--signal Jmp:std_logic; xxxx
--signal memWrite:std_logic;
--signal memToReg:std_logic;
--signal regWr:std_logic;  xxxx

aux_instr <= instr(15 downto 13);




process(aux_instr) begin
       regDst<='0'; 
       extop<='0';
       aluSrc<='0';
       branch<='0'; 
       jmp<='0';
       memWrite<='0';
       memToReg<='0';
       regWr<='0';
       aluop<="000";
       led(0)<='0';
       
    case(aux_instr) is
        when "000" =>
            -- tip r
            regDst<='1';
            regWr<='1';
            aluop<="000";
     
        when "001"=>
            -- addi
            extOp<='1';
            regWr<='1';
            aluSrc<='1';
           -- pcSrc<='0';
            aluop<="001";
            led(0)<='1';
            
         when "010"=>
            --lw
            regWr<='1';
            extOp<='1';
            aluSrc<='1';
            memToReg<='1';
           -- pcSrc<='0';
            aluop<="001"; -- se face plus

      
        when "011"=>
            --sw
            extOp<='1';
            aluSrc<='1';
            memWrite<='1';
            aluop<="001";

        when "100"=>
            --beq
            extOp<='1';
            branch<='1';
            jmp<='0';  
            aluop<="010";
              
        when "101"=>
            --bne
            extOp<='1';
            branch<='1';
            jmp<='0';  
            aluop<="010";
              
        when "110"=>
            --slti
            extOp<='1';
            alusrc<='1';
            aluop<="110";
            
        when "111"=>  
            --jmp
            jmp<='1';
            aluop<="111";
       
        when others =>
        regDst<='0'; 
        extop<='0';
        aluSrc<='0';
        branch<='0'; 
        jmp<='0';
        memWrite<='0';
        memToReg<='0';
        regWr<='0';
        aluop<="000";
        
    end case;
end process;



-- trebuie initializate ceva valori pt reg_file ???

--M12: MPG port map(btn(1),clk,we); -- cel care dubleaza valoarea veche
--M1: MPG port map(btn(0),clk,en); -- nu are voie sa fie in proces  -- cel care incrementeaza valoarea

--M2: SSD port map(afis,clk,an,cat); -- pt ALU
--

-- reg file
--aux1 <= cnt(3 downto 0);  
--aux_sum<= rd1+rd2;
--RG: reg_file port map(clk,aux1,aux1,aux1,aux_sum,we,rd1,rd2);
--M2: SSD port map(aux_sum,clk,an,cat);


-- memorie ram
--RAM: rams_no_change port map(clk,we,'1',cnt(7 downto 0),din,dout);
--din <= din&"00"; --- am eroare aici1
--M2: SSD port map(dout,clk,an,cat);
--led <= sw;
--an <= btn (3 downto 0);
--cat <= (others=>'0');
--process(clk)
--begin
--if rising_edge(clk) then
--if en='1' then
--if sw(0) ='0' then
--cnt<= cnt+1;
--else
--cnt<= cnt-1;
--end if;
--end if;
--end if;
--end process;



--data<=ROM_M(conv_integer(cnt(7 downto 0)));

-- ALU

--process
--begin
--case cnt is
--    when "00" => result <= sw(15 downto 8) + sw(7 downto 0);
--    when "01" => result <= sw(15 downto 8) - sw(7 downto 0);
--    when "10" => result <= "00"&sw(7 downto 2); -- spre dreapta cu 2 zerouri
--    when "11" => result <= sw(6 downto 0)&"0"; -- spre stanga cu 1 zero
--end case;

--end process;

--afis<= x"00"&result;



			
end Behavioral;

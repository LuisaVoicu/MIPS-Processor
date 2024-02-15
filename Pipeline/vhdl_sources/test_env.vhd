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
              result_mux : inout STD_LOGIC_VECTOR (2 downto 0);
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


--pipeline
signal result_mux:std_logic_vector(2 downto 0);

signal en_pipe:std_logic;
signal pcPlus_id: std_logic_vector(15 downto 0);
signal instr_id: std_logic_vector(15 downto 0);

--ex signals
signal jmp_if,memtoReg_ex,regwrite_ex,branch_ex, alusrc_ex, memwrite_ex, regdst_ex : std_logic;
signal rd1_ex, rd2_ex, instr_ex, pcplus_ex: std_logic_vector(15 downto 0);
signal aluop_ex : std_logic_vector(2 downto 0);
signal Ext_Imm_ex : STD_LOGIC_vector (15 downto 0);
signal func_ex :  STD_LOGIC_VECTOR (2 downto 0);
signal sa_ex :  STD_LOGIC;
signal result_mux_ex:std_logic_vector(2 downto 0);


--mem/wb 

signal memtoReg_mem,regwrite_mem,branch_mem, alusrc_mem, memwrite_mem, regdst_mem,zero_mem : std_logic;
signal aluop_mem,result_mux_mem : std_logic_vector(2 downto 0);
signal brAddr_mem, alures_mem,rd2_mem : std_logic_vector(15 downto 0);


--wb/inceput
signal memtoReg_wb,regwrite_wb: std_logic;
signal memdata_wb, alures_wb: std_logic_vector(15 downto 0);
signal result_mux_wb: std_logic_vector(2 downto 0);

begin       


M1: MPG port map(btn(0),clk,en);
MP2: MPG port map(btn(1),clk,reset);
MPG3: MPG port map(btn(2),clk,en_pipe);
                                        
               
 -- nu stiu daca e bine?                 
jumpAddr <= pcPlus_ID(15 downto 13) & instr_id(12 downto 0);            
pcSrc <= Branch_mem and zero_mem; -- e calculat in mem
brAddr<=pcPlus_ex + ext_imm_ex; -- se calculeaza in ex


INSF: InstrFetch port map(en,clk,pcSrc,jmp,brAddr_mem,jumpAddr,pcPlus,instr,reset); 

      regwrite2<=regwr and en; --??? nu inteleg la ce foloseste

IDD: ID port map(clk,en,regWrite_wb,instr_id,regDst,extop,rd1,rd2,ext_imm,func,sa,result_mux_wb,wd);
EXX: EX port map(rd1_ex,rd2_ex,ext_imm_ex,aluSrc_ex,sa_ex,func_ex,aluOp_ex,zero,AluRes);
DATA_MEM: MEM port map(clk,memWrite_mem,aluRes_mem,RD2_mem,MemData);


-- mux in care intra memToReg si duce semnalul la wd

process(memToReg_wb) begin
case(memToReg_wb) is
when '1' => wd <= MemData_wb;
when '0' => wd <= aluRes_wb;
end case;
end process;


sw_aux<=sw(1);
process(sw) begin
case sw(15 downto 13) is
when "000" => out_ssd <= instr; 
when "001" => out_ssd <= pcplus_id;
when "010" => out_ssd <= rd1;
when "011" => out_ssd <= rd2;
when "100" => out_ssd <= ext_imm;
when "101" => out_ssd <= alures;
when "110" => out_ssd <= instr_id; --memwrite
when "111" => out_ssd <= instr_ex; --wd
when others => out_ssd <= x"0000";
end case;
end process;


process(clk,instr) begin

if(rising_edge(clk)) then
    --termina bucla
    if(instr = b"1000111000000110") then
    led(3)<='1';
    else
    led(3)<='0';
    end if;
    
    --inceput bucla
    if(instr = b"100_010_001_0100000") then
    led(4)<='1';
    else
    led(4)<='0';
    end if;

end if;
end process;


--led(15 downto 13) <= out_ssd;

M2: SSD port map(out_ssd,clk,an,cat); -- PT ROM
--led <=instr;

aux_instr <= instr_id(15 downto 13);


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




--pipeline

--???????
with regdst select
result_mux <= instr_ex(6 downto 4)when '1' ,
              instr_ex(9 downto 7) when '0',
              (others => '0') when others;
    


IF_ID: process(clk)begin

if rising_edge(clk) then

    if(en= '1') then
    pcPlus_ID<=pcPlus;
    instr_ID<=Instr;
    end if;

end if;
end process;


id_ex: process(clk)begin
    if(rising_edge(clk))then

        if(en='1') then
            jmp_if <= jmp; -- ma duce inapoi la if
            memtoReg_ex<=memtoreg;
            regwrite_ex<=regwrite2; -- asta e ciudat ca trb sa apas nu stiu cum
            memwrite_ex<=memwrite;  -- 
            branch_ex<=branch;
            aluop_ex<=aluop;
            alusrc_ex<=alusrc;
            regdst_ex<=regdst;
            
            pcplus_ex<=pcplus_id;
            rd1_ex<=rd1;
            rd2_ex<=rd2;
            instr_ex<=instr; -- nu e tocmai necesara
            ext_imm_ex<=ext_imm;
            func_ex<=func;
            sa_ex<=sa;
            result_mux_ex<=result_mux;
        end if;
    end if;
    end process;
    
 ex_mem: process(clk) begin

     if(rising_edge(clk))then

         if(en='1') then
             memtoReg_mem<=memtoreg_ex;
             regwrite_mem<=regwrite_ex;
             memwrite_mem<=memwrite_ex;
             branch_mem<=branch_ex;
             
             brAddr_mem<= brAddr;
             zero_mem<=zero;
             alures_mem<=alures;
             rd2_mem<=rd2_ex;
             result_mux_mem <= result_mux_ex;
         end if;
      end if;        
end process;


mem_wb: process(clk) begin

     if(rising_edge(clk))then

         if(en='1') then
         memtoreg_wb<=memtoreg_mem;
         regwrite_wb<=regwrite_mem;
         memdata_wb<=memdata;
         alures_wb<=alures_mem;
         result_mux_wb<=result_mux_mem;
         end if;
      end if;        
end process;





end Behavioral;

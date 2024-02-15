----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.04.2023 14:31:25
-- Design Name: 
-- Module Name: ID - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID is
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
end ID;

architecture Behavioral of ID is

--component reg_file is
--port (
--clk : in std_logic;
--ra1 : in std_logic_vector (2 downto 0);
--ra2 : in std_logic_vector (2 downto 0);
--wa : in std_logic_vector (2 downto 0);
--wd : in std_logic_vector (15 downto 0);
--wen : in std_logic;
--rd1 : out std_logic_vector (15 downto 0);
--rd2 : out std_logic_vector (15 downto 0)
--);
--end component reg_file;


type reg_array is array(0 to 7) of STD_LOGIC_VECTOR(15 downto 0);
signal reg_file : reg_array := (others => X"0000");

signal result_mux : std_logic_vector(2 downto 0);
begin

                        -- regwrite and en
--REG: reg_file port map (clk,instr(12 downto 10),instr(9 downto 7),result_mux,wd,regwrite,rd1,rd2);



with regdst select
result_mux <= instr(6 downto 4)when '1' ,
              instr(9 downto 7) when '0',
              (others => '0') when others;
    
    
     process(clk)			
           begin
           if rising_edge(clk) then
              if en = '1' and RegWrite = '1' then
                  reg_file(conv_integer(result_mux)) <= WD;        
               end if;
            end if;
          end process;        



    --rs
    RD1 <= reg_file(conv_integer(Instr(12 downto 10))); 
    RD2 <= reg_file(conv_integer(Instr(9 downto 7))); -- rt
   
    Ext_Imm(6 downto 0) <= Instr(6 downto 0); 
                   with ExtOp select
                       Ext_Imm(15 downto 7) <= (others => Instr(6)) when '1',
                                               (others => '0') when '0',
                                               (others => '0') when others;  
              

--process(extop,instr)
--begin
--if(extop='0')then
--ext_imm<= "000000000"&instr(6 downto 0);
--elsif(extop='1')then
--    if(instr(6)='0')then
--    ext_imm<= "000000000"&instr(6 downto 0);
--    elsif(instr(6)='1')then
--    ext_imm<= "111111111"&instr(6 downto 0);
--    end if;
--end if;
--end process;


func <= instr(2 downto 0); 
sa <= instr(3);


end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.04.2023 02:52:59
-- Design Name: 
-- Module Name: MEM - Behavioral
-- Project  Name: 
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

entity MEM is
    Port ( clk : in std_logic;
           MemWrite : in STD_LOGIC;
           AluRes : inout STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemData : out STD_LOGIC_VECTOR(15 downto 0));
end MEM;



architecture Behavioral of MEM is
type RAM is array ( 0 to 32 ) of std_logic_vector(15 downto 0);
signal memorie: RAM:=(x"0003",x"0004",x"0005",x"0006",x"0002",x"0002",x"0002",x"0002",x"0002",x"0002",x"0002",x"0002",x"0002",others=>x"123C");
begin

memData<=memorie(conv_integer(aluRes(4 downto 0)));


process(clk) begin
if(rising_edge(clk)) then
    if(memWrite='1')then
    memorie(conv_integer(aluRES)) <= RD2;
    end if;
end if;
end process;

end Behavioral;

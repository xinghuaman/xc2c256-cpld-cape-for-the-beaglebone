# CoolRunner-II CPLD Cape for the BeagleBone #
## Overview ##


&lt;hr&gt;


This cape adds the power of a CPLD to the BeagleBone.<br>
Mounted on the cape is a Xilinx CoolRunner-II CPLD with 256 macro cells.(XC2C256-7VQG100C).<br>
With this cape you can generate and process digital signals in real time. All signals can be <br>
accessed from the P8 and P9 headers on the BeagleBone. If the signal is not already routed to<br>
the CPLD. Use a jump wire to route the signal(s) to and from any header on the cape.<br>
<br>
<a href='http://www.flighttronics.se/'><img src='http://xc2c256-cpld-cape-for-the-beaglebone.googlecode.com/svn/wiki/images/CoolRunnerIICPLDCapeRevBTop400.jpg' /></a>


<h2>Key features</h2>
<br>
<br>
<hr><br>
<br>
<br>
<ul><li>Xilinx CoolRunner-II CPLD with 256 macro cells XC2C256-7VQG100<br>
</li><li>JTAG interface for configuration on P3<br>
<h3>I/O</h3>
</li><li>P2 has 18 I/O + GND and VDD3V3<br>
</li><li>P3 has 13 I/O  + GND and VDD3V3<br>
</li><li>P8 has 19 I/O including TIMER and UART5<br>
</li><li>P9 has 6 I/O including I2C and SPI<br>
<h3>Power</h3>
</li><li>LT3028 Dual 100mA/500mA Low Dropout, Low Noise Regulator<br>
</li><li>500mA 3.3V and 100mA 1.8V<br>
</li><li>Draws power from external 5V power on P9. (BeagleBone must be powered from external 5V!!)</li></ul>


<h2>Schematic</h2>
<br>
<br>
<hr><br>
<br>
<br>
<h3>I/O Schematic</h3>

<a href='http://flighttronics.se/wp-content/uploads/2012/09/CoolRunnerII_CPLD_Schematic_RevB2.pdf'><img src='http://xc2c256-cpld-cape-for-the-beaglebone.googlecode.com/svn/wiki/images/CoolRunnerIICPLDCapeRevBSchematicIO.jpg' /></a>

<h3>Power</h3>
<a href='http://flighttronics.se/wp-content/uploads/2012/09/CoolRunnerII_CPLD_Schematic_RevB2.pdf'><img src='http://xc2c256-cpld-cape-for-the-beaglebone.googlecode.com/svn/wiki/images/CoolRunnerIICPLDCapeRevBSchematicPower.jpg' /></a>

<h3>XTAL and JTAG</h3>
<a href='http://flighttronics.se/wp-content/uploads/2012/09/CoolRunnerII_CPLD_Schematic_RevB2.pdf'><img src='http://xc2c256-cpld-cape-for-the-beaglebone.googlecode.com/svn/wiki/images/CoolRunnerIICPLDCapeRevBSchematicMisc.jpg' /></a>
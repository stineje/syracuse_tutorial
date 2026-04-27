* test_inv_1.sp
* NGSPICE testbench for gf180mcu_osu_sc_gp12t3v3__inv_1

************************************
* Include GF180MCU device models
************************************
* Update this path to match your local Open_PDKs installation.
.include /home/jstine/opencircuitdesign/share/pdk/gf180mcuC/libs.tech/ngspice/design.ngspice

************************************
* Include extracted inverter netlist
************************************
.include gf180mcu_osu_sc_gp12t3v3__inv_1.spice

************************************
* Power supplies
************************************
.param VDDVAL=3.3

VDD vdd 0 DC {VDDVAL}
VSS vss 0 DC 0

************************************
* Input stimulus
************************************
* Pulse: 0 -> 3.3 V, 1 ns rise/fall, 20 ns period
VIN a 0 PULSE(0 {VDDVAL} 2n 100p 100p 10n 20n)

************************************
* Device under test
************************************
XINV a y vdd vss gf180mcu_osu_sc_gp12t3v3__inv_1

************************************
* Output load
************************************
CLOAD y 0 10f

************************************
* Simulation control
************************************
.tran 1p 60n

.control
run

* Plot input and output
plot v(a) v(y)

* Measure propagation delays at 50 percent VDD
meas tran tphl TRIG v(a) VAL='VDDVAL/2' RISE=1 TARG v(y) VAL='VDDVAL/2' FALL=1
meas tran tplh TRIG v(a) VAL='VDDVAL/2' FALL=1 TARG v(y) VAL='VDDVAL/2' RISE=1

* Measure average delay
let tpd = (tphl + tplh)/2
print tphl tplh tpd

.endc

.end

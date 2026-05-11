OPENQASM 2.0;
include "qelib1.inc";
qreg q[5];
creg c[3];
cx q[0],q[1];
cx q[1],q[2];
cz q[0],q[3];
cz q[1],q[3];
cz q[0],q[4];
cz q[2],q[4];

measure q[3] -> c[0];
measure q[4] -> c[1];

if(c==1) z q[2];
if(c==2) z q[1];
if(c==3) z q[0];
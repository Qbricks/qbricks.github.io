OPENQASM 2.0;
include "qelib1.inc";
qreg q[7];
creg c[3];
x q[0];
h q[4];
h q[4];
measure q[4] -> c[0];
barrier;
h q[5];
cx q[5],q[2];
cx q[5],q[0];
if(c==1) u1(pi/2) q[5];
h q[5];
measure q[5] -> c[1];
barrier;


cswap q[6],q[1],q[0];
cswap q[6],q[2],q[1];
cswap q[6],q[3],q[2];
cx q[6],q[3];
cx q[6],q[2];
cx q[6],q[1];
cx q[6],q[0];
if(c==3) u1(3*pi/4) q[6];
if(c==2) u1(pi/2) q[6];
if(c==1) u1(pi/4) q[6];
h q[6];
measure q[6] -> c[2];


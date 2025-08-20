OPENQASM 2.0;
include "qelib1.inc";
qreg q[2];
ry (2 * pi / 2^(3)) q[1];
cx q[0], q[1];
ry (- 2 * pi / 2^(3)) q[1];

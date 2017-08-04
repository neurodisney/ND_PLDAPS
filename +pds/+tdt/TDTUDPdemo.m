close all; clear all; clc;

RZ_IP = '129.59.230.10'; % find remote IP address of RZ device using zBusMon

% read demo
u = pds.tdt.TDTUDP(RZ_IP, 'TYPE', 'single', 'VERBOSE', 1);

while 1
    u.write(0);
    u = u.read();
    u.data
end
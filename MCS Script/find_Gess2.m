function G = find_Gess2(x)

global mu
mu = 398600;
a = x(1);
e = x(2);
i = x(3);
w = x(5);

G14 = 2*a*e;
G15 = 4*a*sqrt(1-e^2);
G24 = 1-e^2;
G25 = -3*e*sqrt(1-e^2);
G311 = sqrt(1/(1-e^2))*(1+e^2)*cos(w);
G313 = -sin(w);
G411 = sqrt(1/(1-e^2))*(1+e^2)*sin(w)/sin(i);
G413 = cos(w)/sin(i);
G51 = 2*sqrt(1-e^2);
G58 = (2-e^2)/e;
G511 = -cos(i)/sin(i)*(1+e^2)/sqrt(1-e^2)*sin(w);
G513 = -cos(i)/sin(i)*cos(w);
G61 = -6;
G68 = -(2-e^2)/e*sqrt(1-e^2);

G = 1/2*sqrt(a/mu)*[0 G14 G15 0 0 0;...
    0 G24 G25 0 0 0;...
    0 0 0 0 G311 G313;...
    0 0 0 0 G411 G413;...
    G51 0 0 G58 G511 G513;...
    G61 0 0 G68 0 0];
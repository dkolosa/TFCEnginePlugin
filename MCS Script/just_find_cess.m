% code to just find c_ess between states

global mu
mu = 398600;

% GEO phase-out
x0 = [42165 .00028 0.14*pi/180 102.8*pi/180 116.4*pi/180 255.3*pi/180]; % initial state [a e i \Omega \w \theta]
xT = [42165 .00017 0.02*pi/180 225*pi/180 165.3*pi/180 345*pi/180]; % final state
t0 = 0;
tT = 3888000; %s = 3 sidereal days

% % GEO graveyard maneuver
% x0 = [42164 .001 1*pi/180 10*pi/180 10*pi/180 30*pi/180];
% xT = [42464 .001 .001*pi/180 10*pi/180 10*pi/180 30*pi/180];
% t0 = 0;
% tT = 258491*5; %s = 15 sidereal days


c_ess = find_c_ess2(x0,xT,t0,tT) % returns essential TFC set 2: [a0R b1R a0S b1S a1W b1W]
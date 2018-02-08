function c_ess2 = find_c_ess2(x0,xT,tstart,tT)

G_ess2 = find_Gess2(x0);

c_ess2 = (G_ess2)\((xT-x0)'/(tT-tstart));

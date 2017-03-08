import numpy as np

def EstimateAlphas(initialValues, essentialTFC, targetValues, finalTime):

	D2R = np.pi/180.0    # Degree to radians
	mu = 398600.0
	t0 = 0.0
	# alpha = [a0R a1R a2R b1R a0S a1S a2S b1S b2S a0W a1W a2W b1W b2W] #RSW
	# alphaess = [a0R a0S a1S b1S b2S a1W b1W]

	a = initialValues[0]
	e = initialValues[1]
	i = initialValues[2] * D2R
	Omega = initialValues[3] * D2R
	w = initialValues[4] * D2R
	theta = initialValues[5] * D2R

	at = targetValues[0]
	et = targetValues[1]
	it = targetValues[2] * D2R
	Omegat = targetValues[3] * D2R
	wt = targetValues[4] * D2R
	thetat = targetValues[5] * D2R

	init = np.array([a, e, i, Omega, w, theta])
	targ = np.array([at, et, it, Omegat, wt, thetat])

	alphas = np.zeros((1,14),dtype=float)

	if ess == True:

		G = np.zeros((6,6),dtype=float)

		#a
		G[0,1] = 2*a*e
		G[0,2] = 4*a*np.sqrt(1-e**2)

		G[1,1] = 1-e**2
		G[1,2] = -3*e*np.sqrt(1-e**2)

		G[2,4] = np.sqrt(1/(1-e**2))*(1+e**2)*np.cos(w)
		G[2,5] = -np.sin(w)

		G[3,4] = np.sqrt(1/(1-e**2))*(1+e**2)*(np.sin(w)/np.sin(i))
		G[3,5] = np.cos(w)/np.sin(i)

		G[4,0] = (-1/e)*np.sqrt(1-e**2)
		G[4,3] = (2-e**2)/e
		G[4,4] = -(np.cos(i)/np.sin(i))*((1+e**2)/np.sqrt(1-e**2))*np.sin(w)
		G[4,5] = -(np.cos(i)/np.sin(i))*np.cos(w)

		G[5,0] = (3*e**2+1)/e
		G[5,3] = -((2-e**2)/e)*np.sqrt(1-e**2)

		G = G*.5*(np.sqrt(a/mu))

		alphaess = (G**-1)*((targ - init)/(tf - t0))

		# alphaess = [a0R a0S a1S b1S b2S a1W b1W]
		alphas[0] = alphaess[0]
		alphas[4] = alphaess[1]  
		alphas[5] = alphaess[2]
		alphas[7] = alphaess[3]
		alphas[9] = alphaess[4]
		alphas[12] = alphaess[5]

	else:
		
		G=np.zeros((6,14),dtype=float)

		#a
		G[0,3]=np.sqrt(a**3/mu)*e #b1R
		G[0,4]=2*np.sqrt(a**3/mu)*np.sqrt(1-e**2) #a0S

		#e
		G[1,4]=.5*np.sqrt(1-e**2) #b1R
		G[1,5]=-1.5*e #a0S
		G[1,6]=1 #a1S
		G[1,7]=-.25*e #a2S
		G[1,:]=G[1,:]*np.sqrt(a/mu)*np.sqrt(1-e**2)

		#i
		G[2,9]=-1.5*e*np.cos(w) #a0W
		G[2,10]=.5*(1+e**2)*np.cos(w) #a1W
		G[2,11]=-.25*e*np.cos(w) #a2W
		G[2,12]=-.5*np.sqrt(1-e**2)*np.sin(w) #b1W
		G[2,13]=.25*e*np.sqrt(1-e**2)*np.sin(w) #b2W
		G[2,:]=G[2,:]*np.sqrt(a/mu)/np.sqrt(1-e**2)

		#Omega
		G[3,9]=-1.5*e*np.sin(w) #a0W
		G[3,10]=.5*(1+e**2)*np.sin(w) #a1W
		G[3,11]=-.25*e*np.sin(w) #a2W
		G[3,12]=.5*np.sqrt(1-e**2)*np.cos(w) #b1W
		G[3,13]=-.25*e*np.sqrt(1-e**2)*np.cos(w) #b2W
		G[3,:]=G[3,:]*np.sqrt(a/mu)*csc(i)/np.sqrt(1-e**2)

		#w
		G[4,0]=e*np.sqrt(1-e**2) #a0R
		G[4,1]=-.5*np.sqrt(1-e**2) #a1R
		G[4,7]=.5*(2-e**2) #b1S
		G[4,8]=-.25*e #b2S
		G[4,:]=G[4,:]*np.sqrt(a/mu)/e
		G[4,:]=G[4,:]-np.cos(i)*G[4,:]

		#M
		G[5,0]=-2-e**2 #a0R
		G[5,1]=2*e #a1R
		G[5,3]=-.5*e**2 #a2R
		G[5,:]=G[5,:]*np.sqrt(a/mu)
		G[5,:]=G[5,:]+(1-np.sqrt(1-e**2))*(G[4,:]+G[3,:])+2*np.sqrt(1-e**2)*(np.sin(i/2))**2*G[3,:]-(G[4,:]+G[3,:])

		alphaess = (G**-1)*((targ - init)/(tf - t0))

		# alpha = [a0R a1R a2R b1R a0S a1S a2S b1S b2S a0W a1W a2W b1W b2W] #RSW
		alphas = alphaess
        
    return alphas
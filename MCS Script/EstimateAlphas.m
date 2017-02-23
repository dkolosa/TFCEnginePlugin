%calculates G such that xdot = G*alpha + F, where the 6th element of x is M

function alphas=EstimateAlphas(a, e, i, Omega, w, theta, ess, at, et, it, Omegat, wt, thetat, tf)

	mu = 398600;
	t0 = 0;
	% alpha = [a0R a1R a2R b1R a0S a1S a2S b1S b2S a0W a1W a2W b1W b2W]'; %RSW
	% alphaess = [a0R a0S a1S b1S b2S a1W b1W]


	if(ess == true)

		G = zeros(6,6);

		%a
		G(1,2) = 2*a*e;
		G(1,3) = 4*a*sqrt(1-e^2);

		G(2,2) = 1-e^2;
		G(2,3) = -3*e*sqrt(1-e^2);

		G(3,5) = sqrt(1/(1-e^2))*(1+e^2)*cos(w);
		G(3,6) = -sin(w);

		G(4,5) = sqrt(1/(1-e^2))*(1+e^2)*(sin(w)/sin(i));
		G(4,6) = cos(w)/sin(i);

		G(5,1) = (-1/e)*sqrt(1-e^2);
		G(5,4) = (2-e^2)/e;
		G(5,5) = -(cos(i)/sin(i))*((1+e^2)/sqrt(1-e^2))*sin(w);
		G(5,6) = -(cos(i)/sin(i))*cos(w);

		G(6,1) = (3*e^2+1)/e;
		G(6,4) = -((2-e^2)/e)*sqrt(1-e^2);

		G = G*.5*(sqrt(a/mu));

		init = [a, e, i, Omega, w, theta];
		targ = [at, et, it, Omegat, wt, thetat];

		alphaess = inv(G)*((targ - init)/(tf - t0))';

		alphas = zeros(1,14);
	
		% alpha = [a0R a1R a2R b1R a0S a1S a2S b1S b2S a0W a1W a2W b1W b2W]'; %RSW
		% alphaess = [a0R a0S a1S b1S b2S a1W b1W]
		alphas(1) = alphaess(1);
		alphas(5) = alphaess(2);  
		alphas(6) = alphaess(3);
		alphas(8) = alphaess(4);
		alphas(10) = alphaess(5);
		alphas(13) = alphaess(6);

	else
		
		G=zeros(6,14);

		%a
		G(1,4)=sqrt(a^3/mu)*e; %b1R
		G(1,5)=2*sqrt(a^3/mu)*sqrt(1-e^2); %a0S

		%e
		G(2,4)=.5*sqrt(1-e^2); %b1R
		G(2,5)=-1.5*e; %a0S
		G(2,6)=1; %a1S
		G(2,7)=-.25*e; %a2S
		G(2,:)=G(2,:)*sqrt(a/mu)*sqrt(1-e^2);

		%i
		G(3,10)=-1.5*e*cos(w); %a0W
		G(3,11)=.5*(1+e^2)*cos(w); %a1W
		G(3,12)=-.25*e*cos(w); %a2W
		G(3,13)=-.5*sqrt(1-e^2)*sin(w); %b1W
		G(3,14)=.25*e*sqrt(1-e^2)*sin(w); %b2W
		G(3,:)=G(3,:)*sqrt(a/mu)/sqrt(1-e^2);

		%Omega
		G(4,10)=-1.5*e*sin(w); %a0W
		G(4,11)=.5*(1+e^2)*sin(w); %a1W
		G(4,12)=-.25*e*sin(w); %a2W
		G(4,13)=.5*sqrt(1-e^2)*cos(w); %b1W
		G(4,14)=-.25*e*sqrt(1-e^2)*cos(w); %b2W
		G(4,:)=G(4,:)*sqrt(a/mu)*csc(i)/sqrt(1-e^2);

		%w
		G(5,1)=e*sqrt(1-e^2); %a0R
		G(5,2)=-.5*sqrt(1-e^2); %a1R
		G(5,8)=.5*(2-e^2); %b1S
		G(5,9)=-.25*e; %b2S
		G(5,:)=G(5,:)*sqrt(a/mu)/e;
		G(5,:)=G(5,:)-cos(i)*G(4,:);

		%M
		G(6,1)=-2-e^2; %a0R
		G(6,2)=2*e; %a1R
		G(6,3)=-.5*e^2; %a2R
		G(6,:)=G(6,:)*sqrt(a/mu);
		G(6,:)=G(6,:)+(1-sqrt(1-e^2))*(G(5,:)+G(4,:))+2*sqrt(1-e^2)*(sin(i/2))^2*G(4,:)-(G(5,:)+G(4,:));
	end
end


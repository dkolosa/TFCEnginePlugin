function  SetupThrusterSet(compThrusterSet, compThrusterProperties)
	%set up the Thruster Set to create the TFC thruster set

	global ISP

	compThrusterSet.DuplicateComponent('Thruster Set', 'TFC set');

	TFC_ISP = {'TFCR ISP', 'TFCR Neg ISP', 'TFCS ISP', 'TFCS Neg ISP', 'TFCW ISP', 'TFCW Neg ISP'};


	% Create a new set of TFC ening models to allow changing the ISP
	compThrusterProperties.DuplicateComponent('Fourier Thrust Coefficient R', TFC_ISP{1});
	compThrusterProperties.DuplicateComponent('Fourier Thrust Coefficient R Negative', TFC_ISP{2});
	compThrusterProperties.DuplicateComponent('Fourier Thrust Coefficient S', TFC_ISP{3});
	compThrusterProperties.DuplicateComponent('Fourier Thrust Coefficient S Negative', TFC_ISP{4});
	compThrusterProperties.DuplicateComponent('Fourier Thrust Coefficient W', TFC_ISP{5});
	compThrusterProperties.DuplicateComponent('Fourier Thrust Coefficient W Negative', TFC_ISP{6});

	% Create a handle for each engine model
	TFC_R_ISP = compThrusterProperties.Item(TFC_ISP{1});
	TFC_R_Neg_ISP = compThrusterProperties.Item(TFC_ISP{2});
	TFC_S_ISP = compThrusterProperties.Item(TFC_ISP{3});
	TFC_S_Neg_ISP = compThrusterProperties.Item(TFC_ISP{4});
	TFC_W_ISP = compThrusterProperties.Item(TFC_ISP{5});
	TFC_W_Neg_ISP = compThrusterProperties.Item(TFC_ISP{6});

	% Set the ISP of the engine models
	TFC_R_ISP.PluginConfig.SetProperty('Isp', ISP);
	TFC_R_Neg_ISP.PluginConfig.SetProperty('Isp', ISP);
	TFC_S_ISP.PluginConfig.SetProperty('Isp', ISP);
	TFC_S_Neg_ISP.PluginConfig.SetProperty('Isp', ISP);
	TFC_W_ISP.PluginConfig.SetProperty('Isp', ISP);
	TFC_W_Neg_ISP.PluginConfig.SetProperty('Isp', ISP);


	%Create a handle for the Thruster Set
	    TFCset = compThrusterSet.Item('TFC set');
	    TFCRSW = TFCset.Thruster;
	    %Clear Default Thrusters
	    TFCRSW.RemoveAll;

	    %Add the TFC thrusters
	    TFCThrusters = {'TFCR', 'TFCRNeg', 'TFCS', 'TFCSNeg', 'TFCW', 'TFCWNeg'};

	    for (i = 1: length(TFCThrusters))
	        TFCRSW.Add(TFCThrusters{i});
	    end

	    TFCR = TFCRSW.Item(TFCThrusters{1});
	    TFCR.EngineModelName = TFC_ISP{1};
	    %TFCR.ThrusterDirection.AssignXYZ(1,0,0);
		TFCR.ThrusterDirection.AssignXYZ(0,1,0);


	    TFCRNeg = TFCRSW.Item(TFCThrusters{2});
	    TFCRNeg.EngineModelName = TFC_ISP{2};
	    %TFCRNeg.ThrusterDirection.AssignXYZ(-1,0,0);
		TFCRNeg.ThrusterDirection.AssignXYZ(0,-1,0);


	    TFCS = TFCRSW.Item(TFCThrusters{3});
	    TFCS.EngineModelName = TFC_ISP{3};
		TFCS.ThrusterDirection.AssignXYZ(1,0,0);
	    %TFCS.ThrusterDirection.AssignXYZ(0,1,0);

	    TFCSNeg = TFCRSW.Item(TFCThrusters{4});
	    TFCSNeg.EngineModelName = TFC_ISP{4};
	    TFCSNeg.ThrusterDirection.AssignXYZ(0,-1,0);
	    TFCSNeg.ThrusterDirection.AssignXYZ(-1,0,0);

	    TFCW = TFCRSW.Item(TFCThrusters{5});
	    TFCW.EngineModelName = TFC_ISP{5};
	    TFCW.ThrusterDirection.AssignXYZ(0,0,1);

	    TFCWNeg = TFCRSW.Item(TFCThrusters{6});
	    TFCWNeg.EngineModelName = TFC_ISP{6};
	    TFCWNeg.ThrusterDirection.AssignXYZ(0,0,-1);

end
function  SetupThrusterSet(compThrusterSet)
	%set up the Thruster Set to create the TFC thruster set

	compThrusterSet.DuplicateComponent('Thruster Set', 'TFC set');

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
	    TFCR.EngineModelName = 'Fourier Thrust Coefficient R';
	    TFCR.ThrusterDirection.AssignXYZ(1,0,0);

	    TFCRNeg = TFCRSW.Item(TFCThrusters{2});
	    TFCRNeg.EngineModelName = 'Fourier Thrust Coefficient R Negative';
	    TFCRNeg.ThrusterDirection.AssignXYZ(-1,0,0);

	    TFCS = TFCRSW.Item(TFCThrusters{3});
	    TFCS.EngineModelName = 'Fourier Thrust Coefficient S';
	    TFCS.ThrusterDirection.AssignXYZ(0,1,0);

	    TFCSNeg = TFCRSW.Item(TFCThrusters{4});
	    TFCSNeg.EngineModelName = 'Fourier Thrust Coefficient S Negative';
	    TFCSNeg.ThrusterDirection.AssignXYZ(0,-1,0);

	    TFCW = TFCRSW.Item(TFCThrusters{5});
	    TFCW.EngineModelName = 'Fourier Thrust Coefficient W';
	    TFCW.ThrusterDirection.AssignXYZ(0,0,1);

	    TFCWNeg = TFCRSW.Item(TFCThrusters{6});
	    TFCWNeg.EngineModelName = 'Fourier Thrust Coefficient W Negative';
	    TFCWNeg.ThrusterDirection.AssignXYZ(0,0,-1);

end
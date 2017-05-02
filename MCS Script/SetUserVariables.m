function SetUserVariables(ASTG, compBrowser, TFCcoefficients)
	%% Fuction sets the user variables (TFC coefficients) in the Component Browser
	%%Pass in the component browser directory
	% %% Set the user variables

	uservariables = compBrowser.GetFolder('UserValues');

    for (i = 1: length(TFCcoefficients))
        ASTG.Options.UserVariables.Add(TFCcoefficients{i});
    end

	    % access the uservalues and rename to corrent coefficients


        %Radial
        AlphaR0 = uservariables.DuplicateComponent('User_value', TFCcoefficients{1});
        AlphaR0.VariableName = TFCcoefficients{1};
        AlphaR1 = uservariables.DuplicateComponent('User_value', TFCcoefficients{2});
        AlphaR1.VariableName = TFCcoefficients{2};
        AlphaR2 = uservariables.DuplicateComponent('User_value', TFCcoefficients{3});
        AlphaR2.VariableName = TFCcoefficients{3};
        BetaR1 = uservariables.DuplicateComponent('User_value', TFCcoefficients{4});
        BetaR1.VariableName = TFCcoefficients{4};

        %Transverse
        AlphaS0 = uservariables.DuplicateComponent('User_value', TFCcoefficients{5});
        AlphaS0.VariableName = TFCcoefficients{5};
        AlphaS1 = uservariables.DuplicateComponent('User_value', TFCcoefficients{6});
        AlphaS1.VariableName = TFCcoefficients{6};
        AlphaS2 = uservariables.DuplicateComponent('User_value', TFCcoefficients{7});
        AlphaS2.VariableName = TFCcoefficients{7};
        BetaS1 = uservariables.DuplicateComponent('User_value', TFCcoefficients{8});
        BetaS1.VariableName = TFCcoefficients{8};
        BetaS2 = uservariables.DuplicateComponent('User_value', TFCcoefficients{9});
        BetaS2.VariableName = TFCcoefficients{9};

        %Normal
        AlphaW0 = uservariables.DuplicateComponent('User_value', TFCcoefficients{10});
        AlphaW0.VariableName = TFCcoefficients{10};
        AlphaW1 = uservariables.DuplicateComponent('User_value', TFCcoefficients{11});
        AlphaW1.VariableName = TFCcoefficients{11};
        AlphaW2 = uservariables.DuplicateComponent('User_value', TFCcoefficients{12});
        AlphaW2.VariableName = TFCcoefficients{12};
        BetaW1 = uservariables.DuplicateComponent('User_value', TFCcoefficients{13});
        BetaW1.VariableName = TFCcoefficients{13};
        BetaW2 = uservariables.DuplicateComponent('User_value', TFCcoefficients{14});
        BetaW2.VariableName = TFCcoefficients{14};
end
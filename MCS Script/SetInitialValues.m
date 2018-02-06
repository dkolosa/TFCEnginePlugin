function SetInitialValues(UVsegment, TFCcoefficients, alphaCoeff)

    set_action = 'eVAUpdateActionSetToNewValue';

 %initialize User Variables
            %Radial 
            userVariableAlphaR0 = UVsegment.UserVariables.Item(TFCcoefficients{1}); %create handle
            userVariableAlphaR0.VariableAction = set_action;    %allow to change value per iteration
            userVariableAlphaR0.VariableValue = alphaCoeff(1);              %Set the initial value
            userVariableAlphaR0.EnableControlParameter;


            userVariableAlphaR1 = UVsegment.UserVariables.Item(TFCcoefficients{2});
            userVariableAlphaR1.VariableAction = set_action;
            userVariableAlphaR1.VariableValue = alphaCoeff(2);
            userVariableAlphaR1.EnableControlParameter;

            userVariableAlphaR2 = UVsegment.UserVariables.Item(TFCcoefficients{3});
            userVariableAlphaR2.VariableAction = set_action;
            userVariableAlphaR2.VariableValue = alphaCoeff(3);
            userVariableAlphaR2.EnableControlParameter;


            userVariableBetaR1 = UVsegment.UserVariables.Item(TFCcoefficients{4});
            userVariableBetaR1.VariableAction = set_action;
            userVariableBetaR1.VariableValue = alphaCoeff(4);
            userVariableBetaR1.EnableControlParameter;


            %Transverse
            userVariableAlphaS0 = UVsegment.UserVariables.Item(TFCcoefficients{5});
            userVariableAlphaS0.VariableAction = set_action;
            userVariableAlphaS0.VariableValue = alphaCoeff(5);
            userVariableAlphaS0.EnableControlParameter;

            userVariableAlphaS1 = UVsegment.UserVariables.Item(TFCcoefficients{6});
            userVariableAlphaS1.VariableAction = set_action;
            userVariableAlphaS1.VariableValue = alphaCoeff(6);
            userVariableAlphaS1.EnableControlParameter;


            userVariableAlphaS2 = UVsegment.UserVariables.Item(TFCcoefficients{7});
            userVariableAlphaS2.VariableAction = set_action;
            userVariableAlphaS2.VariableValue = alphaCoeff(7);
            userVariableAlphaS2.EnableControlParameter;

            userVariableBetaS1 = UVsegment.UserVariables.Item(TFCcoefficients{8});
            userVariableBetaS1.VariableAction = set_action;
            userVariableBetaS1.VariableValue = alphaCoeff(8);
            userVariableBetaS1.EnableControlParameter;

            userVariableBetaS2 = UVsegment.UserVariables.Item(TFCcoefficients{9});
            userVariableBetaS2.VariableAction = set_action;
            userVariableBetaS2.VariableValue = alphaCoeff(9);
            userVariableBetaS2.EnableControlParameter;


            %Normal
            userVariableAlphaW0 = UVsegment.UserVariables.Item(TFCcoefficients{10});
            userVariableAlphaW0.VariableAction = set_action;
            userVariableAlphaW0.VariableValue = alphaCoeff(10);
            userVariableAlphaW0.EnableControlParameter;

            userVariableAlphaW1 = UVsegment.UserVariables.Item(TFCcoefficients{11});
            userVariableAlphaW1.VariableAction = set_action;
            userVariableAlphaW1.VariableValue = alphaCoeff(11);
            userVariableAlphaW1.EnableControlParameter;

            userVariableAlphaW2 = UVsegment.UserVariables.Item(TFCcoefficients{12});
            userVariableAlphaW2.VariableAction = set_action;
            userVariableAlphaW2.VariableValue = alphaCoeff(12);
            userVariableAlphaW2.EnableControlParameter;

            userVariableBetaW1 = UVsegment.UserVariables.Item(TFCcoefficients{13});
            userVariableBetaW1.VariableAction = set_action;
            userVariableBetaW1.VariableValue = alphaCoeff(13);
            userVariableBetaW1.EnableControlParameter;

            userVariableBetaW2 = UVsegment.UserVariables.Item(TFCcoefficients{14});
            userVariableBetaW2.VariableAction = set_action;
            userVariableBetaW2.VariableValue = alphaCoeff(14);
            userVariableBetaW2.EnableControlParameter;
end

classdef pldaps < handle
%pldaps    main class for PLDAPS (Plexon Datapixx PsychToolbox) version 4.1
% The pldaps constructor accepts the following inputs, all are required in the following order:
%     1. a subject identifier (string)
%     2. a struct that contains all the defaultParameters
%     3. An experimental setup function
% Read README.md for a more detailed explanation of the default usage
% Conditions should not be specified in the input arguments

% October 2017, Nate Faber. Removed params class for faster intertrial intervals and simpler design


 properties
    defaultParameters

    conditions@cell %cell array with a struct like defaultParameters that only hold condition specific changes or additions

    trial %will get all variables from defaultParameters + correct conditions cell merged. This will get saved automatically. 
          %You can add calculated parameters to this struct, e.g. the
          %actual eyeposition used for calculating the frame, etc.
          
    session               % WZ: store session relevant information here    
    
    data                  % WZ: keep essential data across trials
    
    plotdata              % WZ: temporary ad hoc addition to get plots working again
    
    PAL                   % WZ: preparation for an integration of the palamedes toolbox
    
    functionHandles%@cell %mostly unused atm
 end

 methods
     function p = pldaps(varargin)
        
        % Load in the defaultParameters
        p.defaultParameters = varargin{2};
        
        % Set the subject name
        p.defaultParameters.session.subject=varagin{1};
        
        % Set the experimental setup file
        if isa(varargin{3}, 'function_handle')
            p.defaultParameters.session.experimentSetupFile=func2str(varagin{3});
        else
            p.defaultParameters.session.experimentSetupFile=varagin{3};
        end
    end 
     
    
 end %methods

 methods(Static)
      [xy,z] = deg2px(p,xy,z,zIsR)
      
      [xy,z] = deg2world(p,xy,z,zIsR)
      
      [xy,z] = px2deg(p,xy,z)
      
      [xy,z] = world2deg(p,xy,z)
      
      s = pldapsClassDefaultParameters(s)
      
      [stateValue, stateName] = getReorderedFrameStates(trialStates,moduleRequestedStates)
 end

end
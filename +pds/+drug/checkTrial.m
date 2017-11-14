function p = checkTrial(p)
% p = pds.drug.checkTrial(p)
% check if the current trial will be a drug trial
% 
% wolf zinke, Nov 2017

if(~p.trial.Drug.DoStim)
    p.trial.Drug.StimTrial = 0;  % just be sure that this is set as no stimulation trial
else
    
    switch p.trial.Drug.StimDesign 
        
        case {'random', 'rand', 'r'}
        %% determine if this is a drug trial by chance for every single trial
        %ToDo: -right now it assumes a 50% chance according to an uniform distribution, different 
        %       distributions and probabilities could be implemented;   
            p.trial.Drug.StimTrial = rand(1) > 0.5;
            
        case {'block', 'b','key','k'}
        %% Blocks of drug injection and and wash-out, includes key trigered block
             if(p.trial.Drug.StimDesign(1) == 'b')
                 p.trial.Drug.TriggerStim;
             end
                
        case {'condition', 'cond', 'c'}
        %% Drug delevery determined by condition
        % not much to do here, p.trial.Drug.StimTrial should be present in the condition struct
        % or it should be set in the trial setup based on condition number
        
        otherwise  
            error('Drug application design <%s> unknown!', p.trial.Drug.StimDesign );
    end
end


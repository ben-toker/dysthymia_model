% Generate a time course of cue and reward through simple Pavlovian task
% simulation

function [time,cue,reward] = task_generate(nTrials,rewardProb,rewardMag, cueRewardDelay, ITI,dt)
    % nTrials = number of Trials
    % rewardProb = the probability that a reward will come after the cue
    % dt = delta T = timestep interval
    % cueRewardDelay = # of (dt) time units between cue and reward
    % ITI = inter-trial interval

    trialDuration = cueRewardDelay + ITI; % determines how long each trial is 
    total_time = nTrials * trialDuration; 

    t = 0:dt:total_time; % number of time steps
    time=t;

    cue = zeros(1,length(t));
    reward = zeroes(1,length(t));

    for i = 1:nTrials
       trialStart = (i-1) * trialDuration; %starts at the end of the previous trial
       cueTime = trialStart; % cue right at the start of the trial
       rewardTime = trialStart + cueRewardDelay; 

       cue(cueTime) = 1;

       if randn < rewardProb %randomized reward chance
            reward(rewardTime) = rewardMag;
       end

    end

    

end


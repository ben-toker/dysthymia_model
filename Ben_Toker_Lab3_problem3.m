function lab3prob3() 

dt=0.1; %timestep duration in seconds
maxTime=100; % time period we want to plot
tau = 10; %time constant
theta = 0.4; %spiking threshold 

numUnits =4; %number of leaky integrators we want in the network

t = 0:dt:maxTime; % set of timesteps
V = nan(numUnits,length(t)); 
V(:,1) = 0;

I = rand(numUnits,length(t))>0.95; % random input signal for each unit

spikecounts=zeros(numUnits,length(t));

W = randn(numUnits); %weight matrix of size n x nx



for i = 1:length(t)-1
    dVdt=(-1*V(:,i) + I(:,i))/tau; %dV/dt = (-V+I)/tau
    V(:,i+1) = V(:,i) + dVdt * dt; 
    
    inputspikes = I(:,i) > 0; %if there is an impulse
    V(inputspikes,i+1) = V(inputspikes,i)+ 1/tau;
    

    activations = V(:,i+1) > theta;   % logical column, units × 1
    spikecounts(activations, i) = 1;  % mark spikes in row i, at the right units
    V(activations, i+1) = 0;          % reset voltages for spiking units
end

pl=tiledlayout(numUnits,2);
title(pl,"");

colors = lines(numUnits);   % generate a set of distinct colors


for i = 1:numUnits
nexttile
plot(t,V(i,:),'LineWidth',2,'Color',colors(i,:)) %voltage
hold on;
plot(t,I(i,:),'r') % input
yline(theta)
title('Voltage of leaky integrator in response to step inputs')
end

nexttile([2 2])

hold on
for i = 1:numUnits
    for j = 1:length(t)
        if spikecounts(i,j) == 1
            plot([t(j) t(j)], [i-1 i], 'Color', colors(i,:), 'LineWidth', 2)
        end
    end
end
hold off
title('Spike occurences')




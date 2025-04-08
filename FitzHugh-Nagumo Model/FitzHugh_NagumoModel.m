% Replace the following constants with your own values
tspan = [0 100];  % start and end times
v0 = 0; w0 = 0; % initial values
IC = [v0 w0];


[t, vw] = ode45(@fn, tspan,IC);
% Extract individual solution values
v = vw(:,1);
w = vw(:,2);
% Plot results
plot(t,v,'r',t,w,'b'),grid
xlabel('t'),ylabel('v and w')
legend('v','w')

function dvwdt = fn(~,vw)
        
         a = 0.7; 
         b = 0.8;
         g = 0.08;
         i = 0.5;
         v = vw(1);
         w = vw(2);
         dvwdt = [v - v^3/3 - w + i;
                  g*(v+a-b*w)];          

end

% Parameters
a = 0.7; b = 0.8; g = 0.08; I = 0.5;

% Create grid for phase plane
v_values = linspace(-2.5, 2.5, 50);
w_values = linspace(-1, 2, 50);
[V, W] = meshgrid(v_values, w_values);

% Calculate derivatives
dV = V - V.^3/3 - W + I;
dW = g*(V + a - b*W);

% Nullclines
v_null = @(v) v - v.^3/3 + I;
w_null = @(v) (v + a)/b;

% Plotting
figure;
hold on;


% Nullclines
fplot(v_null, [-2.5, 2.5], 'r', 'LineWidth', 2);
fplot(w_null, [-2.5, 2.5], 'b', 'LineWidth', 2);

% Trajectory from simulation
plot(v, w, 'g', 'LineWidth', 1.5);


% Formatting
xlabel('Membrane Potential (v)');
ylabel('Recovery Variable (w)');
title('Phase Plane Analysis of FHN Model');
legend('v-nullcline', 'w-nullcline', 'Trajectory', 'Equilibrium Point');
grid on;
axis([-2.5 2.5 -1 2]);
hold off;
% Cainiello Neuron Bifurcation Diagram in MATLAB

% Parameters
beta = 0.5;           % Feedback from x(t-1)
gamma = 0.0;          % Bias
numSteps = 1000;      % Total steps
transient = 300;      % Steps to discard
alphaVals = linspace(0, 5, 1000); % Alpha sweep range

% Preallocate for plotting
allAlpha = [];
allX = [];

% Loop over alpha values
for a = alphaVals
    x_t = 0.1;
    x_tm1 = 0.0;
    trajectory = zeros(1, numSteps - transient);

    for t = 1:numSteps
        x_tp1 = tanh(a * x_t + beta * x_tm1 + gamma);
        x_tm1 = x_t;
        x_t = x_tp1;

        if t > transient
            trajectory(t - transient) = x_t;
        end
    end

    % Store points
    allAlpha = [allAlpha, repmat(a, 1, length(trajectory))];
    allX = [allX, trajectory];
end

% Plot
figure('Color', 'w');
plot(allAlpha, allX, '.k', 'MarkerSize', 1);
xlabel('\alpha');
ylabel('x');
title('Bifurcation Diagram of Cainiello Neuron Model');
grid on;
xlim([min(alphaVals), max(alphaVals)]);

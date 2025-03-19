function y_next = chaotic_neuron(y, k, alpha, a, epsilon)
    % Chaotic neuron model developed by Aihara, Takabe, and Toyoda
    % Inputs:
    %   y: Current internal state of the neuron
    %   k: Decay parameter (0 < k < 1)
    %   alpha: Strength of the refractory effect
    %   a: External input
    %   epsilon: Steepness parameter of the sigmoid function
    % Output:
    %   y_next: Next internal state of the neuron

    % Sigmoid function
    f = 1 / (1 + exp(-y / epsilon));

    % Update equation
    y_next = k * y - alpha * f + a;
end
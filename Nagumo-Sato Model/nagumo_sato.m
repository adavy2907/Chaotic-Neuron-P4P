function y_next = nagumo_sato(y, k, alpha, a)
    % Nagumo-Sato neuron model
    % Inputs:
    %   y: Current internal state of the neuron
    %   k: Decay parameter (0 < k < 1)
    %   alpha: Strength of the refractory effect
    %   a: External input
    % Output:
    %   y_next: Next internal state of the neuron

    % Binary output function (step function)
    if y >= 0
        f = 1;
    else
        f = 0;
    end

    % Update equation
    y_next = k * y - alpha * f + a;
end
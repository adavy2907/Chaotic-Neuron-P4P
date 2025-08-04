import numpy as np
import math

class TCNN:
    """
    Implements a Transiently Chaotic Neural Network (TCNN), as presented in
    "Chaotic Simulated Annealing by a Neural Network Model with Transient Chaos"
    by Chen and Aihara, 1995.

    This TCNN is specifically tailored for solving the traveling salesman 
    problem (TSP). For a n-city TSP, there will be a total of N = n^2 neurons,
    or n rows of n neurons.
    """
    def __init__(self, distances, **constants):
        # Ensure the distance matrix is square
        m,n = distances.shape
        if m != n:
            raise RuntimeError("Distance matrix is not square")
        
        self.real_distances = distances
        self.norm_distances = distances / distances.max()  # Normalize distances for stability
        self.n = n
        ns = range(n)
        self.ns = ns
        
        # Store all constants for the neural network dynamics
        self.W1 = constants["W1"]      # Validity constraint weight
        self.W2 = constants["W2"]      # Optimality constraint weight
        self.alpha = constants["alpha"]# Scaling parameter for neuron inputs
        self.beta = constants["beta"]  # Self-connection damping factor
        self.epsilon = constants["epsilon"] # Neuron output function steepness
        self.k = constants["k"]        # Nerve membrane damping factor
        self.z0 = constants["z0"]      # Initial self-connection weight
        self.I0 = constants["I0"]      # Input bias

        self.z = self.z0               # Dynamic self-connection weight
        self.X = np.zeros((n,n))       # Internal state of neurons
        self.Y = np.zeros((n,n))       # Output of neurons

        self.X += np.random.uniform(-1, 1, (n,n)) # Random initial state
        self.pairs = self.__random_pairs()        # Random update order for neurons
        self.iter = 0                            # Iteration counter

    def __random_pairs(self):
        # Generate all possible (i, j) neuron pairs and shuffle them
        pairs = []
        for i in self.ns:
            for j in self.ns:
                pairs.append((i,j))
        np.random.shuffle(pairs)
        return pairs
            
    def __g(self,x):
        # Neuron activation function (sigmoid-like)
        #return 1.0 / (1 + math.exp(-x / self.epsilon))
        return 0.5 * (1 + math.tanh(x/self.epsilon))

    def __retrieve(self, attr):
        # Helper to get attribute or call method for result collection
        res = getattr(self,attr)
        if callable(res):
            return res()
        else:
            return res
        
    def run(self, maxiter=None, collecting=None):
        """
        Run the TCNN until a valid tour is found or maxiter is reached.
        Optionally collect specified attributes at each step.
        """
        results = {"steps":[]}
        if collecting:
            for attr in collecting:
                results[attr] = []
        
        iters = 0
        while not self.valid_tour() and (iters < maxiter if maxiter else True):
            self.step()
            if collecting:
                for attr in collecting:
                    results[attr].append(self.__retrieve(attr))
            iters += 1
        return results
    
    def step(self):
        """
        Perform one asynchronous update of all neurons in random order,
        then update the self-connection weight and iteration counter.
        """
        #for i,k in self.__random_pairs():
        for i,k in self.pairs:
            self.__update_neuron(i,k)
        
        self.z *= (1 - self.beta)  # Dampen self-connection weight
        self.iter += 1

    def __update_output(self,i,k):
        # Update the output of neuron (i, k) using activation function
        self.Y[i,k] = self.__g(self.X[i,k])
        
    def __update_neuron(self,i,k):
        """
        Update the internal state and output of neuron (i, k) according to TCNN dynamics.
        """
        n, X, Y = self.n, self.X, self.Y
        W1, W2, alpha = self.W1, self.W2, self.alpha
        ns, ds = self.ns, self.norm_distances
        
        # Validity constraint: penalize multiple visits to a city or multiple cities at a position
        a = -W1*(
            sum(Y[i,l] if l != k else 0.0 for l in ns) + 
            sum(Y[j,k] if j != i else 0.0 for j in ns)
        )
        # Optimality constraint: encourage short tours
        b = -W2*sum(ds[i,j]*(Y[j,(k+1)%n] + Y[j,(k-1)%n]) if j != i else 0.0 for j in ns)
        
        # Membrane and bias terms
        c = self.k*X[i,k] - self.z*(Y[i, k] - self.I0)
        
        # Update internal state and output
        X[i,k] = alpha*(a + b + W1) + c
        self.__update_output(i,k)
        
    def energy(self):
        """
        Compute the total energy of the network, combining validity and optimality constraints.
        Lower energy means a better (more valid and shorter) tour.
        """
        W1, W2, Y = self.W1, self.W2, self.Y
        n, ns, ds = self.n, self.ns, self.norm_distances
        
        # Validity: each city visited once, each position filled once
        temp1 = sum((sum(Y[i,k] for k in ns) - 1.0)**2 for i in ns)
        temp2 = sum((sum(Y[i,k] for i in ns) - 1.0)**2 for k in ns)
        
        # Optimality: sum of distances for the tour
        temp3 = 0.0
        for i in ns:
            for j in ns:
                for k in ns:
                    temp3 += ds[i,j]*Y[i,k]*(Y[j,(k+1)%n] + Y[j,(k-1)%n])
        
        E1 = 0.5*W1*(temp1 + temp2)
        E2 = 0.5*W2*temp3
        return E1 + E2
        
    def valid_rows(self):
        # Check if each city is visited exactly once (row constraint)
        return [ len(np.where(self.Y[i])[0]) == 1 for i in self.ns ]
    
    def valid_cols(self):
        # Check if each tour position is filled by exactly one city (column constraint)
        YT = self.Y.transpose()
        return [ len(np.where(YT[i])[0]) == 1 for i in self.ns ]
        
    def n_valid_rows(self):
        # Number of valid rows (cities visited once)
        return len(np.where(self.valid_rows())[0])
        
    def n_valid_cols(self):
        # Number of valid columns (positions filled once)
        return len(np.where(self.valid_cols())[0])
    
    def percent_valid(self):
        # Fraction of valid rows and columns
        total = self.n_valid_rows() + self.n_valid_cols()
        return total / (2.0 * self.n)

    def valid_tour(self):
        # True if all rows and columns are valid (a valid tour)
        return self.percent_valid() == 1
    
    def tour(self):
        # Return the tour as a list of city indices if valid
        if not self.valid_tour:
            raise RuntimeError("Tour is not valid!")
        
        ns, YT = self.ns, self.Y.transpose()
        return [ np.where(YT[i])[0][0] for i in ns ]
        
    def tour_length(self):
        # Compute the total length of the current tour
        n, ns, ds = self.n, self.ns, self.real_distances
        
        tour = self.tour()
        citypairs = [(tour[i], tour[(i+1)%n]) for i in ns ]
        distances = [ ds[cp[0],cp[1]] for cp in citypairs ]
        return sum(distances)

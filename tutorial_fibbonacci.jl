# Intro to computer Science and Optimmization
# fibbonacci recursive
function fib(n)
    if (n==0) | (n==1)
        return 1
    else
        return fib(n-1)+fib(n-2)
    end
end

# fibbonacci iterative : Memorization
function fib_iter(n)
    # initial condition
    previous1_fib = 1;
    previous2_fib = 1;
    current_fib = 1;

    # return first 2 
    if n<=2
        return 1;
    end
    
    # Loop
    for i=2:n
        previous2_fib = previous1_fib;
        previous1_fib = current_fib;
        current_fib = previous1_fib + previous2_fib;          
    end

    return current_fib;
end
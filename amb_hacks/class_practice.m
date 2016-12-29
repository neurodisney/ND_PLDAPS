function y = newton(u, v, x)
y = fzero(@fofx, x)
    function y = fofx(x)
        y = x^3 + u*x + v;
    end
end
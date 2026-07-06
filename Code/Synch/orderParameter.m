function [r, psi] = orderParameter(theta)
%ORDERPARAMETER  How synchronized is a group of oscillators?
%
%   [r, psi] = orderParameter(theta)
%
% Give it a list of phases (angles), and it returns:
%   r   = the "sync level", from 0 to 1
%         0  -> total disorder (everyone points a different way)
%         1  -> perfect sync   (everyone points the same way)
%   psi = the average phase (which way the group points on average)
%
% The trick: put each oscillator as an arrow of length 1 on a circle,
% then add all the arrows up. If they point every-which-way they cancel
% out (r near 0). If they point together, they add up (r near 1).

    z   = mean(exp(1i * theta(:)));   % average of all the little arrows
    r   = abs(z);                     % how long the combined arrow is
    psi = angle(z);                   % which direction it points
end

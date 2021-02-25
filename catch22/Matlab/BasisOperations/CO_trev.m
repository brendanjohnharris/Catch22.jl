function out = CO_trev(y, tau)
% CO_trev   Normalized nonlinear autocorrelation, trev function of a time series
%
% Calculates the trev function, a normalized nonlinear autocorrelation,
% mentioned in the documentation of the TSTOOL nonlinear time-series analysis
% package (available here: http://www.physik3.gwdg.de/tstool/).
%
% The quantity is often used as a nonlinearity statistic in surrogate data
% analysis, cf. "Surrogate time series", T. Schreiber and A. Schmitz, Physica D,
% 142(3-4) 346 (2000).
%
%---INPUTS:
%
% y, time series
%
% tau, time lag (can be 'ac' or 'mi' to set as the first zero-crossing of the
%       autocorrelation function, or the first minimum of the automutual
%       information function, respectively)
%
%---OUTPUTS:
% the trev numerator and the denominator.

% ------------------------------------------------------------------------------
% Copyright (C) 2017, Ben D. Fulcher <ben.d.fulcher@gmail.com>,
% <http://www.benfulcher.com>
%
% If you use this code for your research, please cite the following two papers:
%
% (1) B.D. Fulcher and N.S. Jones, "hctsa: A Computational Framework for Automated
% Time-Series Phenotyping Using Massive Feature Extraction, Cell Systems 5: 527 (2017).
% DOI: 10.1016/j.cels.2017.10.001
%
% (2) B.D. Fulcher, M.A. Little, N.S. Jones, "Highly comparative time-series
% analysis: the empirical structure of time series and their methods",
% J. Roy. Soc. Interface 10(83) 20130048 (2013).
% DOI: 10.1098/rsif.2013.0048
%
% This function is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
%% Set defaults:
% ------------------------------------------------------------------------------
if nargin < 2 || isempty(tau)
    tau = 1;
end

% ------------------------------------------------------------------------------
% Compute trev quantities
% ------------------------------------------------------------------------------

yn = y(1:end-tau);
yn1 = y(1+tau:end); % yn, tau steps ahead

% ------------------------------------------------------------------------------
% Fill output struct
% ------------------------------------------------------------------------------

% % The numerator
out.num = mean((yn1-yn).^3);

% The denominator
out.denom = (mean((yn1-yn).^2))^(3/2);

end

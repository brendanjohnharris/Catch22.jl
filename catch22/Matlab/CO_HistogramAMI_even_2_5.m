function out = CO_HistogramAMI_even_2_5(y)
% CO_HistogramAMI      The automutual information of the distribution using histograms.
%
% The approach used to bin the data is provided.
%
%---INPUTS:
%
% y, the input time series
%
% tau, 2: the time-lag
%
% meth, 'even': evenly-spaced bins through the range of the time series,
%
% numBins, 5: the number of bins
%
%---OUTPUT: the automutual information calculated in this way.

% Uses the hist2 function (renamed NK_hist2.m here) by Nedialko Krouchev, obtained
% from Matlab Central,
% http://www.mathworks.com/matlabcentral/fileexchange/12346-hist2-for-the-people
% [[hist2 for the people by Nedialko Krouchev, 20 Sep 2006 (Updated 21 Sep 2006)]]

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

% no combination of single functions
coder.inline('never');

% ------------------------------------------------------------------------------
%% Check Inputs:
% ------------------------------------------------------------------------------

% Number of options:
% remove outliers first?, number of bins, range of bins, bin sizes

tau = 2;
% meth = 'even';
numBins = 5;

% ------------------------------------------------------------------------------
%% Bins by standard deviation (=1)
% ------------------------------------------------------------------------------

% even
b = linspace(min(y)-0.1,max(y)+0.1,numBins+1); % +0.1 to make sure all points included

nb = length(b) - 1; % number of bins (-1 since b defines edges)

% ------------------------------------------------------------------------------
% Form the time-delay vectors y1 and y2
% ------------------------------------------------------------------------------

y1 = y(1:end-tau);
y2 = y(1+tau:end);

% (1) Joint distribution of y1 and y2
pij = NK_hist2(y1,y2,b,b);
pij = pij(1:nb,1:nb); % joint
pij = pij/sum(sum(pij)); % joint
pi = sum(pij,1); % marginal
pj = sum(pij,2); % other marginal

% Old-fashioned method (should give same result):
% pi = histc(y1,b); pi = pi(1:nb); pi = pi/sum(pi); % marginal
% pj = histc(y2,b); pj= pj(1:nb); pj = pj/sum(pj); % other marginal

pii = ones(nb,1)*pi;
pjj = pj*ones(1,nb);

r = (pij > 0); % Defining the range in this way, we set log(0) = 0
ami = sum(pij(r).*log(pij(r)./pii(r)./pjj(r)));

out = ami;

end

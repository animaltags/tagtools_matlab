function    e = odba(A,n,method)

%       e = odba(A,fh)              % A is a sensor structure
%		  or
%       e = odba(A,n,method)        % A is a sensor structure
%		  or
%       e = odba(A,fs,fh)           % A is a matrix
%		  or
%		  e = odba(A,n,method)        % A is a matrix
%
%       Compute the 'Overall Dynamic Body Acceleration' sensu Wilson et al. 2006.
%       ODBA is the norm of the high-pass-filtered acceleration. Several methods
%		  for computing ODBA are in use which differ by which norm and which filter
%		  are used. In the Wilson paper, the 1-norm and a rectangular window (moving
%		  average) filter are used. The moving average is subtracted from the input
%		  accelerations to implement a high-pass filter. The 2-norm may be preferable 
%		  if the tag orientation is unknown or may change and this is termed VeDBA. 
%		  A tapered symmetric FIR filter gives more efficient high-pass filtering 
%		  compared to the rectangular window method and avoids lobes in the response.
%
%		  Inputs:
%       A is a sensor structure or a 3 column acceleration matrix with columns 
%        [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. 
%        A can be in any frame but the result depends on the method used to compute 
%        ODBA. The default method and VeDBA method are rotation independent and so 
%        give the same result irrespective of the frame of A. The 1-norm method has 
%        a more complex dependency on frame.
%       fs is the sampling rate in Hz of the acceleration signals. This is only
%        required if A is a matrix and if FIR filtering is used (i.e., if you are also
%        giving a fh argument).
%       fh is the high-pass filter cut-off frequency in Hz. This should be chosen
%		   to be about half of the stroking rate for the animal (e.g., using dsf.m).
%			fh is only needed if using the default (FIR filtering) method.
%		  n is the rectangular window (moving average) length in samples. This is only
%		   needed if using the classic ODBA and VeDBA forms.
%		  method is a string containing either 'wilson' or 'vedba'. If the third argument
%		   to odba.m is a string, either the classic 1-norm ODBA ('wilson') or the 2-norm 
%		   VeDBA ('vedba') is computed, in either case with an n-length rectangular window.
%
%		  Result:
%       e is a column vector of ODBA with the same number of rows as A. e has the same
%		   units as A.
%
%	Examples:
%		   odba([1,-0.5,0.1;0.8,-0.2,0.6;0.5,-0.9,-0.7;0.6,-0.2,0.8],5,'vedba')
%		   returns: [0.1536;0.4944;1.1534;0.3682]
%
%		   odba([1,-0.5,0.1;0.8,-0.2,0.6;0.5,-0.9,-0.7;0.6,-0.2,0.8],5,'wilson')
%		   returns: [0.22;0.7;1.72;0.5]
%
%	See Wilson et al. 2006 Moving towards acceleration for estimates of activity 
%       specific metabolic rate in free living animals: the case of the cormorant.
%	J. Animal Ecology 75:1081-1090. https://doi.org/10.1111/j.1365-2656.2006.01127.x
%
%	Delay-free filtering is used for all filter types.
%
%       Valid: Matlab, Octave
%       markjohnson@st-andrews.ac.uk
%       Last modified: 5 May 2017
%		  19 May 2020: embarrassing error corrected in the Wilson and VeDBA filter calculation
%		  28 Jan 2023: another embarrassing error corrected in the input parameters

e = [] ;
if nargin<2,
	help odba
	return
end

if isstruct(A),
   if nargin==2,
      method = n ;	%  for call type: e = odba(A,fh), method will be used as fh
   end
   [A,fs]=sens2var(A,'regular') ;
   if isempty(A), return, end
else
   if nargin<3,
   	help odba
   	return
   end
   fs = n ;		%  for call type: e = odba(A,fs,fh) 
end

if ischar(method),				% 'wilson' or 'vedba' method is selected
	n = 2*floor(n/2)+1 ; 	% make sure n is odd
	nz = floor(n/2) ;
	h = [zeros(nz,1);1;zeros(nz,1)]-ones(n,1)/n ;
	%Ah = filter(h,1,[zeros(nz,size(A,2));A;zeros(nz,size(A,2))]) ;  % was this
	Ah = filter(h,1,[repmat(A(1,:),nz,1);A;repmat(A(end,:),nz,1)]) ; % more sensible start/end values
	Ah = Ah(n-1+(1:size(A,1)),:) ;
	switch method
		case 'vedba'
			e = sqrt(sum(Ah.^2,2)) ;		% vedba: use 2-norm
		case 'wilson'
			e = sum(abs(Ah),2) ;			% Wilson method: use 1-norm
		otherwise
			fprintf('Unknown method: %s\n',method)
	end
else
	fh = method ;
	n = 4*round(fs/fh) ;
	if size(A,1)<=n/2,
		fprintf('A needs at least %d rows to compute filter\n',floor(n/2)+1);
		return
	end
   	Ah = fir_nodelay(A,n,fh/(fs/2),'high') ;
	e = sqrt(sum(abs(Ah).^2,2)) ;
end

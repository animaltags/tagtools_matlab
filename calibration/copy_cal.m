function		CAL = copy_cal(S,CAL)

%		CAL = copy_cal(S)
%		or
%		CAL = copy_cal(S,CAL)
%
%		Copy the calibration information embedded in a sensor data structure.
%		This can be used to apply a calibration performed on data at one
%		sampling rate to data from the same source at a different sampling rate.
%		Calibration information fields in S must be prefixed with 'cal_'. If the
%		data in S was calibrated using do_cal or any of the automatic calibration
%		tools in the animaltags tools, it will contain corresponding metadata fields
%		of the form 'cal_xxxx' that document the calibration actions.
%
%		Input:
%		S is a sensor structure.
%		CAL is an optional calibration structure. If CAL is given, the calibration
%		 information in S will be added to this structure and will over-write fields in
%		 CAL that have the same name as fields in S. If CAL is not given, a new
%		 calibration structure will be made.
%
%		Returns:
%		CAL is a calibration structure for the data in S. Cal fields currently 
%		supported are:
%     poly, cross, map, tcomp, tref, tseg
%		Any other fields in cal will be ignored.
%
%     Valid: Matlab, Octave
%     markjohnson@bio.au.dk
%     Created: June 2022

if nargin<2,
	CAL = [] ;
elseif ~isstruct(CAL),
	fprintf('CAL must be a sensor calibration structure\n') ;
	return
end
	
if nargin<1,
	help copy_cal
	return
end
	
if ~isstruct(S),
	fprintf('First argument must be a sensor data structure, e.g., from sens_struct\n') ;
	return
end

n = size(S.data,2) ;
N = fieldnames(S) ;
kf = find(strncmp('cal_',N,4)==1) ; 
for k=kf(:)',
	cname = N{k}(5:end) ;
	cval = S.(N{k}) ;
	if n>1 & ~any(strcmp(cname,{'tref','tseg'})) & rem(length(cval),n)==0,
		cval = reshape(cval,n,[]) ;
	end
	CAL.(cname) = cval ;
end
	
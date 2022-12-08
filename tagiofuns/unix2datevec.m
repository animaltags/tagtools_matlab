function    [dvec,jvec] = unix2datevec(dnum,offset)
%
%    [dvec,jvec] = unix2datevec(dnum,offset)
%
%     Convert UNIX time into a 6-element
%     datevector [year month day hour minute second].
%		dnum can be a vector of numbers or a string containing
%		a UNIX time in hexadecimal, e.g., from a DTAG XML file.
%     The UNIX time is the number of seconds 
%     since midnight Jan 1 1970.
%     Optional offset is an additional offset in seconds to
%     add to dnum before processing. Processing is done using
%     extended precision to maintain accuracy.
%     Optional output jvec is [day_of_year, second_of_day],
%     which is an alternative more compact time code.
%
%     markjohnson@bio.au.dk
%     last modified 29 july 2015 - added offset and jvec
%							1 August 2022 - converted from d3datevec

if nargin<2,
   offset = 0 ;
end

dd = datenum([1970 1 1 0 0 0]) ;
if ischar(dnum),
	dnum = hex2dec(dnum) ;
end
	
dnum = dnum(:) ;

% handle seconds and fractions of a second separately to keep precision
frac = rem(dnum,1)+rem(offset,1) ;  % fractions of a second
dnum = floor(dnum)+floor(offset)+floor(frac) ;  % whole seconds
frac = frac-floor(frac) ;
dvec = datevec(dnum(:)/3600/24+dd) ;
dvec(:,end) = dvec(:,end)+frac ;

if nargout==2,
   jvec = [jday(dvec(:,1:3)) dvec(:,4:6)*[3600;60;1]] ;
end

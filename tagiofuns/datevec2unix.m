function    t = datevec2unix(dvec)
%
%    t = datevec2unix(dvec)
%
%     Convert a 6-element datevector [year month day hour minute second]
%		into a UNIX time number.
%     UNIX time is the number of seconds since midnight Jan 1 1970.
%
%     markjohnson@bio.au.dk
%     created 24 oct 2022

dn = datenum(dvec) ;
dd = datenum([1970 1 1 0 0 0]) ;
t = (24*3600)*(dn-dd) ;

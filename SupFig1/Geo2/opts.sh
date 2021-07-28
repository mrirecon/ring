NAME=Geo2
OUT=c

if bart version -t v0.6.00 >/dev/null 2>&1 ; then
	POPTS="-G -g2"
else
	POPTS="-G 2"
fi

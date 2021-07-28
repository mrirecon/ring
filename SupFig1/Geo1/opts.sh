NAME=Geo1
OUT=b

if bart version -t v0.6.00 >/dev/null 2>&1 ; then
	POPTS="-G -g1"
else
	POPTS="-G 1"
fi

#/bin/bash 

while getopts "i:o:" opt; do
  case $opt in
    i) infile="$OPTARG" ;;
    o) outfile="$OPTARG" ;;
    *) echo "Usage: $0 -i input.nc -o output.nc"; exit 1 ;;
  esac
done

if [ -z "$infile" ] || [ -z "$outfile" ]; then
  echo "Usage: $0 -i input.nc -o output.nc"
  exit 1
fi

cat <<EOF > gridlonlat.txt
gridtype = lonlat
xsize    = 318
ysize    = 276
xfirst   = 85.67
xinc     = 0.03
yfirst   = 22.65
yinc     = 0.03
EOF

#cdo remapbil,gridlonlat.txt 2015113000WRF2HBV.nc out_latlon.nc
cdo remapbil,gridlonlat.txt "$infile" "$outfile"
rm -f gridlonlat.txt

ncrename -v APCP_surface,precipitation "$outfile"
ncatted -a units,precipitation,o,c,"mm" \
        -a standard_name,precipitation,o,c,"precipitation_flux" \
        -a long_name,precipitation,o,c,"Precipitation" "$outfile"

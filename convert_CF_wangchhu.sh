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
xsize    = 364
ysize    = 484
xfirst   = 89.00
xinc     = 0.0025
yfirst   = 26.7
yinc     = 0.0025
EOF

cdo remapbil,gridlonlat.txt "$infile" "$outfile"
rm -f gridlonlat.txt

ncrename -v APCP_surface,precipitation "$outfile"
ncatted -a units,precipitation,o,c,"mm" \
        -a standard_name,precipitation,o,c,"precipitation_flux" \
        -a long_name,precipitation,o,c,"Precipitation" "$outfile"



#---- 

for f in ./subbasin_boundaries/*.txt
do
  filename=`basename -a "${f%.*}"`
  cdo fldmean -maskregion,${f} -selvar,TMP_2maboveground -delete,timestep=1 ${outfile} tmp.nc
  cdo fldmean -maskregion,${f} -selvar,precipitation -delete,timestep=1 ${outfile} pr.nc
  cdo outputtab,date,time,value tmp.nc >T2M-${filename}-${outfile}.ascii
  cdo outputtab,date,time,value pr.nc >PR-${filename}-${outfile}.ascii   
  sed -i "s/value/${filename}/" T2M-${filename}-${outfile}.ascii
  sed -i "s/value/${filename}/" PR-${filename}-${outfile}.ascii
  sed -i "s/#/ /" T2M-${filename}-${outfile}.ascii
  sed -i "s/#/ /" PR-${filename}-${outfile}.ascii
done

# joint files
#

#paste T2M-*.ascii >T2M-${outfile}.dat
#paste PR-*.ascii >PR-${outfile}.dat

awk -F' ' '{print $1, $2}' PR-${filename}-${outfile}.ascii >datetime_string

for f in PR-*.ascii
do
   awk -F' ' '{print $3}' ${f} >pr-${f}-value   
done
paste datetime_string pr-*-value > pr_${outfile}.dat

for f in T2M-*.ascii
do
   awk -F' ' '{print $3}' ${f} >t2m-${f}-value
done
paste datetime_string t2m-*-value > t2m_${outfile}.dat


#--- clean up 
rm -f *.ascii
rm -f *-value datetime_string ${outfile}




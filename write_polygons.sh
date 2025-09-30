#!/bin/bash

for nm in $(ogrinfo Corrected_Basin_WGS84.shp \
    -sql "SELECT DISTINCT name FROM Corrected_Basin_WGS84" -geom=no \
    | grep "name (String)" | sed 's/.*= //' | sed 's/\"//g'); do

    fname=$(echo "$nm" | tr ' ' '_' )

    #ogr2ogr -f CSV "${fname}.csv" Corrected_Basin_WGS84.shp \
    #    -explodecollections \
    #    -lco GEOMETRY=AS_WKT \
    #    -where "name='${nm}'"

    # Extract the geometry (2nd column), clean brackets, split to rows
    #tail -n +2 "${fname}.csv" | \
    #awk -F'","' '{print $1}' | sed 's/"//g' | \
    #sed 's/MULTIPOLYGON (((//; s/POLYGON ((//; s/)))//g' | \
    #tr ',' '\n' | tr -s ' ' ' ' | sed 's/^ *//;s/ *$//' \
    #> "${fname}.txt"
    ogr2ogr -f CSV "${fname}.csv" Corrected_Basin_WGS84.shp \
    -explodecollections \
    -lco GEOMETRY=AS_WKT \
    -dialect sqlite \
    -sql "SELECT geometry FROM Corrected_Basin_WGS84 WHERE name='${nm}'"

    tail -n +2 "${fname}.csv" | sed 's/"//g' \
    | sed 's/MULTIPOLYGON (((//; s/POLYGON ((//; s/)))//g' \
    | tr ',' '\n' | tr -s ' ' ' ' | sed 's/^ *//;s/ *$//' \
    > "${fname}.txt"
    
    sed -i 's/))//' ${fname}.txt 
    sed -i 's/)//'  ${fname}.txt
    sed -i 's/(//'  ${fname}.txt
    
    rm "${fname}.csv"
done


#for i in $(seq 0 $(($(ogrinfo -al -so Corrected_Basin_WGS84.shp | grep "Feature Count" | awk '{print $3}') - 1))); do
#    ogr2ogr -f "GeoJSON" temp_$i.json Corrected_Basin_WGS84.shp -where "FID=$i"
#    ogr2ogr -f "CSV" poly_$i.csv temp_$i.json -lco GEOMETRY=AS_WKT
#done

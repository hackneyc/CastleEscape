#!/bin/bash

# width in tiles. zero offset
width=11
# height in tiles. zero offset
height=11
tile=0
tileSheet="sprites.png"
tileSet=tiles/tiles.c

echo "/* Autogenerated tileset */" > $tileSet

for y in $(seq 0 $height)
do
	for x in $(seq 0 $width)
	do
		let tx=$x*8
		let ty=$y*8
		echo "$tx,$ty tile${tile}.png -> tile${tile}.h"
		convert ${tileSheet} -crop 8x8+$tx+$ty tiles/tile${tile}.png
#		convert tiles/tile${tile}.png -threshold 50% -negate tiles/tile${tile}.h
		convert tiles/tile${tile}.png -threshold 50% tiles/tile${tile}.h
		sed -i s/MagickImage/tile${tile}/ tiles/tile${tile}.h
		sed -i "s/0x50, 0x34, 0x0A, 0x38, 0x20, 0x38, 0x0A, //g" tiles/tile${tile}.h
		sed -i "s/static //" tiles/tile${tile}.h
		echo "#include \"tile${tile}.h\"" >> $tileSet
		let tile=$tile+1
	done
done



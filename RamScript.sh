#!/bin/bash

if [ "$3" = "0" ]; then
	selinux=Permissive
fi
if [ "$3" = "1" ]; then
	selinux=Enforcing
fi

for i in $(pwd)/bootimg/AIK-Linux-2.7/cleanup.sh
do
"$i" &
done
wait

cp bootimg/stock_bootimg/$1$2/boot.img $(pwd)/bootimg/AIK-Linux-2.7

for i in $(pwd)/bootimg/AIK-Linux-2.7/unpackimg.sh
do
"$i" &
done
wait

rm $(pwd)/bootimg/AIK-Linux-2.7/split_img/boot.img-zImage
cp $(pwd)/output/arch/arm/boot/zImage $(pwd)/bootimg/AIK-Linux-2.7/split_img/boot.img-zImage

patch $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/default.prop $(pwd)/bootimg/patches/defualt.prop/$1.default.prop.patch
rm $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/init.environ.rc
rm $(pwd)/bootimg/AIK-Linux-2.7/split_img/boot.img-dtb
cp $(pwd)/bootimg/patches/environ-rc/N7 $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/init.environ.rc
cp $(pwd)/bootimg/boot.img-dtb $(pwd)/bootimg/AIK-Linux-2.7/split_img/boot.img-dtb
patch $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/init.rc $(pwd)/bootimg/patches/init.d/init.rc.patch
#patch $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/init.target.rc $(pwd)/bootimg/patches/F2FS/init.target.rc.patch
cp $(pwd)/bootimg/patches/init.d/initd-support.sh $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/sbin
cp $(pwd)/bootimg/patches/init.d/init.d_support.sh $(pwd)/bootimg/AIK-Linux-2.7/ramdisk

#cp -r $(pwd)/bootimg/patches/Synapse_support/ramdisk/* $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/
#patch $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/ueventd.rc $(pwd)/bootimg/patches/Synapse_support/ueventd.rc.patch
#cp $(pwd)/bootimg/patches/Synapse_support/ramdisk_fix_permissions.sh $(pwd)/bootimg/AIK-Linux-2.7/ramdisk/ramdisk_fix_permissions.sh
#cd $(pwd)/bootimg/AIK-Linux-2.7/ramdisk
#chmod 0777 ramdisk_fix_permissions.sh
#./ramdisk_fix_permissions.sh 2>/dev/null
#rm -f ramdisk_fix_permissions.sh
#cd -

for i in $(pwd)/bootimg/AIK-Linux-2.7/repackimg.sh
do
"$i" &
done
wait
cp $(pwd)/bootimg/AIK-Linux-2.7/image-new.img $(pwd)/bootimg/zips/template/ram/boot.img

for i in $(pwd)/bootimg/AIK-Linux-2.7/cleanup.sh
do
"$i" &
done
wait
rm $(pwd)/bootimg/AIK-Linux-2.7/boot.img

mv $(pwd)/bootimg/zips/template/ram/system/lib/modules/placeholder $(pwd)/bootimg/
find ./ -name '*.ko' -exec cp '{}' "$(pwd)/bootimg/zips/template/ram/system/lib/modules" ";"

7z a -tzip -mx5 $(pwd)/bootimg/zips/RamKernel_$1$2_RC3_$selinux.zip $(pwd)/bootimg/zips/template/META-INF $(pwd)/bootimg/zips/template/ram
rm $(pwd)/bootimg/zips/template/ram/boot.img
rm $(pwd)/bootimg/zips/template/ram/system/lib/modules/*.*
mv $(pwd)/bootimg/placeholder $(pwd)/bootimg/zips/template/ram/system/lib/modules/
echo "$selinux zip made for $1$2"

#!/bin/sh

DEVICE="$1"
IMAGE="$2"

[ "$IMAGE" ] || exit 1

case "${DEVICE}" in
    "sdm845")
        VARIANTS="axolotl beryllium-tianma beryllium-ebbg enchilada fajita polaris"
        ;;
    "sm8450")
        VARIANTS="tabs8"
        ;;
    *)
        echo "ERROR: unsupported device ${DEVICE}"
        exit 1
        ;;
esac

for variant in ${VARIANTS}; do
    echo "Extracting boot image for variant ${variant}"
    mv "${ROOTDIR}/bootimg-${variant}" "${ARTIFACTDIR}/${IMAGE}.boot-${variant}.img"
done

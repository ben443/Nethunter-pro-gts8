#!/bin/sh

DEVICE="$1"

generate_bootimg() {
    ROOTDEV="$1"
    SOC="$2"
    VENDOR="$3"
    MODEL="$4"
    VARIANT="$5"

    CMDLINE="mobile.qcomsoc=${SOC} mobile.vendor=${VENDOR} mobile.model=${MODEL}"
    if [ "${VARIANT}" ]; then
        CMDLINE="${CMDLINE} mobile.variant=${VARIANT}"
        FULLMODEL="${MODEL}-${VARIANT}"
    else
        FULLMODEL="${MODEL}"
    fi

    # Workaround a bug in the SDHCI driver on SM7225
    if [ "${SOC}" = "qcom/sm8450" ]; then
        CMDLINE="${CMDLINE} sdhci.debug_quirks=0x40"
    fi

    # Append DTB to kernel
    echo "Creating boot image for ${FULLMODEL}..."
    cat /boot/vmlinuz-${KERNEL_VERSION} \
        /usr/lib/linux-image-${KERNEL_VERSION}/${SOC}-${VENDOR}-${FULLMODEL}.dtb > /tmp/kernel-dtb

    # Create the bootimg as it's the only format recognized by the Android bootloader
    abootimg --create /bootimg-${FULLMODEL} -c kerneladdr=0x8000 \
        -c ramdiskaddr=0x1000000 -c secondaddr=0x0 -c tagsaddr=0x100 -c pagesize=4096 \
        -c cmdline="mobile.root=${ROOTDEV} ${CMDLINE} init=/sbin/init ro quiet splash" \
        -k /tmp/kernel-dtb -r /boot/initrd.img-${KERNEL_VERSION}
}

ROOTPART="UUID=$(findmnt -n -o UUID /)"
if [ "${ROOTPART}" = "UUID=" ]; then
    # This means we're using an encrypted rootfs
    ROOTPART="/dev/mapper/root"
fi
KERNEL_VERSION=$(linux-version list)

case "${DEVICE}" in
    "sdm845")
        generate_bootimg "${ROOTPART}" "qcom/sdm845" "oneplus" "enchilada"
        generate_bootimg "${ROOTPART}" "qcom/sdm845" "oneplus" "fajita"
        generate_bootimg "${ROOTPART}" "qcom/sdm845" "shift" "axolotl"
        generate_bootimg "${ROOTPART}" "qcom/sdm845" "xiaomi" "beryllium" "tianma"
        generate_bootimg "${ROOTPART}" "qcom/sdm845" "xiaomi" "beryllium" "ebbg"
        generate_bootimg "${ROOTPART}" "qcom/sdm845" "xiaomi" "polaris"
        ;;
    "sm8450")
        generate_bootimg "${ROOTPART}" "qcom/sm8450" "samsung" "tabs8"
        ;;
    *)
        echo "ERROR: unsupported device ${DEVICE}"
        exit 1
        ;;
esac

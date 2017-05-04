#REMOVE_PACKAGES := \
#PRODUCT_PACKAGES := $(filter-out $(REMOVE_PACKAGES),$(PRODUCT_PACKAGES))

# OMS
#PRODUCT_PACKAGES += \
#    ThemeInterfacer \
#    Substratum

# File Manager
#PRODUCT_PACKAGES += \
#    Mixplorer

# Music Player
#PRODUCT_PACKAGES += \
#    Music

#PRODUCT_PACKAGES += \
#    ApolloMusic

# Magisk
#PRODUCT_PACKAGES += \
#    MagiskManager

#PRODUCT_COPY_FILES += \
#    vendor/extra/prebuilt/zip/magisk.zip:system/addon.d/magisk.zip

# phh's SuperUser
PRODUCT_PACKAGES += \
    SuperUser

PRODUCT_COPY_FILES += \
    vendor/extra/prebuilt/zip/superuser.zip:system/addon.d/superuser.zip

PRODUCT_COPY_FILES += \
   vendor/extra/prebuilt/zip/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
   vendor/extra/prebuilt/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

# su
#PRODUCT_PACKAGES += \
#    su

# bash
PRODUCT_COPY_FILES += \
    vendor/extra/prebuilt/xbin/bash:system/xbin/bash

# nano
PRODUCT_COPY_FILES += \
    vendor/extra/prebuilt/bin/nano:system/bin/nano \
    vendor/extra/prebuilt/bin/nano.bin:system/bin/nano.bin \
    vendor/extra/prebuilt/etc/terminfo/l/linux:system/etc/terminfo/l/linux

# init.d
PRODUCT_COPY_FILES += \
    vendor/extra/prebuilt/etc/init.d/20selinux:system/etc/init.d/20selinux \
    vendor/extra/prebuilt/etc/init.d/30dropbear:system/etc/init.d/30dropbear \
    vendor/extra/prebuilt/etc/init.d/80backup:system/etc/init.d/80backup

# OmniROM prop
#PRODUCT_COPY_FILES += \
#    vendor/extra/prebuilt/common/omnirom.prop:system/addon.d/omnirom.prop

# Selinux
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

#WITH_CM_CHARGER := true

# Custom off-mode charger
ifneq ($(WITH_CM_CHARGER),false)
PRODUCT_PACKAGES += \
    cm_charger_res_images \
    font_log.png \
    libhealthd.cm
endif

# Set cache location
ifeq ($(BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE),)
ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.device.cache_dir=/data/cache
else
ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.device.cache_dir=/cache
endif

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# Substratum Verified
#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.substratum.verified=true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.opa.eligible_device=true

# SD Clang version
ADDITIONAL_BUILD_PROPERTIES += \
    ro.sdc.version=$(SDCLANG_VERSION)

# Add our overlays
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/extra/overlay/common

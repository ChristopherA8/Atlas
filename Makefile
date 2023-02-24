TARGET := iphone:clang:14.5
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
export THEOS_DEVICE_IP=192.168.50.231

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Atlas

$(TWEAK_NAME)_FILES = $(wildcard *.xm *.m)
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
$(TWEAK_NAME)_FRAMEWORKS = AVFoundation
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += atlasprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

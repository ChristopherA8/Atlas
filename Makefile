TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YoutubePlayer

YoutubePlayer_FILES = $(wildcard *.xm *.m)
YoutubePlayer_FRAMEWORKS = AVFoundation
YoutubePlayer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

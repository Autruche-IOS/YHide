DEBUG=1
FINALPACKAGE=1
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTHide

YTHide_FILES = Tweak.xm
YTHide_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

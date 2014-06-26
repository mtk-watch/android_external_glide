LOCAL_PATH := $(my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(call all-java-files-under, library/src)
LOCAL_MANIFEST_FILE := library/AndroidManifest.xml

LOCAL_STATIC_JAVA_LIBRARIES := volley
LOCAL_STATIC_JAVA_LIBRARIES += libDiskLruCacheGlide

LOCAL_MODULE := glide
LOCAL_MODULE_TAGS := optional
LOCAL_SDK_VERSION := 19

include $(BUILD_STATIC_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_PREBUILT_STATIC_JAVA_LIBRARIES := \
  libDiskLruCacheGlide:library/libs/disklrucache-2.0.2.jar
include $(BUILD_MULTI_PREBUILT)

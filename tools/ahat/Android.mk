#
# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

include art/build/Android.common_path.mk

# --- ahat.jar ----------------
include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-java-files-under, src/main)
LOCAL_JAR_MANIFEST := etc/ahat.mf
LOCAL_JAVA_RESOURCE_FILES := $(LOCAL_PATH)/etc/style.css
LOCAL_JAVACFLAGS := -Xdoclint:all/protected
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := ahat

# Make this available on the classpath of the general-tests tradefed suite.
# It is used by libcore tests that run there.
LOCAL_COMPATIBILITY_SUITE := general-tests

include $(BUILD_HOST_JAVA_LIBRARY)
AHAT_JAR := $(LOCAL_BUILT_MODULE)

# --- api check for ahat.jar ----------
AHAT_API := $(INTERNAL_PLATFORM_AHAT_API_FILE)
AHAT_REMOVED_API := $(INTERNAL_PLATFORM_AHAT_REMOVED_API_FILE)

$(eval $(call check-api, \
  ahat-check-api, \
  $(LOCAL_PATH)/etc/ahat_api.txt, \
  $(AHAT_API), \
  $(LOCAL_PATH)/etc/ahat_removed_api.txt, \
  $(AHAT_REMOVED_API), \
  -error 2 -error 3 -error 4 -error 5 -error 6 -error 7 -error 8 -error 9 -error 10 -error 11 \
    -error 12 -error 13 -error 14 -error 15 -error 16 -error 17 -error 18 -error 19 -error 20 \
    -error 21 -error 23 -error 24 -error 25 -error 26 -error 27, \
  cat $(LOCAL_PATH)/etc/ahat_api_msg.txt, \
  $(AHAT_JAR),))

.PHONY: ahat-update-api
ahat-update-api: PRIVATE_AHAT_API := $(AHAT_API)
ahat-update-api: PRIVATE_AHAT_REMOVED_API := $(AHAT_REMOVED_API)
ahat-update-api: PRIVATE_AHAT_ETC_API := $(LOCAL_PATH)/etc/ahat_api.txt
ahat-update-api: PRIVATE_AHAT_ETC_REMOVED_API := $(LOCAL_PATH)/etc/ahat_removed_api.txt
ahat-update-api: ahat-docs
	@echo Copying ahat_api.txt
	cp $(PRIVATE_AHAT_API) $(PRIVATE_AHAT_ETC_API)
	@echo Copying ahat_removed_api.txt
	cp $(PRIVATE_AHAT_REMOVED_API) $(PRIVATE_AHAT_ETC_REMOVED_API)

# --- ahat script ----------------
include $(CLEAR_VARS)
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE := ahat
LOCAL_SRC_FILES := ahat
include $(BUILD_PREBUILT)

# The ahat tests rely on running ART to generate a heap dump for test, but ART
# doesn't run on darwin. Only build and run the tests for linux.
# There are also issues with running under instrumentation.
ifeq ($(HOST_OS),linux)
ifneq ($(EMMA_INSTRUMENT),true)
# --- ahat-test-dump.jar --------------
include $(CLEAR_VARS)
LOCAL_MODULE := ahat-test-dump
LOCAL_MODULE_TAGS := tests
LOCAL_SRC_FILES := $(call all-java-files-under, src/test-dump)
LOCAL_PROGUARD_ENABLED := obfuscation
LOCAL_PROGUARD_FLAG_FILES := etc/test-dump.pro
include $(BUILD_JAVA_LIBRARY)

# Determine the location of the test-dump.jar, test-dump.hprof, and proguard
# map files. These use variables set implicitly by the include of
# BUILD_JAVA_LIBRARY above.
AHAT_TEST_DUMP_JAR := $(LOCAL_BUILT_MODULE)
AHAT_TEST_DUMP_HPROF := $(intermediates.COMMON)/test-dump.hprof
AHAT_TEST_DUMP_BASE_HPROF := $(intermediates.COMMON)/test-dump-base.hprof
AHAT_TEST_DUMP_PROGUARD_MAP := $(intermediates.COMMON)/test-dump.map

# Directories to use for ANDROID_DATA when generating the test dumps to
# ensure we don't pollute the source tree with any artifacts from running
# dalvikvm.
AHAT_TEST_DUMP_ANDROID_DATA := $(intermediates.COMMON)/test-dump-android_data
AHAT_TEST_DUMP_BASE_ANDROID_DATA := $(intermediates.COMMON)/test-dump-base-android_data

# Generate the proguard map in the desired location by copying it from
# wherever the build system generates it by default.
$(AHAT_TEST_DUMP_PROGUARD_MAP): PRIVATE_AHAT_SOURCE_PROGUARD_MAP := $(proguard_dictionary)
$(AHAT_TEST_DUMP_PROGUARD_MAP): $(proguard_dictionary)
	cp $(PRIVATE_AHAT_SOURCE_PROGUARD_MAP) $@

# Run ahat-test-dump.jar to generate test-dump.hprof and test-dump-base.hprof
AHAT_TEST_DUMP_DEPENDENCIES := \
  $(HOST_OUT_EXECUTABLES)/dalvikvm64 \
  $(ART_HOST_SHARED_LIBRARY_DEBUG_DEPENDENCIES) \
  $(HOST_OUT_EXECUTABLES)/art \
  $(HOST_CORE_IMG_OUT_BASE)$(CORE_IMG_SUFFIX)

$(AHAT_TEST_DUMP_HPROF): PRIVATE_AHAT_TEST_ART := $(HOST_OUT_EXECUTABLES)/art
$(AHAT_TEST_DUMP_HPROF): PRIVATE_AHAT_TEST_DUMP_JAR := $(AHAT_TEST_DUMP_JAR)
$(AHAT_TEST_DUMP_HPROF): PRIVATE_AHAT_TEST_ANDROID_DATA := $(AHAT_TEST_DUMP_ANDROID_DATA)
$(AHAT_TEST_DUMP_HPROF): $(AHAT_TEST_DUMP_JAR) $(AHAT_TEST_DUMP_DEPENDENCIES)
	rm -rf $(PRIVATE_AHAT_TEST_ANDROID_DATA)
	mkdir -p $(PRIVATE_AHAT_TEST_ANDROID_DATA)
	ANDROID_DATA=$(PRIVATE_AHAT_TEST_ANDROID_DATA) \
	  $(PRIVATE_AHAT_TEST_ART) -d --64 -cp $(PRIVATE_AHAT_TEST_DUMP_JAR) Main $@

$(AHAT_TEST_DUMP_BASE_HPROF): PRIVATE_AHAT_TEST_ART := $(HOST_OUT_EXECUTABLES)/art
$(AHAT_TEST_DUMP_BASE_HPROF): PRIVATE_AHAT_TEST_DUMP_JAR := $(AHAT_TEST_DUMP_JAR)
$(AHAT_TEST_DUMP_BASE_HPROF): PRIVATE_AHAT_TEST_ANDROID_DATA := $(AHAT_TEST_DUMP_BASE_ANDROID_DATA)
$(AHAT_TEST_DUMP_BASE_HPROF): $(AHAT_TEST_DUMP_JAR) $(AHAT_TEST_DUMP_DEPENDENCIES)
	rm -rf $(PRIVATE_AHAT_TEST_ANDROID_DATA)
	mkdir -p $(PRIVATE_AHAT_TEST_ANDROID_DATA)
	ANDROID_DATA=$(PRIVATE_AHAT_TEST_ANDROID_DATA) \
	  $(PRIVATE_AHAT_TEST_ART) -d --64 -cp $(PRIVATE_AHAT_TEST_DUMP_JAR) Main $@ --base

# --- ahat-ri-test-dump.jar -------
include $(CLEAR_VARS)
LOCAL_MODULE := ahat-ri-test-dump
LOCAL_MODULE_TAGS := tests
LOCAL_SRC_FILES := $(call all-java-files-under, src/ri-test-dump)
LOCAL_IS_HOST_MODULE := true
include $(BUILD_HOST_JAVA_LIBRARY)

# Determine the location of the ri-test-dump.jar and ri-test-dump.hprof.
# These use variables set implicitly by the include of BUILD_JAVA_LIBRARY
# above.
AHAT_RI_TEST_DUMP_JAR := $(LOCAL_BUILT_MODULE)
AHAT_RI_TEST_DUMP_HPROF := $(intermediates.COMMON)/ri-test-dump.hprof

# Run ahat-ri-test-dump.jar to generate ri-test-dump.hprof
$(AHAT_RI_TEST_DUMP_HPROF): PRIVATE_AHAT_RI_TEST_DUMP_JAR := $(AHAT_RI_TEST_DUMP_JAR)
$(AHAT_RI_TEST_DUMP_HPROF): $(AHAT_RI_TEST_DUMP_JAR)
	rm -rf $@
	java -cp $(PRIVATE_AHAT_RI_TEST_DUMP_JAR) Main $@

# --- ahat-tests.jar --------------
# To run these tests, use: atest ahat-tests --host
include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-java-files-under, src/test)
LOCAL_JAR_MANIFEST := etc/ahat-tests.mf
LOCAL_JAVA_RESOURCE_FILES := \
  $(AHAT_TEST_DUMP_HPROF) \
  $(AHAT_TEST_DUMP_BASE_HPROF) \
  $(AHAT_TEST_DUMP_PROGUARD_MAP) \
  $(AHAT_RI_TEST_DUMP_HPROF) \
  $(LOCAL_PATH)/etc/L.hprof \
  $(LOCAL_PATH)/etc/O.hprof \
  $(LOCAL_PATH)/etc/RI.hprof
LOCAL_STATIC_JAVA_LIBRARIES := ahat junit-host
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := ahat-tests
LOCAL_TEST_CONFIG := ahat-tests.xml
LOCAL_COMPATIBILITY_SUITE := general-tests
include $(BUILD_HOST_JAVA_LIBRARY)
AHAT_TEST_JAR := $(LOCAL_BUILT_MODULE)

endif # EMMA_INSTRUMENT
endif # linux

# Clean up local variables.
AHAT_JAR :=
AHAT_API :=
AHAT_REMOVED_API :=
AHAT_TEST_JAR :=
AHAT_TEST_DUMP_JAR :=
AHAT_TEST_DUMP_HPROF :=
AHAT_TEST_DUMP_BASE_HPROF :=
AHAT_TEST_DUMP_PROGUARD_MAP :=
AHAT_TEST_DUMP_DEPENDENCIES :=
AHAT_TEST_DUMP_ANDROID_DATA :=
AHAT_TEST_DUMP_BASE_ANDROID_DATA :=


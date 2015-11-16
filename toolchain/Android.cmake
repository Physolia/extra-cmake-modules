#.rst:
# AndroidToolchain
# ----------------
#
# Enable easy compilation of cmake projects on Android.
#
# By using this android toolchain, the projects will be set up to compile the
# specified project targeting an Android platform, depending on its input.
# Furthermore, if desired, an APK can be directly generated by using the
# `androiddeployqt <http://doc.qt.io/qt-5/deployment-android.html>`_ tool.
#
# .. note::
#
#   This module requires CMake 3.1.
#
# Since 1.7.0.
#
# Usage
# =====
#
# To use this file, you need to set the ``CMAKE_TOOLCHAIN_FILE`` to point to
# ``AndroidToolchain.cmake`` on the command line::
#
#   cmake -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/AndroidToolchain.cmake
#
# You will also need to provide the locations of the Android NDK and SDK. This
# can be done on the commandline or with environment variables; in either case
# the variable names are:
#
# ``ANDROID_NDK``
#     The NSK root path.
# ``ANDROID_SDK_ROOT``
#     The SSK root path.
#
# Additional options are specified as cache variables (eg: on the command line):
#
# ``ANDROID_ARCHITECTURE``
#     The architecture to compile for. Default: ``arm``.
# ``ANDROID_TOOLCHAIN``
#     The toolchain to use. See the ``toolchains`` directory of the NDK.
#     Default: ``arm-linux-androideabi``.
# ``ANDROID_ABI``
#     The ABI to use. See the ``sources/cxx-stl/gnu-libstdc++/*/libs``
#     directories in the NDK. Default: ``armeabi-v7a``.
# ``ANDROID_GCC_VERSION``
#     The GCC version to use. Default: ``4.9``.
# ``ANDROID_API_LEVEL``
#     The `API level
#     <http://developer.android.com/guide/topics/manifest/uses-sdk-element.html>`_
#     to require. Default: ``14``.
# ``ANDROID_SDK_BUILD_TOOLS_REVISION``
#     The build tools version to use. Default: ``21.1.1``.
#
# Deploying Qt Applications
# =========================
#
# After building the application, you will need to generate an APK that can be
# deployed to an Android device. This module integrates androiddeployqt support
# to help with this for Qt-based projects. To enable this, set the
# ``QTANDROID_EXPORTED_TARGET`` variable to the target you wish to export as an
# APK, as well as ``ANDROID_APK_DIR`` to a directory containing some basic
# information. This will create a ``create-apk-<target>`` target that will
# generate the APK file.  See the `Qt on Android deployment documentation
# <http://doc.qt.io/qt-5/deployment-android.html>`_ for more information.
#
# For example, you could do::
#
#   cmake \
#     -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/AndroidToolchain.cmake \
#     -DQTANDROID_EXPORTED_TARGET=myapp \
#     -DANDROID_APK_DIR=myapp-apk
#   make
#   make create-apk-myapp
#
# The APK would then be found in ``myapp_build_apk/bin`` in the build directory.

# =============================================================================
# Copyright 2014 Aleix Pol i Gonzalez <aleixpol@kde.org>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file COPYING-CMAKE-SCRIPTS for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of extra-cmake-modules, substitute the full
#  License text for the above reference.)

cmake_minimum_required(VERSION "3.1")

#input
set(ANDROID_NDK "$ENV{ANDROID_NDK}" CACHE path "Android NDK path")
set(ANDROID_SDK_ROOT "$ENV{ANDROID_SDK_ROOT}" CACHE path "Android SDK path")
set(ANDROID_ARCHITECTURE "arm" CACHE string "Used Architecture, related to the ABI and TOOLCHAIN")
set(ANDROID_TOOLCHAIN "arm-linux-androideabi" CACHE string "Used SDK")
set(ANDROID_ABI "armeabi-v7a" CACHE string "Used ABI")
set(ANDROID_GCC_VERSION "4.9" CACHE string "Used GCC version" )
set(ANDROID_API_LEVEL "14" CACHE string "Android API Level")
set(ANDROID_SDK_BUILD_TOOLS_REVISION "21.1.1" CACHE string "Android API Level")

set(_HOST "${CMAKE_HOST_SYSTEM_NAME}-${CMAKE_HOST_SYSTEM_PROCESSOR}")
string(TOLOWER "${_HOST}" _HOST)

get_filename_component(_CMAKE_ANDROID_DIR "${CMAKE_TOOLCHAIN_FILE}" PATH)

cmake_policy(SET CMP0011 OLD)
cmake_policy(SET CMP0017 OLD)

set(CMAKE_SYSROOT
    "${ANDROID_NDK}/platforms/android-${ANDROID_API_LEVEL}/arch-${ANDROID_ARCHITECTURE}")
if(NOT EXISTS ${CMAKE_SYSROOT})
    message(FATAL_ERROR "Couldn't find the Android NDK Root in ${CMAKE_SYSROOT}")
endif()

#actual code
SET(CMAKE_SYSTEM_NAME Android)
SET(CMAKE_SYSTEM_VERSION 1)

set(ANDROID_TOOLCHAIN_ROOT "${ANDROID_NDK}/toolchains/${ANDROID_TOOLCHAIN}-${ANDROID_GCC_VERSION}/prebuilt/${_HOST}/bin")
set(ANDROID_LIBS_ROOT "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/${ANDROID_GCC_VERSION}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "${ANDROID_TOOLCHAIN_ROOT}")
set(ANDROID_LIBRARIES_PATH
    "${CMAKE_SYSROOT}/usr/lib")
set(CMAKE_SYSTEM_LIBRARY_PATH
    ${ANDROID_LIBRARIES_PATH}
    "${ANDROID_LIBS_ROOT}/libs/${ANDROID_ABI}/"
)
set(CMAKE_FIND_LIBRARY_SUFFIXES ".so")
set(CMAKE_FIND_LIBRARY_PREFIXES "lib")
find_library(GNUSTL_SHARED gnustl_shared)
if(NOT GNUSTL_SHARED)
    message(FATAL_ERROR "you need gnustl_shared: ${CMAKE_SYSTEM_LIBRARY_PATH}")
endif()
include_directories(SYSTEM
    "${CMAKE_SYSROOT}/usr/include"
    "${ANDROID_LIBS_ROOT}/include/"
    "${ANDROID_LIBS_ROOT}/libs/${ANDROID_ABI}/include"
)

# needed for Qt to define Q_OS_ANDROID
add_definitions(-DANDROID)

link_directories(${CMAKE_SYSTEM_LIBRARY_PATH})

set(CMAKE_C_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_TOOLCHAIN}-gcc")
set(CMAKE_CXX_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_TOOLCHAIN}-g++")

SET(CMAKE_FIND_ROOT_PATH ${ANDROID_NDK})
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_EXE_LINKER_FLAGS "${GNUSTL_SHARED} -Wl,-rpath-link,${ANDROID_LIBRARIES_PATH} -llog -lz -lm -ldl -lc -lgcc" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}" CACHE STRING "")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}" CACHE STRING "")

#we want executables to be shared libraries, hooks will invoke the exported cmake function
set(CMAKE_CXX_LINK_EXECUTABLE
    "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>"
)

######### generation

set(CREATEAPK_TARGET_NAME "create-apk-${QTANDROID_EXPORTED_TARGET}")
# Need to ensure we only get in here once, as this file is included twice:
# from CMakeDetermineSystem.cmake and from CMakeSystem.cmake generated within the
# build directory.
if(DEFINED QTANDROID_EXPORTED_TARGET AND NOT TARGET ${CREATEAPK_TARGET_NAME})
    if(NOT EXISTS "${ANDROID_APK_DIR}/AndroidManifest.xml")
        message(FATAL_ERROR "Define an apk dir to initialize from using -DANDROID_APK_DIR=<path>. The specified directory must contain the AndroidManifest.xml file.")
    endif()

    find_package(Qt5Core REQUIRED)

    set(EXPORT_DIR "${CMAKE_BINARY_DIR}/${QTANDROID_EXPORTED_TARGET}_build_apk/")
    set(EXECUTABLE_DESTINATION_PATH "${EXPORT_DIR}/libs/${ANDROID_ABI}/lib${QTANDROID_EXPORTED_TARGET}.so")
    configure_file("${_CMAKE_ANDROID_DIR}/deployment-file.json.in" "${QTANDROID_EXPORTED_TARGET}-deployment.json.in")

    add_custom_target(${CREATEAPK_TARGET_NAME}
        COMMAND cmake -E echo "Generating $<TARGET_NAME:${QTANDROID_EXPORTED_TARGET}> with $<TARGET_FILE_DIR:Qt5::qmake>/androiddeployqt"
        COMMAND cmake -E remove_directory "${EXPORT_DIR}"
        COMMAND cmake -E copy_directory "${ANDROID_APK_DIR}" "${EXPORT_DIR}"
        COMMAND cmake -E copy "$<TARGET_FILE:${QTANDROID_EXPORTED_TARGET}>" "${EXECUTABLE_DESTINATION_PATH}"
        COMMAND cmake -DINPUT_FILE="${QTANDROID_EXPORTED_TARGET}-deployment.json.in" -DOUTPUT_FILE="${QTANDROID_EXPORTED_TARGET}-deployment.json" "-DTARGET_DIR=$<TARGET_FILE_DIR:${QTANDROID_EXPORTED_TARGET}>" "-DTARGET_NAME=${QTANDROID_EXPORTED_TARGET}" -P ${_CMAKE_ANDROID_DIR}/specifydependencies.cmake
        COMMAND $<TARGET_FILE_DIR:Qt5::qmake>/androiddeployqt --input "${QTANDROID_EXPORTED_TARGET}-deployment.json" --output "${EXPORT_DIR}" --deployment bundled "\\$(ARGS)"
    )
else()
    message(STATUS "You can export a target by specifying -DQTANDROID_EXPORTED_TARGET=<targetname>")
endif()

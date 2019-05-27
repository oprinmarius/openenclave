# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#
# Set default paths
# TODO: See #757: Actually use GNUInstallDirs and don't hard-code our
# own paths.

# Set the default install prefix for Open Enclave. One may override this value
# with the cmake command. For example:
#
#     $ cmake -DCMAKE_INSTALL_PREFIX=/opt/myplace ..
#
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX
    "/opt/openenclave" CACHE PATH "default install prefix" FORCE)
endif()

include(GNUInstallDirs)
set(OE_OUTPUT_DIR ${PROJECT_BINARY_DIR}/output CACHE INTERNAL "Path to the intermittent collector tree")
set(OE_BINDIR ${OE_OUTPUT_DIR}/bin CACHE INTERNAL "Binary collector")
set(OE_DATADIR ${OE_OUTPUT_DIR}/share CACHE INTERNAL "Data collector root")
set(OE_DOCDIR ${OE_OUTPUT_DIR}/share/doc CACHE INTERNAL "Doc collector root")
set(OE_INCDIR ${OE_OUTPUT_DIR}/include CACHE INTERNAL "Include collector")
set(OE_LIBDIR ${OE_OUTPUT_DIR}/lib CACHE INTERNAL "Library collector")

# Make directories for build systems (NMake) that don't automatically make them.
file(MAKE_DIRECTORY ${OE_BINDIR} ${OE_DATADIR} ${OE_DOCDIR} ${OE_DOCDIR} ${OE_INCDIR} ${OE_LIBDIR})

# Generate and install CMake export file for consumers using CMake
include(CMakePackageConfigHelpers)
configure_package_config_file(
  ${PROJECT_SOURCE_DIR}/cmake/openenclave-config.cmake.in
  ${CMAKE_BINARY_DIR}/cmake/openenclave-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/openenclave/cmake
  PATH_VARS CMAKE_INSTALL_LIBDIR CMAKE_INSTALL_BINDIR CMAKE_INSTALL_DATADIR CMAKE_INSTALL_INCLUDEDIR)
write_basic_package_version_file(
  ${CMAKE_BINARY_DIR}/cmake/openenclave-config-version.cmake
  COMPATIBILITY SameMajorVersion)
install(
  FILES ${CMAKE_BINARY_DIR}/cmake/openenclave-config.cmake
  ${CMAKE_BINARY_DIR}/cmake/openenclave-config-version.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/openenclave/cmake)
install(
  EXPORT openenclave-targets
  NAMESPACE openenclave::
  # Note that this is used in `openenclaverc` to set the path for
  # users of the SDK and so must remain consistent.
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/openenclave/cmake
  FILE openenclave-targets.cmake)
install(
  FILES ${PROJECT_SOURCE_DIR}/cmake/sdk_cmake_targets_readme.md
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/openenclave/cmake
  RENAME README.md)

# CPack package handling
include(InstallRequiredSystemLibraries)
set(CPACK_PACKAGE_NAME "open-enclave")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Open Enclave SDK")
set(CPACK_PACKAGE_CONTACT "openenclave@microsoft.com")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VERSION ${OE_VERSION})
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libsgx-enclave-common (>=2.3.100.46354-1), libsgx-enclave-common-dev (>=2.3.100.0-1), libsgx-dcap-ql (>=1.0.100.46460-1.0), libsgx-dcap-ql-dev (>=1.0.100.46460-1.0), pkg-config")
include(CPack)

# Generate the openenclaverc script.
configure_file(
    ${PROJECT_SOURCE_DIR}/cmake/openenclaverc.in
    ${CMAKE_BINARY_DIR}/output/share/openenclave/openenclaverc
    @ONLY)

# Install the openenclaverc script.
install(FILES
    ${CMAKE_BINARY_DIR}/output/share/openenclave/openenclaverc
    DESTINATION
    "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/openenclave")


##==============================================================================
##
## Prefix where Open Enclave is installed.
##
##==============================================================================
if(DEFINED ENV{DESTDIR})
    MESSAGE(STATUS "DESTDIR env seen: --[$ENV{DESTDIR}]--")
    set(PREFIX "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}")
else()
    MESSAGE(STATUS "DESTDIR not defined")
    set(PREFIX "${CMAKE_INSTALL_PREFIX}")
endif()

##==============================================================================
##
## Enclave compiler flags:
##
##==============================================================================

set(ENCLAVE_CINCLUDES
    "-I\${includedir}/openenclave/3rdparty/libc -I\${includedir}/openenclave/3rdparty -I\${includedir}")

set(ENCLAVE_CXXINCLUDES
    "-I\${includedir}/openenclave/3rdparty/libcxx ${ENCLAVE_CINCLUDES}")

set(ENCLAVE_CFLAGS_LIST
  -nostdinc
  -m64
  -fPIE
  -ftls-model=local-exec
  -fvisibility=hidden
  -fno-stack-protector)

set(ENCLAVE_CFLAGS_CLANG_LIST ${ENCLAVE_CFLAGS_LIST} ${SPECTRE_MITIGATION_FLAGS})
list(JOIN ENCLAVE_CFLAGS_CLANG_LIST " " ENCLAVE_CFLAGS_CLANG)

list(JOIN ENCLAVE_CFLAGS_LIST " " ENCLAVE_CFLAGS_GCC)

##==============================================================================
##
## Enclave linker flags:
##
##==============================================================================

set(ENCLAVE_CLIBS_1
  -nostdlib
  -nodefaultlibs
  -nostartfiles
  -Wl,--no-undefined
  -Wl,-Bstatic
  -Wl,-Bsymbolic
  -Wl,--export-dynamic
  -Wl,-pie
  -Wl,--build-id
  -Wl,-z,noexecstack
  -Wl,-z,now
  -L\${libdir}/openenclave/enclave
  -loeenclave
  -lmbedx509
  -lmbedcrypto)

set(ENCLAVE_CLIBS_2 -loelibc -loecore)

set(ENCLAVE_CLIBS_LIST ${ENCLAVE_CLIBS_1} ${ENCLAVE_CLIBS_2})
list(JOIN ENCLAVE_CLIBS_LIST " " ENCLAVE_CLIBS)

set(ENCLAVE_CXXLIBS_LIST ${ENCLAVE_CLIBS_1} -loelibcxx ${ENCLAVE_CLIBS_2})
list(JOIN ENCLAVE_CXXLIBS_LIST " " ENCLAVE_CXXLIBS)

##==============================================================================
##
## Host compiler flags:
##
##==============================================================================

set(HOST_INCLUDES "-I\${includedir}")

set(HOST_CFLAGS_CLANG_LIST -fstack-protector-strong ${SPECTRE_MITIGATION_FLAGS})
list(JOIN HOST_CFLAGS_CLANG_LIST " " HOST_CFLAGS_CLANG)

set(HOST_CXXFLAGS_CLANG ${HOST_CFLAGS_CLANG})

set(HOST_CFLAGS_GCC_LIST -fstack-protector-strong -D_FORTIFY_SOURCE=2)
list(JOIN HOST_CFLAGS_GCC_LIST " " HOST_CFLAGS_GCC)

set(HOST_CXXFLAGS_GCC ${HOST_CFLAGS_GCC})

##==============================================================================
##
## Host linker flags:
##
##==============================================================================

if(USE_LIBSGX)
    set(SGX_LIBS "-lsgx_enclave_common -lsgx_dcap_ql -lsgx_urts")
else()
    set(SGX_LIBS "")
endif()

set(HOST_CLIBS "-rdynamic -Wl,-z,noexecstack -L\${libdir}/openenclave/host -loehost -ldl -lpthread ${SGX_LIBS}")

set(HOST_CXXLIBS "${HOST_CLIBS}")

##==============================================================================
##
## oeenclave-gcc.pc:
##
##==============================================================================

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/oeenclave-gcc.pc.in
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oeenclave-gcc.pc
    @ONLY)

install(FILES
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oeenclave-gcc.pc
    DESTINATION
    "${CMAKE_INSTALL_DATADIR}/pkgconfig")

##==============================================================================
##
## oeenclave-g++.pc:
##
##==============================================================================

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/oeenclave-g++.pc.in
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oeenclave-g++.pc
    @ONLY)

install(FILES
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oeenclave-g++.pc
    DESTINATION
    "${CMAKE_INSTALL_DATADIR}/pkgconfig")

##==============================================================================
##
## oehost-gcc.pc:
##
##==============================================================================

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/oehost-gcc.pc.in
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oehost-gcc.pc
    @ONLY)

install(FILES
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oehost-gcc.pc
    DESTINATION
    "${CMAKE_INSTALL_DATADIR}/pkgconfig")

##==============================================================================
##
## oehost-g++.pc:
##
##==============================================================================

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/oehost-g++.pc.in
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oehost-g++.pc
    @ONLY)

install(FILES
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oehost-g++.pc
    DESTINATION
    "${CMAKE_INSTALL_DATADIR}/pkgconfig")

##==============================================================================
##
## oeenclave-clang.pc:
##
##==============================================================================

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/oeenclave-clang.pc.in
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oeenclave-clang.pc
    @ONLY)

install(FILES
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oeenclave-clang.pc
    DESTINATION
    "${CMAKE_INSTALL_DATADIR}/pkgconfig")

##==============================================================================
##
## oeenclave-clang++.pc:
##
##==============================================================================

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/oeenclave-clang++.pc.in
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oeenclave-clang++.pc
    @ONLY)

install(FILES
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oeenclave-clang++.pc
    DESTINATION
    "${CMAKE_INSTALL_DATADIR}/pkgconfig")

##==============================================================================
##
## oehost-clang.pc:
##
##==============================================================================

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/oehost-clang.pc.in
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oehost-clang.pc
    @ONLY)

install(FILES
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oehost-clang.pc
    DESTINATION
    "${CMAKE_INSTALL_DATADIR}/pkgconfig")

##==============================================================================
##
## oehost-clang++.pc:
##
##==============================================================================

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/oehost-clang++.pc.in
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oehost-clang++.pc
    @ONLY)

install(FILES
    ${CMAKE_BINARY_DIR}/output/share/pkgconfig/oehost-clang++.pc
    DESTINATION
    "${CMAKE_INSTALL_DATADIR}/pkgconfig")

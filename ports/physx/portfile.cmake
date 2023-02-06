vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA-Omniverse/PhysX
    REF 4d33492253ab64c2246d80257ac4ce0f37b40b22
    SHA512 8893d68dedf32f83d1292145a9c650e96b88d44f582df1447b40fccaeaf9361d4f74c0a42629a4c424c4c4dd73d9175be3cbcf8a44e877133425e3fc76aaa4c1
    HEAD_REF release/104.1
    PATCHES patch.patch
)

vcpkg_download_distfile(
    PHYSX_CMAKEMODULES_FILE
    URLS https://d4i3qtqj3r0z5.cloudfront.net/CMakeModules%401.28.trunk.31965103.7z
    FILENAME "CMakeModules@1.28.trunk.31965103.7z"
    SHA512 fa0ddfafe6e877183048c664860e6dccfcd85c30be23eebad99ec23994a6e10530b69a81db11d45671f6ada800776db22db63df6f3945d2cbf5b86640803e476
)

vcpkg_extract_source_archive(
    PHYSX_CMAKEMODULES
    ARCHIVE "${PHYSX_CMAKEMODULES_FILE}"
    NO_REMOVE_ONE_LEVEL
)

vcpkg_download_distfile(
    PHYSX_PHYSXGPU_FILE
    URLS https://d4i3qtqj3r0z5.cloudfront.net/PhysXGpu%40104.1-5.1.1253.32184287-public.zip
    FILENAME "PhysXGpu@104.1-5.1.1253.32184287-public.zip"
    SHA512 096b67a1946d9d83486353bdd6a66559b9a632ba509240622d61035abbd6bf5690d669c69629b7025d5a2db5377c3e92b038ca4d4ef5b1c434b5a95b6081773c
)

vcpkg_extract_source_archive(
    PHYSX_PHYSXGPU
    ARCHIVE "${PHYSX_PHYSXGPU_FILE}"
    NO_REMOVE_ONE_LEVEL
)

vcpkg_download_distfile(
    PHYSX_PHYSXDEVICE_FILE
    URLS https://d4i3qtqj3r0z5.cloudfront.net/PhysXDevice%4018.12.7.3.7z
    FILENAME "PhysXDevice@18.12.7.3.7z"
    SHA512 801e6b64d16fde8d885c7b94e923710c701a83f0f0fa9c8452c44fb1f8fc121b63df73f2e345b682ae59d26953311f39976bc4eefab77c922170b5994773e6b9
)

vcpkg_extract_source_archive(
    PHYSX_PHYSXDEVICE
    ARCHIVE "${PHYSX_PHYSXDEVICE_FILE}"
    NO_REMOVE_ONE_LEVEL
)

if(NOT DEFINED RELEASE_CONFIGURATION)
    set(RELEASE_CONFIGURATION "release")
endif()
set(DEBUG_CONFIGURATION "debug")

set(OPTIONS
    "-DPHYSX_ROOT_DIR=${SOURCE_PATH}/physx"
    "-DCMAKEMODULES_PATH=${PHYSX_CMAKEMODULES}"
    "-DPX_BUILDPVDRUNTIME=ON"
    "-DPX_BUILDSNIPPETS=OFF"
    "-DPHYSX_PHYSXDEVICE_PATH=${PHYSX_PHYSXDEVICE}/bin/x86"
    "-DPHYSX_PHYSXGPU_PATH=${PHYSX_PHYSXGPU}/bin"
    "-DPX_FLOAT_POINT_PRECISE_MATH=OFF"
)

set(OPTIONS_RELEASE
    "-DPX_OUTPUT_BIN_DIR=${CURRENT_PACKAGES_DIR}"
    "-DPX_OUTPUT_LIB_DIR=${CURRENT_PACKAGES_DIR}"
)
set(OPTIONS_DEBUG
    "-DPX_OUTPUT_BIN_DIR=${CURRENT_PACKAGES_DIR}/debug"
    "-DPX_OUTPUT_LIB_DIR=${CURRENT_PACKAGES_DIR}/debug"
    "-DNV_USE_DEBUG_WINCRT=ON"
)

if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=uwp")
    set(configure_options WINDOWS_USE_MSBUILD)
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=windows")
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=mac")
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_FREEBSD)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=linux")
elseif(VCPKG_TARGET_IS_ANDROID)
    list(APPEND OPTIONS "-DTARGET_BUILD_PLATFORM=android")
else()
    message(FATAL_ERROR "Unhandled or unsupported target platform.")
endif()

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    list(APPEND OPTIONS "-DNV_FORCE_64BIT_SUFFIX=ON" "-DNV_FORCE_32BIT_SUFFIX=OFF")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "-DPX_GENERATE_STATIC_LIBRARIES=OFF")
else()
    list(APPEND OPTIONS "-DPX_GENERATE_STATIC_LIBRARIES=ON")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "-DNV_USE_STATIC_WINCRT=OFF")
else()
    list(APPEND OPTIONS "-DNV_USE_STATIC_WINCRT=ON")
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    list(APPEND OPTIONS "-DPX_OUTPUT_ARCH=arm")
else()
    list(APPEND OPTIONS "-DPX_OUTPUT_ARCH=x86")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/physx/compiler/public"
    ${configure_options}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
)
vcpkg_cmake_install()

# NVIDIA Gameworks release structure is generally something like <compiler>/<configuration>/[artifact]
# It would be nice to patch this out, but that directory structure is hardcoded over many cmake files.
# So, we have this helpful helper to copy the bins and libs out.
function(fixup_physx_artifacts)
    macro(_fixup _IN_DIRECTORY _OUT_DIRECTORY)
        foreach(_SUFFIX IN LISTS _fpa_SUFFIXES)
            file(GLOB_RECURSE _ARTIFACTS
                LIST_DIRECTORIES false
                "${CURRENT_PACKAGES_DIR}/${_IN_DIRECTORY}/*${_SUFFIX}"
            )
            if(_ARTIFACTS)
                file(COPY ${_ARTIFACTS} DESTINATION "${CURRENT_PACKAGES_DIR}/${_OUT_DIRECTORY}")
            endif()
        endforeach()
    endmacro()

    cmake_parse_arguments(_fpa "" "DIRECTORY" "SUFFIXES" ${ARGN})
    _fixup("bin" ${_fpa_DIRECTORY})
    _fixup("debug/bin" "debug/${_fpa_DIRECTORY}")
endfunction()

fixup_physx_artifacts(
    DIRECTORY "lib"
    SUFFIXES ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}
)
fixup_physx_artifacts(
    DIRECTORY "bin"
    SUFFIXES ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX} ".pdb"
)

# Remove compiler directory and descendents.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin/"
        "${CURRENT_PACKAGES_DIR}/debug/bin/"
    )
else()
    file(GLOB PHYSX_ARTIFACTS LIST_DIRECTORIES true
        "${CURRENT_PACKAGES_DIR}/bin/*"
        "${CURRENT_PACKAGES_DIR}/debug/bin/*"
    )
    foreach(_ARTIFACT IN LISTS PHYSX_ARTIFACTS)
        if(IS_DIRECTORY ${_ARTIFACT})
            file(REMOVE_RECURSE ${_ARTIFACT})
        endif()
    endforeach()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/source"
    "${CURRENT_PACKAGES_DIR}/source"
)
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

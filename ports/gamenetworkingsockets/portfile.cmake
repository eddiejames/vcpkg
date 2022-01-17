vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF 617672707c2c2c46562bc1152262d4cf383cdc0c
    SHA512 ef692ef9a4949703ddf75ebda8861956f0564375a3f0e4d2adf6b727ed475f964db214fef914acaebbbf9d42b4847fbf0029ef14c9ac3a40b31be5e47c5f2f3d
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "webrtc"    USE_STEAMWEBRTC
)

if (USE_STEAMWEBRTC)
    vcpkg_from_git(
        OUT_SOURCE_PATH WEBRTC_SOURCE_PATH
        URL https://webrtc.googlesource.com/src
        REF 30a3e787948dd6cdd541773101d664b85eb332a6
        HEAD_REF MAIN
    )

    if (NOT EXISTS "${SOURCE_PATH}/src/external/webrtc/rtc_base")
        file(REMOVE_RECURSE "${SOURCE_PATH}/src/external/webrtc")
        file(RENAME "${WEBRTC_SOURCE_PATH}" "${SOURCE_PATH}/src/external/webrtc")
    endif()
endif()

set(CRYPTO_BACKEND OpenSSL)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_CRT_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DUSE_CRYPTO=${CRYPTO_BACKEND}
        -DUSE_CRYPTO25519=${CRYPTO_BACKEND}
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
        -DBUILD_SHARED_LIB=${BUILD_SHARED_LIB}
        -DMSVC_CRT_STATIC=${MSVC_CRT_STATIC}
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        MSVC_CRT_STATIC
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/GameNetworkingSockets" TARGET_PATH "share/GameNetworkingSockets")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

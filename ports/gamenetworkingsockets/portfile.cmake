vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF 35106a6e1a1d7d496b4fbd1bf31f4e1a670d7831 # v1.4.1
    SHA512 5f8016397210f8035cbe52d9db339d43f006f5d37fbe64641279efa3a140e57bb5300c9b0251c5455ff9c1e658531c50a299d1832c7b0d9aba3eb1819409a948
    HEAD_REF master
)

vcpkg_from_git(
    OUT_SOURCE_PATH WEBRTC_SOURCE_PATH
    URL https://webrtc.googlesource.com/src
    REF 30a3e787948dd6cdd541773101d664b85eb332a6
    HEAD_REF MAIN
    PATCHES 0001-no-inttypes.patch
)

if (NOT EXISTS "${SOURCE_PATH}/src/external/webrtc/rtc_base")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/external/webrtc")
    file(RENAME "${WEBRTC_SOURCE_PATH}" "${SOURCE_PATH}/src/external/webrtc")
endif()

set(CRYPTO_BACKEND OpenSSL)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_CRT_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TOOLS=OFF
        -DUSE_CRYPTO=${CRYPTO_BACKEND}
        -DUSE_CRYPTO25519=${CRYPTO_BACKEND}
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
        -DBUILD_SHARED_LIB=${BUILD_SHARED_LIB}
        -DMSVC_CRT_STATIC=${MSVC_CRT_STATIC}
        -DUSE_STEAMWEBRTC=ON
    MAYBE_UNUSED_VARIABLES
        MSVC_CRT_STATIC
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/GameNetworkingSockets")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

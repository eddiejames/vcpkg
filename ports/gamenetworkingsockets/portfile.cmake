vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF 517f463d2992478e3b588b259321889c64ea2deb # v1.4.0
    SHA512 3f3845d78aee2e5a6e40b41baf1a8d19be4fd0251d6468cdc7aa33eb02a304a8c1ad20fd860ea49b5195948f6e45f3a572f099f4945a9fadfc4eda47bd8c08f0
    HEAD_REF master
)

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
        -DBUILD_TOOLS=OFF
		-DENABLE_ICE=ON
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

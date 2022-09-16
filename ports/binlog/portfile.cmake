vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO morganstanley/binlog
    REF 5467217310eb0c43452bbd810d3f093e6eb737d9 # 2021-04-16
    SHA512 d99c932eddee0109c8184714b05bd9f6397dff013828b287a76affa5dc2db8d5570b6e805697019bf59756f6a2d05a62e9456dd4b7d3f0831e7f8308be1ca733
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/binlog")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")

vcpkg_copy_pdbs()

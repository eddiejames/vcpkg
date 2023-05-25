vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO guillaumeblanc/ozz-animation
    REF ed38a6a89a5d95d4c6df26afe79abe91688aadbe
    SHA512 cd473bf74d2ec78502455d43bce9011604164f4b6ad99c7148d6b71832723b4fc3d328326f2ea75923e81cc7f81fbbaedfd1d6d34a76120ee693c198bce2cc87
    HEAD_REF 0.14.1
	PATCHES 0001-remove-DESTINATION-lib-from-library-install-commands.patch
)

set(OPTIONS
    "-Dozz_build_tools=OFF"
	"-Dozz_build_fbx=OFF"
	"-Dozz_build_samples=OFF"
	"-Dozz_build_howtos=OFF"
	"-Dozz_build_tests=OFF"
	"-Dozz_build_postfix=OFF"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "-DBUILD_SHARED_LIBS=ON")
else()
    list(APPEND OPTIONS "-DBUILD_SHARED_LIBS=OFF")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "-Dozz_build_msvc_rt_dll=ON")
else()
    list(APPEND OPTIONS "-Dozz_build_msvc_rt_dll=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(REMOVE "${CURRENT_PACKAGES_DIR}/CHANGES.md")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.md")
file(REMOVE "${CURRENT_PACKAGES_DIR}/README.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/CHANGES.md")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE.md")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/README.md")

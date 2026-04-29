function(setup_pypi CONFIG)
    string(REPLACE "-" "_" PYPI_MODULE_NAME "${CMAKE_PROJECT_NAME}")
    string(SUBSTRING "${CMAKE_PROJECT_NAME}" 4 -1 TARGET)

    set(PYPI_STAGE_DIR "${CMAKE_BINARY_DIR}/ffi/python")
    set(PYPI_MODULE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/ffi/python/${PYPI_MODULE_NAME}")
    set(PYPI_PYTHON_BIN "python3")
    set(PYPI_AUDITWHEEL_BIN "auditwheel")

    set(PYPI_PYPROJECT_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/pyproject.toml.config")
    set(PYPI_PYPROJECT_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/pyproject.toml")
    set(PYPI_PACKAGE_DATA "\"$<TARGET_FILE_NAME:${TARGET}-c-api>\"")

    set(PY_FFI_MODULE_NAME "${PYPI_MODULE_NAME}")
    set(PY_FFI_PACKAGE_DATA "${PYPI_PACKAGE_DATA}")

    configure_file("${CONFIG}" "${PYPI_PYPROJECT_CONFIG}" @ONLY)
    file(GENERATE OUTPUT "${PYPI_PYPROJECT_OUTPUT}" INPUT "${PYPI_PYPROJECT_CONFIG}")

    add_custom_target(
        ffi-python-stage
        COMMAND ${CMAKE_COMMAND} -E rm -rf "${PYPI_STAGE_DIR}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PYPI_STAGE_DIR}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PYPI_STAGE_DIR}/${PYPI_MODULE_NAME}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/src/ffi/python/README.md" "${PYPI_STAGE_DIR}/README.md"
        COMMAND ${CMAKE_COMMAND} -E copy "${PYPI_PYPROJECT_OUTPUT}" "${PYPI_STAGE_DIR}/pyproject.toml"
        COMMAND ${CMAKE_COMMAND} -E copy "${PYPI_MODULE_FILE}.py" "${PYPI_STAGE_DIR}/${PYPI_MODULE_NAME}/__init__.py"
        COMMAND ${CMAKE_COMMAND} -E copy "${PYPI_MODULE_FILE}.pyi" "${PYPI_STAGE_DIR}/${PYPI_MODULE_NAME}/__init__.pyi"
        COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:${TARGET}-c-api>" "${PYPI_STAGE_DIR}/${PYPI_MODULE_NAME}/$<TARGET_FILE_NAME:${TARGET}-c-api>"
        COMMAND ${CMAKE_COMMAND} -E chdir "${PYPI_STAGE_DIR}" "${PYPI_PYTHON_BIN}" -m build --wheel
        COMMAND ${CMAKE_COMMAND} -E chdir "${PYPI_STAGE_DIR}" /bin/bash -lc "${PYPI_AUDITWHEEL_BIN} repair dist/*.whl --wheel-dir dist/"
        DEPENDS ${TARGET}-c-api
        COMMENT "Stage Python FFI package for wheel build"
    )

    add_custom_target(
        ffi-python-upload
        COMMAND ${CMAKE_COMMAND} -E chdir "${PYPI_STAGE_DIR}" /bin/bash -lc "${PYPI_PYTHON_BIN} -m twine upload dist/*.whl"
        DEPENDS ffi-python-stage
        COMMENT "Upload Python FFI wheels to PyPI"
    )
endfunction()
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

add_executable(props_host host.c)
target_link_libraries(props_host oehostapp)
target_compile_options(props_host PRIVATE -Wconversion -Wpointer-arith)

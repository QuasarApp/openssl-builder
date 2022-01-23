#
# Copyright (C) 2021-2022 QuasarApp.
# Distributed under the lgplv3 software license, see the accompanying
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.
#

if(DEFINED SLLBUILDER_LIBRARY)
  return()
endif()

project(SLLBUILDER_LIBRARY)

if(TARGET ${PROJECT_NAME})
  message("The ${PROJECT_NAME} arledy included in main Project")
  return()
endif()

cmake_minimum_required(VERSION 3.12)

file(GLOB SOURCE
    LIST_DIRECTORIES False
    RELATIVE ${CMAKE_SOURCE_DIR}/
    "*"
)

add_custom_target(${PROJECT_NAME} SOURCES ${SOURCE})

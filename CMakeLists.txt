cmake_minimum_required(VERSION 3.5)

set(CMAKE_BUILD_TYPE Release)
list(APPEND CMAKE_PREFIX_PATH "~/out")
set(CMAKE_CXX_STANDARD 20)
project(hello LANGUAGES CXX)

find_package(aws-lambda-runtime REQUIRED)
add_executable(${PROJECT_NAME} "./src/main.cpp")
target_link_libraries(${PROJECT_NAME} PUBLIC AWS::aws-lambda-runtime)
aws_lambda_package_target(${PROJECT_NAME})

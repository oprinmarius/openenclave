def ACClibcxxTest(String label, String compiler, String build_type) {
    stage("libcxx ${label} SGX1FLC ${compiler} ${build_type}") {
        node("${label}") {
            cleanWs()
            checkout scm

            timeout(180) {
                def c_compiler
                def cpp_compiler
                if (compiler == "gcc") {
                    c_compiler = "gcc"
                    cpp_compiler = "g++"
                } else if (compiler == "clang-7") {
                    c_compiler = "clang-7"
                    cpp_compiler = "clang++-7"
                }
                dir('build'){
                    withEnv(["CC=${c_compiler}","CXX=${cpp_compiler}"]) {
                        sh """
                        CMAKE="cmake .. -DCMAKE_BUILD_TYPE=${build_type} -DUSE_LIBSGX=1 -DENABLE_FULL_LIBCXX_TESTS=1"
                        if ! \${CMAKE}; then
                            echo ""
                            echo "cmake failed for SGX1FLC"
                            echo ""
                            exit 1
                        fi
                        if ! make; then
                            echo ""
                            echo "Build failed for SGX1FLC"
                            echo ""
                            exit 1
                        fi
                        if ! ctest --output-on-failure; then
                            echo ""
                            echo "Test failed for SGX1FLC ${build_type} in ${label} hardware mode"
                            echo ""
                            exit 1
                        fi
                        """
                    }
                }
            }
        }
    }
}

def Win2016CrossPlatformlibcxxTest(String build_type) {
    stage("Linux SGX1 ${build_type}") {
        node {
            cleanWs()
            checkout scm
            def oetoolsWincp = docker.build("oetools-wincp", "-f .jenkins/Dockerfile .")
            oetoolsWincp.inside {
                timeout(180) {
                  dir('build') {
                      withEnv(["CC=clang-7","CXX=clang++-7"]) {
                        sh """
                        CMAKE="cmake .. -DCMAKE_BUILD_TYPE=${build_type} -DUSE_LIBSGX=1 -DENABLE_FULL_LIBCXX_TESTS=1"
                        if ! \${CMAKE}; then
                            echo ""
                            echo "cmake failed for SGX1FLC"
                            echo ""
                            exit 1
                        fi
                        if ! make; then
                            echo ""
                            echo "Build failed for SGX1FLC"
                            echo ""
                            exit 1
                        fi
                        if ! ctest --output-on-failure; then
                            echo ""
                            echo "Test failed for SGX1FLC ${build_type} in Windows CrossPlatform mode"
                            echo ""
                            exit 1
                        fi
                        """
                        stash includes: 'build/tests/**', name: "libclinux${build_type}"
                    }
                  }
              }
            }
        }
    }
    stage("Windows ${build_type}") {
        node('SGXFLC-Windows') {
            cleanWs()
            checkout scm
            unstash "libclinux${build_type}"
            powershell "mv build linuxbin"
            timeout(180) {
                dir('build') {
                    powershell """
                    \$ErrorActionPreference = "Stop"
                    . $WORKSPACE\\scripts\\ci-helpers.ps1
                    Set-VCVariables

                    cmake.exe -G "Visual Studio 15 2017 Win64"  -DADD_WINDOWS_ENCLAVE_TESTS=1 -DLINUX_BIN_DIR="$WORKSPACE/linuxbin/tests" -DENABLE_FULL_LIBCXX_TESTS=1 ..
                    cmake.exe --build . --config ${build_type}
                    ctest -V -C ${build_type}
                    """
                }
            }
       }
    }
}

def Win2016libcxxTest(String build_type) {
  stage("Windows ${build_type}") {
      node('SGXFLC-Windows') {
          cleanWs()
          checkout scm
          timeout(180) {
              dir('build') {
                  powershell """
                  \$ErrorActionPreference = "Stop"
                  . $WORKSPACE\\scripts\\ci-helpers.ps1

                  Set-VCVariables
                  cmake.exe -G "NMake Makefiles" -DBUILD_ENCLAVES=1 -DADD_WINDOWS_ENCLAVE_TESTS=1 -DENABLE_FULL_LIBCXX_TESTS=1 ..
                  cmake.exe --build . --config ${build_type}
                  ctest -V -C ${build_type}
                  """
              }
          }
      }
  }
}

parallel "libcxx ACC1604 clang-7 Debug" :          { ACClibcxxTest('ACC-1604', 'clang-7', 'Debug') },
         "libcxx ACC1604 clang-7 Release" :        { ACClibcxxTest('ACC-1604', 'clang-7','Release') },
         "libcxx ACC1604 clang-7 RelWithDebInfo" : { ACClibcxxTest('ACC-1604', 'clang-7', 'RelWithDebinfo') },
         "libcxx ACC1604 gcc Debug" :              { ACClibcxxTest('ACC-1604', 'gcc', 'Debug') },
         "libcxx ACC1604 gcc Release" :            { ACClibcxxTest('ACC-1604', 'gcc', 'Release') },
         "libcxx ACC1604 gcc RelWithDebInfo" :     { ACClibcxxTest('ACC-1604', 'gcc', 'RelWithDebInfo') },
         "libcxx ACC1804 clang-7 Debug" :          { ACClibcxxTest('ACC-1804', 'clang-7', 'Debug') },
         "libcxx ACC1804 clang-7 Release" :        { ACClibcxxTest('ACC-1804', 'clang-7', 'Release') },
         "libcxx ACC1804 clang-7 RelWithDebInfo" : { ACClibcxxTest('ACC-1804', 'clang-7', 'RelWithDebinfo') },
         "libcxx ACC1804 gcc Debug" :              { ACClibcxxTest('ACC-1804', 'gcc', 'Debug') },
         "libcxx ACC1804 gcc Release" :            { ACClibcxxTest('ACC-1804', 'gcc', 'Release') },
         "libcxx ACC1804 gcc RelWithDebInfo" :     { ACClibcxxTest('ACC-1804', 'gcc', 'RelWithDebinfo') },
         "libcxx Win2016 Debug" :                  { Win2016libcxxTest('Debug') },
         "libcxx Win2016 Release" :                { Win2016libcxxTest('Release') },
         "libcxx Win2016 Cross-Platform Debug" :   { Win2016CrossPlatformlibcxxTest('Debug') },
         "libcxx Win2016 Cross-Platform Release" : { Win2016CrossPlatformlibcxxTest('Release') }

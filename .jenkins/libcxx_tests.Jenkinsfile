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
         "libcxx ACC1804 gcc RelWithDebInfo" :     { ACClibcxxTest('ACC-1804', 'gcc', 'RelWithDebinfo') }

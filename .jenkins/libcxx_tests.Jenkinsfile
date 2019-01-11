def ACClibcxxTest(String label, String compiler, String suite) {
    stage("libcxx $label SGX1FLC $compiler $suite") {
        node("$label") {
            cleanWs()
            checkout scm

            timeout(180) {
                sh "./scripts/test-build-config -p SGX1FLC -b $suite -d --enable_full_libcxx_tests --compiler=$compiler"
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

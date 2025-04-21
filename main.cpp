#include <cstdio>

#include "rsp_parser.hpp"

int main() {
  //RspParser parser("test_vectors/gcmDecrypt256.rsp");
  RspParser parser("../test_vectors/gcmDecryptTest.rsp");
  parser.print_tests();

  return 0;
}

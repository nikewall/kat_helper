#include <fstream>

#include "rsp_parser.hpp"

RspParser::RspParser(const std::string& filename) {
  // begin file
  printf("opening %s\n", filename.c_str());
  std::ifstream file(filename, std::ifstream::in);

  std::string currline;
  // discard all lines until first [Keylen = *]
  do {
    std::getline(file, currline);
  } while(currline.find("Keylen = ") == std::string::npos);


  // capture test info
  // [Keylen = *]
  // [IVlen = *]
  // [PTlen = *]
  // [AADlen = *]
  // [Taglen = *]
  size_t begin = currline.find(" = ") + 3;
  test_info[0] = currline.substr(begin); // Keylen = ###
  test_info[0].erase(test_info[0].size()-2); // trim \n and ']'
  printf("KEYLEN = %s\n", test_info[0].c_str());

  for (int i = 0; i < 4; i++) { // others
    printf("i = %d\n", i);
    std::getline(file, test_info[i]);

    begin = test_info[i].find(" = ") + 3;
    test_info[i] = test_info[i].substr(begin);
    test_info[i].erase(test_info[i].size()-2); // trim \n and ']'

    printf("%s\n", test_info[i].c_str());
  }

  // test case:
  // <BEGIN>
  // newline
  // Count =
  // Keylen =
  // IVlen =
  // PTlen =
  // AADlen =
  // Taglen =
  // if passing, "PT = *"
  // if failing, "FAIL"
  // <END>

  // 1. get rid of newline
}


void RspParser::print_tests() {
  return;
}

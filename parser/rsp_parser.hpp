#include <cstdint>

#include <string>
#include <array>

struct TestCase {
    uint8_t* key;
    uint8_t* iv;
    uint8_t* input;
    uint8_t* aad;
    uint8_t* tag;
};

class RspParser {
  public:
    RspParser(const std::string& filename);
    void print_tests();
  private:
    std::array<std::string, 5> test_info;
};

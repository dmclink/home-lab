#include <thread>
#include <chrono>

int main() {
    while (true) {
        std::this_thread::sleep_for(std::chrono::hours(24));
    }
    return 0;
}

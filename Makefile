CXX = g++
CXXFLAGS = -std=c++17 -O3 -march=native -flto -pthread -DNDEBUG
LDFLAGS = -pthread

TARGET = subdomain_checker_cpp
SOURCE = subdomain_checker.cpp

.PHONY: all clean test benchmark

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCE) $(LDFLAGS)

clean:
	rm -f $(TARGET)

test: $(TARGET)
	./$(TARGET) subdomains.txt

benchmark: $(TARGET)
	time ./$(TARGET) subdomains.txt

help:
	@echo "� C++ Ultra-Fast Subdomain Checker"
	@echo "=================================="
	@echo "Available targets:"
	@echo "  all       - Build the C++ ultra-fast subdomain checker"
	@echo "  clean     - Remove compiled binary"
	@echo "  test      - Run scan on subdomains.txt"
	@echo "  benchmark - Run with timing"
	@echo ""
	@echo "🚀 C++ Stable optimizations:"
	@echo "  - O3 + march=native + LTO optimizations"
	@echo "  - curl + nslookup (stable, no dependencies)"
	@echo "  - 50 concurrent threads (stable)"
	@echo "  - 3s timeout per request"
	@echo "  - Advanced DNS/CNAME + Header CDN detection"

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <thread>
#include <mutex>
#include <atomic>
#include <chrono>
#include <algorithm>
#include <iomanip>
#include <sstream>
#include <cstdlib>
#include <cstring>
#include <future>
#include <map>

struct Result {
    std::string url;
    int status_code;
    std::string cdn;
    std::string server;
    double response_time;
    bool is_working;
    
    Result() : status_code(0), response_time(0.0), is_working(false) {}
};

class ProgressTracker {
private:
    std::atomic<int> total_{0};
    std::atomic<int> processed_{0};
    std::atomic<int> working_{0};
    std::chrono::steady_clock::time_point start_time_;
    std::mutex display_mutex_;

public:
    ProgressTracker() : start_time_(std::chrono::steady_clock::now()) {}
    
    void set_total(int total) { total_ = total; }
    
    void update(bool is_working) {
        processed_++;
        if (is_working) working_++;
        
        if (processed_ % 10 == 0) {
            display_progress();
        }
    }
    
    void display_progress() {
        std::lock_guard<std::mutex> lock(display_mutex_);
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - start_time_).count();
        
        double percent = (double)processed_ / (total_ * 2) * 100.0;
        int eta = elapsed > 0 ? (int)((total_ * 2 - processed_) * elapsed / processed_) : 0;
        
        std::cout << "\r🚀 C++ Stable: " << processed_ << "/" << (total_ * 2) 
                  << " (" << std::fixed << std::setprecision(1) << percent << "%) | "
                  << "Working: " << working_ << " | "
                  << "Elapsed: " << elapsed << "s | "
                  << "ETA: " << eta << "s          " << std::flush;
    }
    
    void final_summary(double total_time) {
        std::cout << "\n\n📊 C++ ULTRA-FAST SUMMARY\n========================\n";
        std::cout << "⏱️  Total scan time: " << std::fixed << std::setprecision(1) << total_time << "s\n";
        std::cout << "✅ Working hosts: " << working_ << "\n";
        std::cout << "📈 Processed: " << processed_ << " requests\n";
        std::cout << "🚀 Speed: " << (double)processed_ / total_time << " requests/second\n\n";
    }
};

// Fast CDN detection using external tools
std::string detect_cdn_from_dns(const std::string& hostname) {
    std::string command = "nslookup " + hostname + " 2>/dev/null | grep -i canonical";
    FILE* pipe = popen(command.c_str(), "r");
    if (!pipe) return "";
    
    char buffer[256];
    std::string result;
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        result += buffer;
    }
    pclose(pipe);
    
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    
    if (result.find("akamaiedge.net") != std::string::npos ||
        result.find("edgekey.net") != std::string::npos ||
        result.find("akamai.net") != std::string::npos) {
        return "Akamai";
    }
    
    if (result.find("cloudflare.net") != std::string::npos ||
        result.find("cloudflare.com") != std::string::npos) {
        return "CloudFlare";
    }
    
    if (result.find("cloudfront.net") != std::string::npos ||
        result.find("amazonaws.com") != std::string::npos) {
        return "AWS CloudFront";
    }
    
    if (result.find("fastly.com") != std::string::npos ||
        result.find("fastlylb.net") != std::string::npos) {
        return "Fastly";
    }
    
    if (result.find("ves.io") != std::string::npos ||
        result.find("volterra.io") != std::string::npos) {
        return "F5/Volterra";
    }
    
    if (result.find("azureedge.net") != std::string::npos) {
        return "Azure CDN";
    }
    
    if (result.find("googleapis.com") != std::string::npos ||
        result.find("googleusercontent.com") != std::string::npos) {
        return "Google Cloud CDN";
    }
    
    if (result.find("bunnycdn.com") != std::string::npos ||
        result.find("b-cdn.net") != std::string::npos) {
        return "BunnyCDN";
    }
    
    return "";
}

// Fast HTTP check using curl
Result check_url(const std::string& hostname, const std::string& scheme) {
    Result result;
    result.url = scheme + "://" + hostname;
    
    auto start_time = std::chrono::steady_clock::now();
    
    std::string command = "curl -s -I --max-time 3 --connect-timeout 2 '" + result.url + "' 2>/dev/null";
    FILE* pipe = popen(command.c_str(), "r");
    
    if (!pipe) {
        return result;
    }
    
    char buffer[256];
    std::string response;
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        response += buffer;
    }
    pclose(pipe);
    
    auto end_time = std::chrono::steady_clock::now();
    result.response_time = std::chrono::duration<double>(end_time - start_time).count();
    
    if (!response.empty()) {
        // Extract status code
        size_t status_pos = response.find("HTTP/");
        if (status_pos != std::string::npos) {
            size_t code_start = response.find(" ", status_pos) + 1;
            size_t code_end = response.find(" ", code_start);
            if (code_end != std::string::npos) {
                std::string status_str = response.substr(code_start, code_end - code_start);
                try {
                    result.status_code = std::stoi(status_str);
                } catch (...) {
                    result.status_code = 0;
                }
            }
        }
        
        // Extract server
        size_t server_pos = response.find("Server: ");
        if (server_pos == std::string::npos) {
            server_pos = response.find("server: ");
        }
        if (server_pos != std::string::npos) {
            size_t start = server_pos + 8;
            size_t end = response.find("\r\n", start);
            if (end != std::string::npos) {
                result.server = response.substr(start, end - start);
            }
        }
        
        // CDN Detection: DNS first, then headers
        result.cdn = detect_cdn_from_dns(hostname);
        if (result.cdn.empty()) {
            std::string lower_response = response;
            std::transform(lower_response.begin(), lower_response.end(), lower_response.begin(), ::tolower);
            
            if (lower_response.find("cf-ray:") != std::string::npos ||
                lower_response.find("cloudflare") != std::string::npos) {
                result.cdn = "CloudFlare";
            } else if (lower_response.find("x-amz-cf-id:") != std::string::npos ||
                       lower_response.find("cloudfront") != std::string::npos) {
                result.cdn = "AWS CloudFront";
            } else if (lower_response.find("akamai") != std::string::npos) {
                result.cdn = "Akamai";
            } else if (lower_response.find("fastly") != std::string::npos) {
                result.cdn = "Fastly";
            } else if (lower_response.find("volterra") != std::string::npos ||
                       lower_response.find("volt-adc") != std::string::npos) {
                result.cdn = "F5/Volterra";
            } else if (lower_response.find("azure") != std::string::npos) {
                result.cdn = "Azure CDN";
            } else if (lower_response.find("gws") != std::string::npos ||
                       lower_response.find("x-google-cache:") != std::string::npos) {
                result.cdn = "Google Cloud CDN";
            } else {
                result.cdn = "Direct";
            }
        }
        
        result.is_working = (result.status_code >= 200 && result.status_code < 500);
    }
    
    return result;
}

// Worker function for processing hosts
void process_hosts(const std::vector<std::string>& hostnames, int start_idx, int end_idx,
                   std::vector<Result>& results, std::mutex& results_mutex,
                   ProgressTracker& progress) {
    
    for (int i = start_idx; i < end_idx; ++i) {
        if (i >= hostnames.size()) break;
        
        const std::string& hostname = hostnames[i];
        
        // Check both HTTP and HTTPS
        for (const std::string& scheme : {"http", "https"}) {
            Result result = check_url(hostname, scheme);
            
            {
                std::lock_guard<std::mutex> lock(results_mutex);
                results.push_back(result);
            }
            
            progress.update(result.is_working);
        }
    }
}

// Save results to file
void save_results(const std::vector<Result>& results) {
    std::ofstream file("working_hosts.txt");
    
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    
    file << "# Working hosts found on " << std::put_time(std::localtime(&time_t), "%Y-%m-%d %H:%M:%S") << "\n";
    file << "# Format: URL [STATUS] [CDN] (SERVER) (TIME)\n";
    file << "# CDN Detection: DNS/CNAME + HTTP Headers (C++ Stable + curl)\n\n";
    
    // Group by CDN
    std::map<std::string, std::vector<Result>> cdn_groups;
    
    for (const auto& result : results) {
        if (result.is_working) {
            cdn_groups[result.cdn].push_back(result);
        }
    }
    
    // Sort CDNs
    std::vector<std::string> cdn_order = {"CloudFlare", "AWS CloudFront", "Akamai", "Fastly", 
                                         "F5/Volterra", "Azure CDN", "Google Cloud CDN", 
                                         "BunnyCDN", "Direct"};
    
    for (const std::string& cdn : cdn_order) {
        if (cdn_groups.find(cdn) != cdn_groups.end()) {
            file << "# CDN: " << cdn << "\n";
            
            for (const auto& result : cdn_groups[cdn]) {
                std::string status_icon = (result.status_code >= 200 && result.status_code < 300) ? "✅" :
                                        (result.status_code >= 400 && result.status_code < 500) ? "🔒" : "⚠️";
                
                file << result.url << " [" << result.status_code << "] [" << result.cdn;
                if (!result.server.empty()) {
                    file << " - " << result.server;
                }
                file << "] (" << std::fixed << std::setprecision(2) << result.response_time << "s)\n";
            }
            file << "\n";
        }
    }
    
    file.close();
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <subdomains_file>\n";
        return 1;
    }
    
    std::cout << "🚀 STABLE C++ Subdomain Checker (curl + Advanced CDN Detection)\n";
    std::cout << "==============================================================\n";
    
    // Read subdomains
    std::ifstream file(argv[1]);
    if (!file.is_open()) {
        std::cerr << "❌ Cannot open file: " << argv[1] << "\n";
        return 1;
    }
    
    std::vector<std::string> hostnames;
    std::string line;
    
    while (std::getline(file, line)) {
        if (!line.empty() && line[0] != '#') {
            hostnames.push_back(line);
        }
    }
    file.close();
    
    int total_hosts = hostnames.size();
    std::cout << "📋 Subdomains to check: " << total_hosts << "\n";
    std::cout << "⚡ Workers: 50 | Timeout: 3s | curl + nslookup | Stable\n";
    std::cout << "🔍 CDN Detection: DNS/CNAME + Headers (CloudFlare, AWS, Akamai, Fastly, Azure, Google, F5, etc.)\n";
    std::cout << "🚀 Starting stable scan...\n\n";
    
    ProgressTracker progress;
    progress.set_total(total_hosts);
    
    std::vector<Result> results;
    std::mutex results_mutex;
    
    auto start_time = std::chrono::steady_clock::now();
    
    // Create 50 worker threads for stability
    std::vector<std::thread> workers;
    const int num_workers = 50;
    int hosts_per_worker = total_hosts / num_workers;
    
    for (int i = 0; i < num_workers; ++i) {
        int start_idx = i * hosts_per_worker;
        int end_idx = (i == num_workers - 1) ? total_hosts : (i + 1) * hosts_per_worker;
        
        workers.emplace_back(process_hosts, std::ref(hostnames), start_idx, end_idx,
                           std::ref(results), std::ref(results_mutex), std::ref(progress));
    }
    
    // Join all threads
    for (auto& worker : workers) {
        worker.join();
    }
    
    auto end_time = std::chrono::steady_clock::now();
    double total_time = std::chrono::duration<double>(end_time - start_time).count();
    
    progress.final_summary(total_time);
    
    // Save results
    save_results(results);
    
    // Count working hosts
    int working_count = 0;
    std::map<std::string, int> cdn_counts;
    
    for (const auto& result : results) {
        if (result.is_working) {
            working_count++;
            cdn_counts[result.cdn]++;
        }
    }
    
    std::cout << "🌐 CDN Distribution:\n";
    for (const auto& pair : cdn_counts) {
        std::cout << "   " << pair.first << ": " << pair.second << " hosts\n";
    }
    
    std::cout << "💾 Saved " << working_count << " working hosts to working_hosts.txt\n\n";
    std::cout << "✅ STABLE C++ scan completed! " << total_time << "s total time\n";
    std::cout << "🚀 Performance: " << (double)(total_hosts * 2) / total_time << " requests per second!\n";
    
    return 0;
}

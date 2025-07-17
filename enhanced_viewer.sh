#!/bin/bash

# Enhanced Results Viewer with Colored Output
# Provides a better visual experience for subdomain checker results

echo "🎨 Enhanced Subdomain Checker Results Viewer"
echo "============================================="

if [ ! -f "working_hosts.txt" ]; then
    echo "❌ working_hosts.txt not found!"
    echo "Run ./subdomain_checker first to generate the results."
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo ""
echo -e "${WHITE}📊 RESULTS SUMMARY${NC}"
echo "=================="

# Count different status codes
count_200=$(grep "\[200\]" working_hosts.txt | wc -l)
count_403=$(grep "\[403\]" working_hosts.txt | wc -l)
count_405=$(grep "\[405\]" working_hosts.txt | wc -l)
count_404=$(grep "\[404\]" working_hosts.txt | wc -l)
count_500=$(grep "\[50[0-9]\]" working_hosts.txt | wc -l)
total_hosts=$(grep -v "^#" working_hosts.txt | grep -v "^$" | wc -l)

echo -e "${GREEN}✅ 200 OK: $count_200 hosts${NC}"
echo -e "${YELLOW}🔒 403 Forbidden: $count_403 hosts${NC}"
echo -e "${YELLOW}⚠️  405 Method Not Allowed: $count_405 hosts${NC}"
echo -e "${RED}❌ 404 Not Found: $count_404 hosts${NC}"
echo -e "${RED}💥 5xx Server Errors: $count_500 hosts${NC}"
echo -e "${WHITE}📈 Total Working: $total_hosts hosts${NC}"

echo ""
echo -e "${WHITE}🚀 FASTEST RESPONDING HOSTS (Top 10)${NC}"
echo "====================================="
grep -v "^#" working_hosts.txt | sort -t'(' -k2 -n | head -10 | while IFS= read -r line; do
    if [[ $line == *"[200]"* ]]; then
        echo -e "${GREEN}$line${NC}"
    elif [[ $line == *"[403]"* ]]; then
        echo -e "${YELLOW}$line${NC}"
    else
        echo -e "${CYAN}$line${NC}"
    fi
done

echo ""
echo -e "${WHITE}⏰ SLOWEST RESPONDING HOSTS (Top 5)${NC}"
echo "==================================="
grep -v "^#" working_hosts.txt | sort -t'(' -k2 -nr | head -5 | while IFS= read -r line; do
    echo -e "${RED}$line${NC}"
done

echo ""
echo -e "${WHITE}🎯 HIGH-VALUE TARGETS (200 OK)${NC}"
echo "==============================="
grep "\[200\]" working_hosts.txt | while IFS= read -r line; do
    echo -e "${GREEN}$line${NC}"
done

echo ""
echo -e "${WHITE}🔐 PROTECTED RESOURCES (403 Forbidden)${NC}"
echo "========================================="
grep "\[403\]" working_hosts.txt | while IFS= read -r line; do
    echo -e "${YELLOW}$line${NC}"
done

echo ""
echo -e "${WHITE}🌐 SERVER ANALYSIS${NC}"
echo "=================="

# Analyze server types
echo -e "${CYAN}volt-adc servers:${NC}"
grep "volt-adc" working_hosts.txt | wc -l | xargs echo -n && echo " hosts"

echo -e "${CYAN}Unknown/Direct servers:${NC}"
grep "Unknown/Direct" working_hosts.txt | wc -l | xargs echo -n && echo " hosts"

echo -e "${CYAN}Other servers:${NC}"
grep -v "volt-adc" working_hosts.txt | grep -v "Unknown/Direct" | grep -v "^#" | wc -l | xargs echo -n && echo " hosts"

echo ""
echo -e "${WHITE}📈 PERFORMANCE METRICS${NC}"
echo "======================"

# Calculate average response time
total_time=0
count=0
grep -o "([0-9]*\.[0-9]*s)" working_hosts.txt | while read time; do
    time_val=$(echo $time | sed 's/[()]//g' | sed 's/s//')
    total_time=$(echo "$total_time + $time_val" | bc)
    count=$((count + 1))
    if [ $count -gt 0 ]; then
        avg=$(echo "scale=2; $total_time / $count" | bc)
        echo "Average response time: ${avg}s" > temp_avg.txt
    fi
done

if [ -f temp_avg.txt ]; then
    cat temp_avg.txt
    rm temp_avg.txt
fi

# Response time categories
fast_hosts=$(grep -E "\([0-5]\.[0-9]*s\)" working_hosts.txt | wc -l)
medium_hosts=$(grep -E "\([5-9]\.[0-9]*s\)" working_hosts.txt | wc -l)
slow_hosts=$(grep -E "\(1[0-9]\.[0-9]*s\)" working_hosts.txt | wc -l)

echo -e "${GREEN}Fast (0-5s): $fast_hosts hosts${NC}"
echo -e "${YELLOW}Medium (5-10s): $medium_hosts hosts${NC}"
echo -e "${RED}Slow (10s+): $slow_hosts hosts${NC}"

echo ""
echo -e "${WHITE}💡 RECOMMENDATIONS${NC}"
echo "==================="
echo -e "${GREEN}• Focus on 200 OK hosts for further testing${NC}"
echo -e "${YELLOW}• 403 hosts might have interesting endpoints${NC}"
echo -e "${CYAN}• Fast-responding hosts are good for automation${NC}"
echo -e "${PURPLE}• volt-adc seems to be the main server infrastructure${NC}"

echo ""
echo -e "${WHITE}📁 Generated Files:${NC}"
echo "   📄 working_hosts.txt - All working hosts"
echo "   📄 cdn_analysis.txt - CDN breakdown"
echo "   📄 cdn_hosts_only.txt - CDN-powered hosts only"
echo "   📄 high_value_targets.txt - High-value targets"

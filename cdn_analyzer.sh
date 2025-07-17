#!/bin/bash

# CDN Highlighter Script
# Highlights hosts using major CDNs from working_hosts.txt

echo "🌐 CDN-Powered Hosts Analyzer"
echo "============================="

if [ ! -f "working_hosts.txt" ]; then
    echo "❌ working_hosts.txt not found!"
    echo "Run ./subdomain_checker first to generate the results."
    exit 1
fi

# Create separate files for each CDN
echo "🔍 Analyzing CDN usage from working_hosts.txt..."
echo ""

# CloudFlare hosts
echo "☁️  CLOUDFLARE HOSTS:" > cdn_analysis.txt
echo "===================" >> cdn_analysis.txt
grep -i "cloudflare\|cf-ray" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

cloudflare_count=$(grep -i "cloudflare\|cf-ray" working_hosts.txt | wc -l)

# AWS CloudFront hosts
echo "🚀 AWS CLOUDFRONT HOSTS:" >> cdn_analysis.txt
echo "========================" >> cdn_analysis.txt
grep -i "cloudfront\|amazonaws" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

cloudfront_count=$(grep -i "cloudfront\|amazonaws" working_hosts.txt | wc -l)

# Fastly hosts
echo "⚡ FASTLY CDN HOSTS:" >> cdn_analysis.txt
echo "===================" >> cdn_analysis.txt
grep -i "fastly" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

fastly_count=$(grep -i "fastly" working_hosts.txt | wc -l)

# Akamai hosts
echo "🔶 AKAMAI HOSTS:" >> cdn_analysis.txt
echo "===============" >> cdn_analysis.txt
grep -i "akamai" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

akamai_count=$(grep -i "akamai" working_hosts.txt | wc -l)

# BunnyCDN hosts
echo "🐰 BUNNYCDN HOSTS:" >> cdn_analysis.txt
echo "==================" >> cdn_analysis.txt
grep -i "bunny\|bunnycdn" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

bunny_count=$(grep -i "bunny\|bunnycdn" working_hosts.txt | wc -l)

# Microsoft Azure CDN hosts
echo "🔷 MICROSOFT AZURE CDN HOSTS:" >> cdn_analysis.txt
echo "==============================" >> cdn_analysis.txt
grep -i "azure\|microsoft" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

azure_count=$(grep -i "azure\|microsoft" working_hosts.txt | wc -l)

# Alibaba Cloud CDN hosts
echo "🟠 ALIBABA CLOUD CDN HOSTS:" >> cdn_analysis.txt
echo "============================" >> cdn_analysis.txt
grep -i "alibaba\|aliyun" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

alibaba_count=$(grep -i "alibaba\|aliyun" working_hosts.txt | wc -l)

# Google Cloud CDN hosts
echo "🔴 GOOGLE CLOUD CDN HOSTS:" >> cdn_analysis.txt
echo "===========================" >> cdn_analysis.txt
grep -i "google\|gcp" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

google_count=$(grep -i "google\|gcp" working_hosts.txt | wc -l)

# KeyCDN, MaxCDN, Incapsula, Sucuri
echo "🔧 OTHER CDN HOSTS:" >> cdn_analysis.txt
echo "===================" >> cdn_analysis.txt
grep -iE "keycdn|maxcdn|stackpath|incapsula|sucuri" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

other_count=$(grep -iE "keycdn|maxcdn|stackpath|incapsula|sucuri" working_hosts.txt | wc -l)

# Direct/Unknown hosts (not using major CDNs)
echo "🏠 DIRECT/UNKNOWN HOSTS:" >> cdn_analysis.txt
echo "=========================" >> cdn_analysis.txt
grep "Unknown/Direct" working_hosts.txt >> cdn_analysis.txt || echo "None found" >> cdn_analysis.txt

direct_count=$(grep "Unknown/Direct" working_hosts.txt | wc -l)

# Summary
total_hosts=$(grep -v "^#" working_hosts.txt | grep -v "^$" | wc -l)

echo "📊 CDN DISTRIBUTION SUMMARY:" >> cdn_analysis.txt
echo "=============================" >> cdn_analysis.txt
echo "Total working hosts: $total_hosts" >> cdn_analysis.txt
echo "CloudFlare: $cloudflare_count hosts" >> cdn_analysis.txt
echo "AWS CloudFront: $cloudfront_count hosts" >> cdn_analysis.txt
echo "Fastly: $fastly_count hosts" >> cdn_analysis.txt
echo "Akamai: $akamai_count hosts" >> cdn_analysis.txt
echo "BunnyCDN: $bunny_count hosts" >> cdn_analysis.txt
echo "Microsoft Azure: $azure_count hosts" >> cdn_analysis.txt
echo "Alibaba Cloud: $alibaba_count hosts" >> cdn_analysis.txt
echo "Google Cloud: $google_count hosts" >> cdn_analysis.txt
echo "Other CDNs: $other_count hosts" >> cdn_analysis.txt
echo "Direct/Unknown: $direct_count hosts" >> cdn_analysis.txt
echo "" >> cdn_analysis.txt

cdn_total=$((cloudflare_count + cloudfront_count + fastly_count + akamai_count + bunny_count + azure_count + alibaba_count + google_count + other_count))
echo "Total CDN-powered hosts: $cdn_total" >> cdn_analysis.txt
echo "Direct hosts: $direct_count" >> cdn_analysis.txt

if [ $total_hosts -gt 0 ]; then
    cdn_percentage=$(echo "scale=1; $cdn_total * 100 / $total_hosts" | bc)
    echo "CDN usage: ${cdn_percentage}%" >> cdn_analysis.txt
fi

# Display results
cat cdn_analysis.txt

echo ""
echo "📄 Detailed analysis saved to: cdn_analysis.txt"

# Create a quick CDN-only file
echo "🎯 Creating CDN-only hosts file..."
echo "# CDN-Powered Hosts Only" > cdn_hosts_only.txt
echo "# Extracted from working_hosts.txt on $(date)" >> cdn_hosts_only.txt
echo "" >> cdn_hosts_only.txt

grep -v "Unknown/Direct" working_hosts.txt | grep -v "^#" >> cdn_hosts_only.txt

cdn_only_count=$(grep -v "Unknown/Direct" working_hosts.txt | grep -v "^#" | wc -l)
echo "📄 CDN-only hosts saved to: cdn_hosts_only.txt ($cdn_only_count hosts)"

# Create high-value target file (CDN + 200 status)
echo "🎯 Creating high-value targets file..."
echo "# High-Value Targets (CDN + 200 OK)" > high_value_targets.txt
echo "# These hosts are CDN-powered and responding with 200 OK" >> high_value_targets.txt
echo "" >> high_value_targets.txt

grep -v "Unknown/Direct" working_hosts.txt | grep "\[200\]" >> high_value_targets.txt

high_value_count=$(grep -v "Unknown/Direct" working_hosts.txt | grep "\[200\]" | wc -l)
echo "📄 High-value targets saved to: high_value_targets.txt ($high_value_count hosts)"

echo ""
echo "✅ Analysis complete!"
echo "   📄 cdn_analysis.txt - Full CDN breakdown"
echo "   📄 cdn_hosts_only.txt - CDN-powered hosts only"
echo "   📄 high_value_targets.txt - CDN + 200 OK hosts"

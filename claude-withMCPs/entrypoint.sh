#!/bin/bash
# Entrypoint script that sets up iptables rules to restrict network access
# Allows connections only to domains specified in allowed-domains.txt

# Enable strict error handling
set -e

# Function to resolve domain to IPs and add iptables rules
add_domain_rules() {
    local domain=$1
    echo "  Adding rules for: $domain"
    
    # Resolve domain to IP addresses
    local ips=$(getent hosts "$domain" 2>/dev/null | awk '{print $1}' | sort -u)
    
    if [ -z "$ips" ]; then
        echo "    ⚠️  Warning: Could not resolve $domain"
        # Still add the domain name rule (iptables will try to resolve it)
        iptables -A OUTPUT -p tcp --dport 443 -d "$domain" -j ACCEPT
        iptables -A INPUT -p tcp --sport 443 -s "$domain" -j ACCEPT
    else
        # Add rules for each resolved IP
        for ip in $ips; do
            echo "    Resolved to IP: $ip"
            iptables -A OUTPUT -p tcp --dport 443 -d "$ip" -j ACCEPT
            iptables -A INPUT -p tcp --sport 443 -s "$ip" -j ACCEPT
        done
    fi
}

# Function to setup firewall rules
setup_firewall() {
    echo "🔒 Setting up network restrictions..."
    
    # Allow loopback
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    
    # Allow DNS resolution (needed to resolve domains)
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
    iptables -A INPUT -p udp --sport 53 -j ACCEPT
    iptables -A INPUT -p tcp --sport 53 -j ACCEPT
    
    # Process allowed domains from config file
    if [ -f /app/tools/allowed-domains.txt ]; then
        echo "📋 Processing allowed domains from config..."
        while IFS= read -r line; do
            # Skip empty lines and comments
            if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
                # Trim whitespace
                domain=$(echo "$line" | xargs)
                if [ -n "$domain" ]; then
                    add_domain_rules "$domain"
                fi
            fi
        done < /app/tools/allowed-domains.txt
    else
        echo "⚠️  No allowed-domains.txt found, using defaults only"
        # Default to Anthropic endpoints only
        add_domain_rules "api.anthropic.com"
        add_domain_rules "claude.ai"
    fi
    
    # Allow established connections
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Drop everything else
    iptables -P OUTPUT DROP
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    
    echo "✅ Network restrictions applied successfully"
    echo "📝 Allowed domains:"
    if [ -f /app/tools/allowed-domains.txt ]; then
        grep -v '^#' /app/tools/allowed-domains.txt | grep -v '^$' | sed 's/^/    - /'
    fi
}

# Check if we should apply network restrictions
if [ "$APPLY_NETWORK_RESTRICTIONS" = "true" ]; then
    setup_firewall
fi

# Execute the main command
exec "$@"
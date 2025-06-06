

////////////////////////////////////////////////////////[ SSM AUTOMATION ]////////////////////////////////////////////////
# # ---------------------------------------------------------------------------------------------------------------------#
# Create SSM document association with EC2 NAT tag
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_ssm_association" "nat_setup" {
  name = aws_ssm_document.nat_setup.name
  targets {
    key    = "tag:EC2NAT"
    values = ["true"]
  }
  document_version    = "$LATEST"
  compliance_severity = "HIGH"
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create SSM document to configure EC2 NAT
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_ssm_document" "nat_setup" {
  name            = "EC2NATSetup"
  document_type   = "Command"
  document_format = "YAML"
  lifecycle {
    ignore_changes = [content]
  }
  content = <<-END
    schemaVersion: '2.2'
    description: Configure EC2 instance as NAT
    mainSteps:
      - action: aws:runShellScript
        name: ConfigureEC2NAT
        inputs:
          runCommand:
            - |
              #!/bin/bash
              set -euo pipefail
              export DEBIAN_FRONTEND=noninteractive
              apt-get update -qq
              apt-get install -yqq syslog-ng iptraf-ng nftables iproute2 curl
              INTERFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)
              echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-nat.conf
              sysctl --system
              for file in /proc/sys/net/ipv4/conf/*/rp_filter; do
                echo 0 > "$file"
              done
              cat <<EONFT > /etc/nftables.conf
              table ip nat {
                chain prerouting {
                  type nat hook prerouting priority 0;
                }
                chain postrouting {
                  type nat hook postrouting priority 100;
                  oifname "$INTERFACE" masquerade;
                }
              }
              table inet filter {
                chain input {
                  type filter hook input priority 0; policy accept;
                }
                chain forward {
                  type filter hook forward priority 0; policy accept;
                }
                chain output {
                  type filter hook output priority 0; policy accept;
                }
              }
              EONFT
              systemctl enable --now nftables
              nft -f /etc/nftables.conf
              echo "NAT successfully configured on $INTERFACE"
END
}

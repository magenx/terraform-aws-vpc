

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
              # Install essentials
              apt-get update -qq
              apt-get upgrade -yq
              apt-get install -yqq ufw
              # Detect the primary network interface
              INTERFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)
              # Enable IP forwarding
              echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-nat.conf
              echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.d/99-nat.conf
              echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.d/99-nat.conf
              echo "net.ipv4.conf.$INTERFACE.rp_filter=0" >> /etc/sysctl.d/99-nat.conf
              sysctl --system
              # Disable reverse path filtering
              for file in /proc/sys/net/ipv4/conf/*/rp_filter; do
              echo 0 > "$file"
              done
              # Configure NAT in UFW
              sed -i 's/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
              grep -q "*nat" /etc/ufw/before.rules || cat <<EONAT >> /etc/ufw/before.rules
              # Setting up NAT
              *nat
              :PREROUTING ACCEPT [0:0]
              :POSTROUTING ACCEPT [0:0]
              -A POSTROUTING -o $INTERFACE -j MASQUERADE
              -A POSTROUTING -s 10.0.0.0/16 -o $INTERFACE -j MASQUERADE
              COMMIT
              EONAT
              # Enable and configure UFW defaults
              ufw --force enable
              ufw default deny incoming
              ufw default allow outgoing
              echo "AWS NAT instance setup complete on $INTERFACE"
END
}

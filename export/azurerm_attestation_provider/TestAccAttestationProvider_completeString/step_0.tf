
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-231013042930959646"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapeclgxi0ovk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzEwMTMwNDI5MzBaFw0yNDA0MTAwNDI5MzBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB7L5L66xRuiP19jk3iA4zw6SQVwHz
+o1Z2vnH6ODc97ldBtwBWtKKa5CHhTfhmfwqnqti6OKdFSGTSdzOQ1A0YIgAt38E
nd5OesUI8TvqWrFqpLSXeu/rOQrkwYJGOmiXF2OgsHH7JavQtcZDsjsQWRAsh8Id
JgYKMVwZFs9nkKG2GSKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAeE+iyj1
EzE9SCDnnv/k3OsaQ6PQT6POMbgQlKQmtF7Zq1Zbrp3x/aPMt+YKO5iQbdCSTjnm
P9xn2WpUulnT7ZkOAkIB9SkJKk8T8FtOMHHIK6cru+8WDKUBTnEl6FEeljeaFn8/
dYky/wywZA+vhh8UGfXb+E5MAVQIJvKoalRA2b6gRok=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
      "sev_snp_policy_base64",
    ]
  }
}

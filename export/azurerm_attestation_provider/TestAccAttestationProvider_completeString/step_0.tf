
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-231218071230599352"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapiql71esz0b"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzEyMTgwNzEyMzBaFw0yNDA2MTUwNzEyMzBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB8GTCmjSLUH2voKSfbDcEthE1QW2I
I6bLBrTAM08M+5flvGZ+TIk7NnApn1jCf9dhnGf75s8SjDfG/jsXLO7MuKwBNWYl
DyHFr894bp4fDOqNaidT3xmcQdvYWHfbcD6UNTWd/24dvrCqGfTS/RJ6fzN3PykI
Lr8VJ5kDIackYxvCqQWjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAKSPILba
pKGrqhuihaK7s5yzagXd7L+AT9fs4cDJVf/ijiMmelEOUQD5HsAWGI8iigOayo/n
XDHzuPZqUeYwO82IAkIB+/KQUKN4fkZKc21jb8Xx0I98uwcjJaH7pcyBkSlkDNCr
v5Ej/sFxPtFMaNb+MBphp69fl+e3ehqYMaclLx5lirY=
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

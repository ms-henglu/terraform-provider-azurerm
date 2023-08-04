
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230804025417983568"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapqfcehg7hgt"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA4MDQwMjU0MTdaFw0yNDAxMzEwMjU0MTdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBx4amVjS4BLrHjNYAhIBc/DXTpvkJ
uLxv6ymjABCrCN9vhRQB/Gh6imkmRe9G8nOfvDmeJ5uNV08ngg6CLY0bsQAA//oR
WtuEF24kd7L96+3bHaigvxu/WLBRbRS0Gn9sj+OjVzeg1yBiF8qC4YOYfgDYLJep
+u6juqPc7H/xq9xatU2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAWQOGcmi
cDXWb9Rm2Fubqogu8ez73O3+o4ldEkFyW3ASj/jlaex43wmBSYHgmgu1DsbeysXe
bJnOamabUFvmaZszAkIBiNBt+oONJpK7WnEmB+Sjcdn8juXSv1J8Pz1UTdFb3Nj8
qTy/8U7OOM3ANmnxdfuffEKPQWOo2hwH9+6YWWKLIaI=
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

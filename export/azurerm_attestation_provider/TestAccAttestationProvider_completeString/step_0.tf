
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230505045836478056"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1jbotccv7x"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA1MDUwNDU4MzZaFw0yMzExMDEwNDU4MzZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB1kGejfcBnIWL5RrN57oPUPb0AKJg
5tows10r4MeOu0L/kh4+pMZINOwJFObU8nRWWvtuTFky6zIjlfERBXcs4CoB5vzX
ele32w8s8LfAEj4KdZOESRdCQBJEPSl9WSocDR6PghmrJwdjbLIumjW0308cAlkU
jPHOrfIlBDQylF3WKdmjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAJNSrsee
fc3eTJ8zgKbVmGBIAmjdagJHcfiJMOhjwTw/vhMN4RdN44zr6FJCz8GM+lY9kRXZ
C1Op3ZbH6o5rIpFWAkIBCcCIYr5GBeugH5AesA3e7PcYcVeDckR47JKukfQpxbyv
HzWuUU16f7O2NqPj6KcP9Iu4xrRc50SjrYSSmllrrF8=
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
    ]
  }
}

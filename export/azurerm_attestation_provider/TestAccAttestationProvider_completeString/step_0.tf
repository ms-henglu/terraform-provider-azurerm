
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-231020040533315449"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapn3201j8gnf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzEwMjAwNDA1MzNaFw0yNDA0MTcwNDA1MzNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBfSh9xLoId5KYVZWFEoLrTq7t4Xqq
GCLdjk0ci39I6ZClvW3rnZ8cb0ttCGjAnnrKz6/btI8kTA7jQcS5U8Ieu48A05Es
HMP6fYj6oovh0vREoRA9DFG3It6uPx32FCLkgjoRqowVcxFbTgM+vqSgfV4rHErB
KGDkvjtDmRWHZjjUzUujNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAOuehZx1
G2IdMHfaXMZIRUe44ORGQQTWi28gKdBRUGrsgLPyjoXNR3GJydu8PXs/+7/O1r4N
My80cPnrwNBQ7XxuAkIBxL0aQ/DGtt9SsDRCDcbk2c9Ra2/MOhzm3aZ+81ENirw8
LrcF4EZP0PNpS3u/LJ5vIGUxLdXTNTe3SJwvAsRp23w=
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

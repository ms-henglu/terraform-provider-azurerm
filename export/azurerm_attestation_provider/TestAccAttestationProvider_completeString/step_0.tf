
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230721014442419275"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaprni7a7dcr4"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA3MjEwMTQ0NDJaFw0yNDAxMTcwMTQ0NDJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBkn/WKvrEOXOF2nto04bKfV9hFN8t
cXCoQSfV9pl2nUADY4hVrvb0W5OmFX7LI/d21kl23ZDPO7LwgnCknpQSJu4BkZ4v
yi8W/Suzcn2Q0gfji4maLsNYQtcoK28Ppnb++Pe0QlKWI0/DcuxYOdcsQZ4rpoTM
0oaPNttz2BCSsiiOujOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCASRWfQnv
xY8gDodFJFr2xp47ziXXcfEDCT5rOzFlHYDmuQLg++6dmCdhzEKZktVVUnpfyy5j
giUFKvMRRGDYO2qiAkIBDauNFbeLqB4XIhes9Z+NkwCXTOJCXLybwB80c95mmyET
F9UT8l1566qi2xXj6TSlAklYhcfB9xBXdQyu3Hfhg7s=
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

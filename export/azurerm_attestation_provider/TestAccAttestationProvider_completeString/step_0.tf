
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230721011132920245"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapj1k8tm8j2i"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA3MjEwMTExMzJaFw0yNDAxMTcwMTExMzJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBvxVz7erydVXrDt05rgYqWW1kdbGf
QFf1V9ckOnj07V7fPeYY9b0YLQPR61XGNNtNVJO2mShIlzSuje8xHBM8mFUBMUtt
LCAntGrZGiL6Ewn9AZlbfEFGAWJYob3Hmzt/t0MgFeYiiCsH5/Hr2yu4GL26xF2n
oov/vbWYuOuUeNY09e2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAZF5aqSS
+1HBZZA7nlyccbsMDS7kuj1oHcsBjKKiE6iKVgu99KLU6NnwQrSFlROYGMWPqKBC
hXsHEJPxDJoai0zZAkF8RuZnVf72RcTU/i7VIlFLHoJYC3lrpzhNcHaf3JBJwIyq
pjexH18F+f8QDy9PFw/GRguZX7eA2Xcif89JZeiJSQ==
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

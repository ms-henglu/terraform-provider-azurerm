
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-240105060246411726"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap86msmvduxj"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yNDAxMDUwNjAyNDZaFw0yNDA3MDMwNjAyNDZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBGW4HigqBjVrrSl6OM8qjFYFFC0FW
GTLqdnd47ZWLmIhljxUkxkii0XfjjtFml433QQ43UmNgpRnFegcP0i2UehgA/pVG
q4bB1bR+1y0KXvPqap/vT3E9ks2vJ8gPeDnyuisUqh4Q50H20Xd8kniKfnxyIN+2
F+BVfIonL8UHv6m7mu2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBNaPFXmfo
H2E9H+JPT8+FR45+BXaL4wSz/y903fBLFaFocvimiaTfQI8pnAVkUJUq5Uwrtehy
T1mkZSfKEfgx28kCQgC5cjz4wajF5HkQPId9t67QIh7Kul7gpJLdToewi6zx1ZPb
yeL80ZZ3uDLOVmu0Sax7NpfXWBrCSCMdfm5e63KvAg==
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

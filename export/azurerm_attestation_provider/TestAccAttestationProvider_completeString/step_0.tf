
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230922060604573179"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapxg6w4qxqnw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA5MjIwNjA2MDRaFw0yNDAzMjAwNjA2MDRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAX2YYlWNfFgNpDVFhGub4ZvKJCbvN
OpD2KTenw2x2gqM0J9u5NDCzJWiSVT/WwpuTLkQV8cgIFOdBfkFkn6PP0McA2c1S
vr5Fa+bcq1iKpW6CtN5XCaapYMjGEDQjt34GuaPIKQJQMw26LbX4/Qzc2RG7cRkl
n1WAraXmethYo1R3WJmjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBWEtYPg44
AFdYdm1AmOV2vfv2RrCEPvLbsH53vT0ROknGGBhKMNb+1BY1YuZ8Ql6LWl826/0U
t3fOQt0qeXFSaAwCQgCHwBwuAV22m5t1KjktPMytiqy+BBHU47n2tn3xzOrtsWdo
p/jslUNbM0hEDuxy1/JrfSP4IIjP8FO93DOMqlw2bg==
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

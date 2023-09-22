
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230922053608274737"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapct0c7vlo94"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA5MjIwNTM2MDhaFw0yNDAzMjAwNTM2MDhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBiXrjBXnt/ZwzVLrRej6AwV+iC53i
pMc0oMcZqhafPylSgciI7uaGFFOgW1b+QqIWIElmx0J+3MUyeQvaduXAwUcBa3hr
AFh/bPoMM+m8o4/3b/fXqtUfsjLk2Cg2kmvzSDYQuJhHscAyZYNzapxV19yRuV3J
Ac+zCHi/RN2JTxwih+GjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBFg/ihm6l
sgkAQn4W8LwvEeEbm9FX7IqzErHML7uXp8lws7zI8dia7xsVcmGZ9KYl9mO5gBQy
aAYMTdezj+Ma7zsCQgFj018bSXGwmrdMoU5Q12o3U443N1ybxWkOTdxVGAswxwsU
P3Na5b+biGvQK3kANdOkXtwDoREdo/4psQvMsTU7aQ==
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


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230728025033908006"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapthfrzv20xq"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA3MjgwMjUwMzNaFw0yNDAxMjQwMjUwMzNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA4JsKhTnYBnysRq8xZJKCMw8ge+P8
r/mdR4Rk6OBAWMtysIprv7rTR9eAE1ESBVXOQgh9VQuha4m/RJKWGqkY6TYAkjnh
rr5cIBvXZqCL907BUHlSWZoPw6Dc5IZ08ik2LXKuIO+c9n4qwkLxwrUkInRZTA+J
95fVpPRe5fnlBxsPc9GjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAVLT/z7k
x2CP/kLSNS1qQinQpixlubG0bxrzFApOzHrI7o67ADbNVtua2aDJ1ClH++FrHrVe
KlmtQ/6EWSpIZSG4AkF0f7u/2us77LK+Ezy4XlhDc0TFeYiUf1CoWQY7pjvNsKFW
tAO6NqtMHG62GzA8rpTzIh8HEFLb0A91bltjAa4ZCA==
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

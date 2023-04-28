
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230428045207536360"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap39vzlw6338"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA0MjgwNDUyMDdaFw0yMzEwMjUwNDUyMDdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAZZ8763kG7scShnfVpHbpt+AKG1xJ
i3Z4UHi3KreptTYr5H42702mt1yMOUfkGpORtK/+hM1XOZmBxsWQXUnh1lEBKsgi
PCTejlEuUt4GBoq1ckh8ok2cVodB3vawOL4Ld1a3h4hK2gBXFHLeprOOeeOQH8Aq
cR6FPLSXYM1UwQtZAMajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBHTL/6lwT
Z3/gon+5c4edCX3PDfC8q2gYzpvNYIoSQUukol74y2DWoq4mI2vSARcNmz9yE8+j
DbwKSt+8VVsoM5wCQgCQi79y3xN+BZdH7BoWpACWUjuXZMjDqW49KVAZwPDnunpW
lFRhqxRYAJqXOUhHRQTHZN3Xi5v5vnlHeP1BhfNudw==
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

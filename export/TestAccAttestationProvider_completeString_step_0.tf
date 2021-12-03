

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211203161040735729"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapswro1eyjqi"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEyMDMxNjEwNDBaFw0yMjA2MDExNjEwNDBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBOMZOt5ij+Jhovgol3AqqNxY6KyP/
I5D29aUDM6CfpmUdzYhbj8tyoFoqoyiQSjyBSDWY0xDsMobOxX109g/XDusBW40c
cZ5JsCj9w239tKI+kmP+sTRmnb7YlGygAslw36WZ9sWziEpLT8ccFyYhqsqK04gI
8iGX2Ud00gH27uyvG96jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJANlmczUX9
XiKzLbJ/NFVhRGcD2AlLvBMDht6N/KD/PyJo1ykBeUgWZrCED6B/EW8xdoML8nsw
7EarVjYCNrHg5wJCAT7fgU+kOigZp6lyd4curZv0O8bb/Hhr9BUG0aDvm5LNR8W/
PUs9SyvBJcZX5qN2xbm7bsotn7oj4v/zGmp+T9Nr
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

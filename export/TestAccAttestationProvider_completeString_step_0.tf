

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220603021700414160"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapvciliebzz7"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MDMwMjE3MDBaFw0yMjExMzAwMjE3MDBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAarYlAHy1hqJy782EsVoKr0wwFfrD
b1BFScwyQHhgNIZtYeP9Wvr1hw3mgL8I2QqgG/L50LLfVk/KzoD+CboNXNwBhrMZ
IOJDbt4xKCMAuUv4GzDO9TTesk/E1uSK3c+9prEIr7ADfvUncj/bGYqHDHUa57L5
isk6B3ag0KZ+z6+Zte+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBYtdF6mwy
cUAJLO8Ky0VoKfkJdiNI+qw5vVEtJsnd3rTZ5X4ZJ8I/ZQVEUIT7kfKpsMZQ11tm
CEPKIQGxsXsCRVMCQgHLEGzPYTGLk4mYvohjlUeFXVssALAokE4rsepOx6xxkFNI
scSccT5MUWvflT96B9hFxbjGEq96q6dAij02rrVx8Q==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

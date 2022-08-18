

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220818234842069693"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapkl6s6s849k"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA4MTgyMzQ4NDJaFw0yMzAyMTQyMzQ4NDJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQADSfmArzOCjOXPZ+F3No+FTPft8j0
9jnY45TMQ1ZeqgjTUKJbbz1GhH69kFBFid3/w8T+YKjnDEZY4DRyrrdHl9gArCD9
R8rYj2N9zZFcW0KOEbh2t5Um+NgZpbi6C1EKF7LG/zvOsW50j7Yb3TpE1HIhA3HS
2sMv4okcTSZppNSj0tOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBTQkZ8zT6
DWqrgeD6dmTw/Ruws184VZiDsQgbhIu5mqqjKopiyiUOk4Jp+wa4oPcFbX9sojvz
sKmQbEyCQPVhW04CQgHOL37lP0oTQscxqLuceyh0cK/gZhWq9QUWsLJeF1UsT/n2
zlujutrtOZiLMiWP4TKo89bsSjPcGXQwx9FRcTk0ow==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}



// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220114013859541302"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestape096mg60xh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMTQwMTM4NTlaFw0yMjA3MTMwMTM4NTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBzIF9JNjZnmAGMR3b9q9uH8m1KmkJ
HyevnoNOWq5jW2syOHwJ2huTBXvOFulbrDl5mOHVc4D+JCV75B4+xbuwGN0A3Zba
wl6hqV4J6Fx0y8caOWa7XQ8eocfBowz5tq9m5H/zPEa4F0ymiAbqjaXCM8NtgSjs
Inu2TKDK4Ztrmo+1pkqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAIRLNjBz
QY0k8Hv1G3vknIcuOS3/dG2WnThunCaJ9ZB9rMoHdn5dnTwzRIHbwkDdK3xsFSka
YA3n8+FTUhFB/1WyAkIBSbPK3WmV7xwLePgaUq8Zmpe5X4yk8XXc6Eejqmu55vYa
SzDQ5qKUsLtlTcQQlAVCjTK3ox56BAo8VkvIv16jrbY=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

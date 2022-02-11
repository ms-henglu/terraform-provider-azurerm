

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220211130203861971"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapceoy7znf34"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAyMTExMzAyMDNaFw0yMjA4MTAxMzAyMDNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAlQmT/8Z0um4rVvVap9Y0VYOgpJoW
AYmQ5N5Q487keQEsQ5H33XxzMNXYyLpCE5z+kdOnyHXexH2uw6YjtXDJwT0BOM3T
LtmOzPN1KLp0KoYtjGMM49mw5WRZJ0zwYEnP39NvtNeK9KkRleeymWO2ivD0T7GR
1p+uEnAXnEknifUI7kKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAc3kmzkq
jdklQ+Knwlo8yW0UyihmYrpVTx/i4WCSXlT2kKEuhuHVQrELSXAUE9F+7bD9lHsD
1zSIU3qFVIPzTVnPAkEyYvPR7q1z31AvqxldNDHKFLsZATbjRsJu+BOacWUTVI6Q
kaR9PjiHYEjzQ1r2JzVvOiY2URaKjXrk2GxCj5l9aw==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

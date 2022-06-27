

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220627130754545189"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap9jaadd2eft"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MjcxMzA3NTRaFw0yMjEyMjQxMzA3NTRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBXvmCme3M3HHKdyG5dhF/jFNc7taB
qk6JxWXmNOSdOALGtcbKW1A/CdsOUjojFD5d5drLVZr+m3XOfVcY2ZxC1VABinER
oAegfo/3ts3q44kjO7Jgg6n+zkeM+H4mXqMBUdfl6RU+RPJZe80oX1CNU5Kl7OqW
kEek//b7gAqp238M9zujNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCALAFUkVV
He7OnfYwZZAgXj5D4DZVTkgk36VYme+/K0NmmTHVkC+F17dH1Rl7EKgr7oux0o1k
aNERmgAMvv5hsE6tAkIAnSawwq0CwGNmtnwQw8MHpwczQJgp/yCKPRAXWDetJa/Q
54TZoauydDhO1wteQJmLEOc57TdIxuKw1fArJgMFIn8=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

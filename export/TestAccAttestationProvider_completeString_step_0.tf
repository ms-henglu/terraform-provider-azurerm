

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211210024311299845"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapast6msq3zw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEyMTAwMjQzMTFaFw0yMjA2MDgwMjQzMTFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBpsK6W994ij2Ab+FLozAPE6X2ThhR
EtRT/S1+Vfc/I7aBHBouvrYtBvQfP2m3ttGM98MqKHXu9qtwLl/JeOsQ6h0ASsic
dAjjxf19ue068kOLa7xtrUY8vMU2zkMwCXhBPuTFEDWjnDF2rMcwqhoOZr1uUcxV
euYwds5DHt8lY6WpBVGjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBCXv8bjzF
WYZLdppodHC9bZiF3EjRCiJIyaZzjD7wwXLwx+qIOFbbdV7oCGULvFM67pew8xqz
jCxCQ5OACTFj9CMCQgFHhJxY3q7baY+6i1wnP07l/ibSLaJMHBsBBP4R18I/NkaC
8UBXcVUyWVeu2C22ABrrq8Tz1AOIRniceUEfzzs9Yg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

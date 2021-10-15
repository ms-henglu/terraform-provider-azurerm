

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211015013908009753"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapw0fbuhk2vq"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMTUwMTM5MDhaFw0yMjA0MTMwMTM5MDhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBT0qtaw0tGhON1F8W2ks7Y3r3jwdo
6CcJVBHqv9jt9uVLI8VdfXH/75dkqF2IM7UT9lbEyzfv0+fojiyUBJaE8/AANSyV
SXwtyumjE/4hbFl6lR9CTO2bVBDGdkYN/1Q2Kas+v5tTzt5B6kzwe1z3uL7GsHrg
XKB5Or1x/wuYJJvHAjqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAIk2AgpQ
EN29gAU7N7R5sbeU43rLZ3e3/b+lOFdh1D0wr8L0jd8ZKBlGu0eTr1KFCiGopUNz
oVA599y+SzvrZNgBAkIBocW//Tlj80/hg5CCbHhlgUnl/ckXeYcnnm90vPBf5RMf
D3KMD71/PebO453bPwXDL4dA9ZkL3pJFoO0gMrMe9Ag=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

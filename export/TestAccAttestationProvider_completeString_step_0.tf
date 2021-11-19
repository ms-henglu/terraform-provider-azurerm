

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211119050511559896"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaphl7ldexe8m"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTExMTkwNTA1MTFaFw0yMjA1MTgwNTA1MTFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBhErDh+2v92lEPmvU3/ermecD7iTW
26kij3GRKW5tqZ4iflcRPigHj1DAkKh6/Urigzgf07bc+phvNcsEM6IMm2cAKwMj
2TFJxE3nVtgHUynV9Q0JJmknnH/1/QDufWzC3HPO3ifWLTMHjRgDorvvypt3cuR/
BddL5nuX+UW3aLmG2S6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAPqoE12v
EK7At+lbVOGv+QS7B0h0/YYQhtBR5XTDTn8KxF/ohmadgneD5dFE+CJBjg8sJZ3G
sc1ybYoYeilpkc3CAkIB7ZG8Kk0MIZvH/gmxXSEN+Kkw/gBfLBUorykVrOATrIGS
o6uHOXgIXcPmkNVRmRsTq3zszjW+yuC1laUcBJ109ww=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

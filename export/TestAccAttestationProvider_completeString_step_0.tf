

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220204092637181287"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapb6pium2zro"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAyMDQwOTI2MzdaFw0yMjA4MDMwOTI2MzdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBdPvawylfwF1EUQW/KO/A5Cl6bDTK
iEScMRZX/UUyYbZHzYA/fMgrzcHLNahlFTvIsNbUqKcNCu/bENM40MJIXMoBp4mF
hEiml3aiCfiRE5LHjGK+Oax/qMJoIcI0a+kwCuBZc1RDrYMzRyYk1UI8T7UDQmAP
R/iUYwSGXufNK9XmhWGjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAQGLpdQ/
uu4FPp8XhSfZD39U7o78CInvibXcdkOcpHlP4Zqd1NIPtO15g2ngjHfKoKmhkpee
lOp2XlVfCu/BKzxJAkIBP71Fvz/5paAim9hs7e+JR8mbXIBBffVo4VWxKVU0sAWV
1WmUQ3eesT471z/cvDJD0zogyxkTm1kw5G4XA7HVxME=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

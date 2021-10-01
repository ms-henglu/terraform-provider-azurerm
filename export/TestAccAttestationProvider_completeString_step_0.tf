

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211001053444019478"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapsor08okg1w"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMDEwNTM0NDRaFw0yMjAzMzAwNTM0NDRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAWyDpXmOaXLywZYoFFtKCzokLbF8b
0s/u39bDkTEoGKaD3QaelJG1/58nufBzEQIDA+V3q6/ak3+EJEJzM0iJ12gAcJ5B
e1aOusuQ+hNpvVzX5CnA0MQE8Q6Dy6e7G4wdGUIHWtlSHS8oXp/A+DCqhoBfSb+s
oVEGAryfIMNw+jH0pc+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBbb4Z43fK
NRJVemYCIFdS7/f/HnlGi0RwPZpeKa0GCqe6oveZ7QiYH/bfYtfBdaM/2G1P7Cp8
51wjecj79hDxRbkCQgEfKKRtSmRSjBP1M49sTGIo20GWnm8Bgb+2BHayvag/+dM2
etdA3cLKncbsaae9lIx91Gb6Va3cmXUj1Alqe2tAxA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

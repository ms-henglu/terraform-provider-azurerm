

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211203013426795254"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaplc70zjcash"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEyMDMwMTM0MjZaFw0yMjA2MDEwMTM0MjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBCkOC2fcz5/gp6vLCNLb/zgK1g8kN
vrMrhjSTjX425zKda8IfNiLNjjF3CJIoM4oRExzOc+Is8OEAXGR7D+ifWTIBmKnv
oiC2Y1MNe4DY1iY+YX63YXirHu1zOJfp4UM+qLywMJw/DkWRuUJ78WP+Zne3xZDU
cwcm1Hqvd3Hg9bMMLuCjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAQnVECW3
K1LWDJ0MqAcVmEz1B6XaD9sbNic1I3vwrugYNBFZd83aZgJN/LTuf3hJRoWzMASR
Y7ktDcJulQ0SVLUsAkIBNzRKLkd2VTuPn1d0ns3AsT2H0zRQ/SatpbHctmLEzIOC
1Bq+c5vU7Xn76Bsuzb2emLmPsJcPnQJbgO8WmkP+PvY=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

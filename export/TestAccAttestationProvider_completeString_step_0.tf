

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220107063633483553"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapc3e8390p9m"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMDcwNjM2MzNaFw0yMjA3MDYwNjM2MzNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA94Oy+5yXfu0Hd6TSv7kReW9ZvuIB
trT3X3TeAHTuVoV26VMlqPUA8BG49gY/25syYl4Pa/TCcIqKMgMLHuFZIucA+h3d
xmO80QrJ3kx1e5emH1CdEDhmuLfpFUeNrRi6tzmd4/oj/dkGC8FM+237dbgzSun2
KU11liQWZeXlrKdL8GKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAISAwV3+
J1oAAVR6fcnsY+SiNgMkwdj6uTgg20/Izl6dqYuHyKMs3bFKqFOMc9QRyuh3/sGL
nAqqsSTScmaPDg98AkIBKHdokv6M4VKptMAy75QNoRPU9VHeeFJ2sFi+s+IiWeOD
gkBdmtylgNqMMCyjOlmmIEdf2+hDmjyodVE+7EzEX+g=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

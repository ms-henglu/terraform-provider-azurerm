

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211015014325406725"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestape34wh9n9iy"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMTUwMTQzMjVaFw0yMjA0MTMwMTQzMjVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB4Bx+yE2z1Guf/o3ymvFfBeKRdvTO
/LV710dSkuCAzAkQrrfE5pW/7A2lwP9Y5xz3vuPwSyIy4AisIu/eIujY0K8AGjEX
2iw/F2eTs7mWzcLeOAbgS4yPcQlrPzxbL8Y3aF6ht4j+G0Y0M2CR9JMElEtuiVYE
nmHAcGktQWvS6CsUq9ijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAUSEoYUq
zUF+2Q577UucVE4ztwtim0HZC8okHJkzBVY06zIE7NhdPOy9blUZ6Xx94AHD1DBZ
9Iyg9xIcQOY7RuLfAkIA1I9r2M072rVU2mU6RtCnow56HMPTrfUEjrn18cS66nT2
Aj4uSVX727YwojQcxS+HzmtPcE+7sAOaO0+Bp0Gd/xU=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

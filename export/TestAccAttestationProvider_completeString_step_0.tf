

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220923011520488907"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapeenpqpzxyf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA5MjMwMTE1MjBaFw0yMzAzMjIwMTE1MjBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBYCkPgR7egmtNBQ/iE+yDu4F/eZS7
5emssS/Sc3rjs/b5fslXnD60Z9y4aOAz5sJ9KLaRSfqvhJ6VQf0r6+PiaGoBNed8
IIvVLurrYe0y895yBnIYxB3huc+Lh6YR7kvzcaluFKyEcUkkHWSsUOqOOKhv2jNf
RMFWlmsziToih/EIw1+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBOPIqp/OM
d3UR92W4NuHecjUauIlc1UtndJJGtMyXk+qUYSyJhINz+X/BYvGrhyc8/tGDTC4q
wT+s6d0iQuDsJqACQgEDfq0cxXC3uWY24IQ3q4XMeuwXFrlDNF7USDia2gH8vtyK
KR7njdGNBLj7uCVnLWfx0vIEzKWhN59snJ/6gRUklA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}



// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220429075113723299"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaprw7fwiyiv1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA0MjkwNzUxMTNaFw0yMjEwMjYwNzUxMTNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAo4VV95a20YY7hJbwNfPviAon+mEV
gkLH43hEvgFJ7dRKW+9cIBwiFnQ8EPS3Lbk0ZJ+rdpzI0mbL0ReJYAGD9GEBwpSD
IMtaviZnrSsI7xV+3KGcLlMPUgsUmk5/lIRTvDWX+C2BRxSIjlizjOerXAWwIoeT
wzWHAgnNCEYyCYsB1AujNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBOow4KniV
AQeT2yXidBQ4ws3f5xJzh94jsH+pwtnS+FjPVOP07EvmEbcxvzasCIQ8XyV0GtFa
z3l/0KUkPylCzowCQgGaTjRslX/1YDOu8Ba/zEGZEoX7KcDs6LRJ97NZ3b1IVz5d
0aUtsPBcgX3x4F7fXOhaeS1ruxv//MV9WA0hhJF18A==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

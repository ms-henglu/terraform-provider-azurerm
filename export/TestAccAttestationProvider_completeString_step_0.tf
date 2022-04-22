

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220422011550749758"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapf3esanqn49"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA0MjIwMTE1NTBaFw0yMjEwMTkwMTE1NTBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAnuNJWvGHWRq8J/odYT2U/CYV5/la
DkV01hWo/+vEVcbHGrxRMmhlgaBWR6QJo5CFRS5doQOpuQrnWp+vBJwF6zIA1LpW
l9VJGJGxubupHDUSA9Gd16VpVRQICw1yNGMbPq/nGesmbItEf6EssFp+RyxVH2zQ
7W3EElufdwQaFiN9I1CjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBCsox6QG4
htICmnq4Pi6NzqmZlEkOaePMBslC4YsksbQ455c+xC2ZNUyvtlIfaDw0KPN5q8jI
n2ylnUw2eynU940CQgD3wKNvMVrUD825X9Dv4zA7cMr+A1zGt1F/ZWL/PuNoRajt
p9XPE6BdFQDC/eRqOU0ci3OsERv3UJgOLk4mV2u3Ag==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

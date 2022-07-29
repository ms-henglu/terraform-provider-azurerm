

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220729032335652653"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapx8andkhwsm"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA3MjkwMzIzMzVaFw0yMzAxMjUwMzIzMzVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAWWFtP6YIBdJcIQZv+aVdoYaPp+kd
/UI8GKIyvLdAXL/gKLGr9as8nej87PzFuI5iv06UTWINSEAneb70NpaWAJQAJ0dn
zZyoTDJnCn7uTj3QQEpNMxxvw5DaO6qNuu/+rapY/KwLQogWSOzVEmpj15vu1xuw
hFwVYXq+4f3K7gmIUDKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBdnVdBaJ8
1h8v0EZS0q5u5CoRTizRa1oWL9XpCAnng+ii5E7o1+CRBKZXulDRO67gc4jcKi7h
H+jKMKqthKOcdhcCQTsn7cAyg+d3u51sFb65oz2/nBMNja01jIr07eg9PMuMlfNt
N3NrnNlFAVYsCih9rniO44aKnkZJBLSynuhWCEy7
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

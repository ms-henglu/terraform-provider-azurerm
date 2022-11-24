

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221124181234180354"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaplmevusmdtq"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjExMjQxODEyMzRaFw0yMzA1MjMxODEyMzRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAOM3yChjRc+shZuyfK9hjCFTKtn+c
URwQIs5630pr23f0Rvrh6dM9zov39eDcnFquS2MSgRYvRB8ey/btVWQPTYgBKuro
ANyGTg3wtrWxzgd8LgfQ1PwlFvFNUucJ48wuqQI7WNnhW6Mhiby9g/xhNbq4J6Nh
nbmlBULUYqK8ltvN3XijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBQ3yi3ykk
ZYRJuLyiDej9nOrszUyPyexEAuWByaBjszexLxizITINvCAVBznAJblhxj1KqZil
Jgj+V80evzSI5D4CQTCbwcVf9TxIgQhBKoyYacmL/hhMzsSi5fbhpXABFRNTwmOT
W+wSxYOeaGsPqqQ+OFjMRhKGd5RDD+/pSW2aA1uh
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

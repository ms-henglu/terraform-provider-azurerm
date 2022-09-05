

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220905045421981507"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap7zi8h8s3kr"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA5MDUwNDU0MjJaFw0yMzAzMDQwNDU0MjJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBnm3zM3t0ppFx6etHrhPuDO0GUD9T
V4YtT91iYfbNagAi0pwnLNyj1chkclQdBW807cRGIPZXipRYc6+taoJW8noBMTEE
zcCRfI/l/zZCPAgaV9OdI4UNelGVAmMdmIs15Pv/BsVcpUkoiQq7TvWKvjk1Kmn/
htvZj+B1v9FsT3kh39yjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAf9nIkfq
j73JhFh5hUGL4JUD0gEXvWcNa/YOliE2mcWWEpZaebfYGvAtb9Lkd5E8EH8pefV8
Jdky4W7Yvr/jscMvAkIAhrgsqIm1g7GMKmf+ZEdUFAPn2uWz0Mo/gG2dsjfQOqdG
SNvGHEkjzONHhybi9JgePj0u800FBmSJjTeIeEedfP8=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

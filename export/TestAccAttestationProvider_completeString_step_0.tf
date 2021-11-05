

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211105025636059673"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap8uy46jabdu"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTExMDUwMjU2MzZaFw0yMjA1MDQwMjU2MzZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBJ8CYgflCFM8R3Oa38ZkIlrf63fWO
WLOsu3h0ahx/5iaDbUYxqMI8mGSjzDW9j9a2osClYtPxMGp3QEx1ykX43Y0Bdtsc
/MycEWgHWOsGaeg72lsVnQd5kHX7BgqgUnlPsWlwcdVPJiq4xRTHZghz3UQQ6tGm
Cy9c4Ij0m8TKJJBk2x2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAR+1VSRJ
QtcXfjQkS3jBloEk2TcBCT6ouVKMobEhnh/sNxV+ynUidHZOvwx0wirZjz8kmjlj
gkRke98dHdUFHefcAkIA/5t9Z0MQGO+frv3WrkPSK0lZYgRyK03VRzN0PZ7lkdKC
IlZiKOoxGlK4V18uLZ6qO3gj+hdN0UJqxUxFn0hAx6M=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

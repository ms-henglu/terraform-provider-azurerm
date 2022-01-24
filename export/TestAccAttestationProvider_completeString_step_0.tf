

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220124121736015599"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaploqt4vor1e"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMjQxMjE3MzZaFw0yMjA3MjMxMjE3MzZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB7vE7CLd2bhdJ+CkB3vfWjhEswVeP
rycqb9v1HPaKEPV3RopIK43jmsUGySjnhkfn7rh8ZQUXClWVx5/RfUlrN1QBGCXH
gwp/eQErcRDlJMK92zAcFMCO7LI019vIumdBKSkwQtrFsuHhPe79T+q6pyQr8qzY
wLPg7Dzs8M6wfOVu/nujNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAYj2UZTL
jeMsm9vN4jSxblGKcdHZH9UF5i8xEepeO602Eg4OW7cIW8nke8Ec2ILlqhdEUA3i
nkqSrj4ob7u2Skc/AkIBqpt/p0tFIYvWfGz+uASzFs/FTBuFKRitiWrrMsYgCo7F
9PfNBACkrTP7lwTKV05+L3Y0ktriyaHhTQKh939xhSU=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

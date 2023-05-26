
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230526084603053285"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaphwdy6c7n4g"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA1MjYwODQ2MDNaFw0yMzExMjIwODQ2MDNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA8ZwpSMdX9J75T0VRcBTf79gcoSc4
HzFDKYxz9GRjV/ngRXuCxynXW8/fGAY79HOVGA/p1mC3TjUxQZzYpIoA8G4Bsn0Y
Vz8OzkgcP0P5rt37wkeOrMVrB0EWcsH5bEpEcokFh93fm0uToOpHubQeKdwFPpXq
MVMj9Zyn52+LC7AmWNajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAMLW+fGi
xxo0CRg6LzU8SWhT1f7WkaLqopk7DQyunsbG0k3704gz87HEkZe3lAm3YjSrmo0E
9Wm5nUyRBdEI8YB1AkIB/7kfne3okpeH1WJRGqiPk9MBRk7oXAll3a6Rqf0CybKU
2ZZ21DziP9uV3oW252sCicrLP0ozGnAnp4eJDvopQ3Y=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
    ]
  }
}


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230616074242310157"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaplsjx2efw2f"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA2MTYwNzQyNDJaFw0yMzEyMTMwNzQyNDJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA9UOYMGAs/zbuEl1cRsRmTCTBhq+9
PVi+Z7mmZWHtMwF05zZBRAsg5XsqaSCS5exBCf6CwWH0wP1WJGtlZVbDFT8B+hYW
73foXceRbbnls7HzEMjwOYHsytN95EkftBtEOANcsHjcntscWHJihzemLGbtKM/D
JVmzftH50LJGz0eUFomjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAKjzKLb3
N33rRJt+HFrKI0VYOAjzlDv3TakipdnwcLl7CSdDan4iNZOmritVTVr5p4lIzNA/
PuydtDXrlzbow7bzAkFFIP29Brnf7qI1FcJAJo8XTzrf0P7+94pOxhs0ZnEp9LHv
ITzh3+Y5IiNtiI4Psu/2JEF8vc85CJcsz0/78SzByg==
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

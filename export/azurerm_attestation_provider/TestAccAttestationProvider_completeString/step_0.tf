
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-240119021528179274"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapqimwh98kpt"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yNDAxMTkwMjE1MjhaFw0yNDA3MTcwMjE1MjhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBs/vQl/z4UW+rfimx8NeTSvkKlHId
Pwrt/PR/8TJ7G9Z2Lts9p5lze5rr2vfJrPRFwqj9ReJr6LO/jN/BfNMq6/sAHHMc
BRokUCWhNwnrNG8NuFVEHHK0ULwAe1ZojipVwticct7bKU+ItG1h0dpAZ3nGHEwQ
BF0Ihe2PGXjTblP++lGjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCASK47wz9
P/raO/q2EtuzgqNd84fcdAQApOFjofGkSEbE+Dbe4cq/J+HcUhLe00dF19J3f5sj
EnhkBKnRsPylKCBpAkFzf8epWAmlQYoDbn5iReEsuACIEZEpNYfCq9W3N8HP2hzx
ZgJQnj1po60q332ghapU7JhuYj8Xf+DmCy5T7Wgd8g==
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
      "sev_snp_policy_base64",
    ]
  }
}

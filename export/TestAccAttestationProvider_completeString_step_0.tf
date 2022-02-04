

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220204055654691914"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap9fl2y8g91b"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAyMDQwNTU2NTRaFw0yMjA4MDMwNTU2NTRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAz4CsdcVYQq6dN7maLBga6R3IEYD+
Eh+chmqjYGmalwZyfOYMKm3+MEgFImqeQzZkUgrZ6JTOBZeqUiUFacffhGoB9epz
EMFDkAU3puc0y9M7l4gak/ZLETJQ1EvexNvoTPDtQxMR+BwAB2qq83wgJrVe9cOS
lo4tYGEoJJeYJDxLmiSjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBEDrMw5xT
8qyVaTPR3fSWqIoWCo/lj517iJtQxIO/3pjdogyM7VSzRROMclvJHHSw10DdJl6D
6L8JTyRyk4uHrD8CQX8B86g7GFmo/k2gGu5cHiUmXZMH6oHVhXISKjZK2woZKsPV
w+eG/02tfkkxtSr0HSIMxS7yPmWa4XiqSST2bfMN
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

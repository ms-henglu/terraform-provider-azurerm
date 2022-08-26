

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220826002338195759"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapc4koive3qc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA4MjYwMDIzMzhaFw0yMzAyMjIwMDIzMzhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB5EgqHkU9BJA+qpwLE0xpHpMCKN0e
iBieI2qZc1TiIkazNLOrfqA/+Bf9q4tUbkJi0cMR3e2EBLqcUvLqkRpgrPcBXlFn
Wa14qnh4j+/ootxTZCaji4RhxecI1cVjNNKhLpTFHfHeB+8I7dGE7MJDSrFCL1o+
VKz52OfX14gtqXhlIFyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAbwmMAxY
meiohWGoBoMuQpwaUB7dk0x28y0hmM6YVdxgE+Jf4/Mb+VKokhAsGoVNfqyDHcDg
csKl3xjoxxc8dyHpAkIBJ8KHVmgmX+ai8tA+dW1fmrNoSqSqNFLxo2Z+JVvpHeZ2
64zH8hcD3TeH0zh0o8nDGwshr3r3O3yDcO0PjhBVIyU=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}

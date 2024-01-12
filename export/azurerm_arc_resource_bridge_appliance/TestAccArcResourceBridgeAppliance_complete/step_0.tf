


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240112033826405130"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240112033826405130"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAlbBoYcskJ7HjNUCcJoyx216ruC3Xqel1e+78SwHFjXb+ORWAv2fNHASBGw9Do4jEfKYYQ+Abt+NJAiNvn9yOxL57toye3XovFQRgMTEqSuEQzbcKiG/KaJgDfa0lcgMN0iXHLt97fGJaSRMMi966rHoDUOdQ55TSS3sibv0xJMcQ4OHaY8wHQmLlgSi/gR0AA5dY0A4zzQY1oqkt6ZMKhDmtCdtlkfVmubM9GodVmfJ8Eh2c+AEzQt1uU+v6Dwxbf94smwZy0tahJ2Ai+qnRjbO11lkQ0AayMsYcCWOlqgKsSE4fqXCVjeTtGinblmPde7g6JWocZICoq2ysQO5h2kbjFTzZLEEMYEoULkBlleoOlbGETv9LjWr9Q7z+F1+XO8Dpp3G0MaACImzAzizZzDEpoxQ2+513rTAbYJHL9nba5Qp2OpsVOustWQgMbp2a88HwoyMdEfPtc/HC6zOugPxvjUJ/ZIqZt9uzk32vIK14l8m/9NDmjqNAOybhUvJ016KE3kGoaroiFNTG3BPB5MK/iDuerxK9xIaDeQ0HaPcXFyQKAtxQo66HRsn47f4pKlgG4A5eYwihO7dyDCYuJiE+f+FcxHwMJlPcwYQTcNacNZJyh1CDM4E5yF82MIbTJIEM/Pgn3nDod7fr8tpna9MyyFDh+DO6qqHuBWLQVL8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}

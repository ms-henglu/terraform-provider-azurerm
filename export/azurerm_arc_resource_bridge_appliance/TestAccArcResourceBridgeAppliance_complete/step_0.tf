


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240315122303500539"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240315122303500539"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAuypJICXx5APd9m1iz6mWP3RqqQ45CohJGfAnKd3E6/rP1W6PUUAUB2goQGm/I63UldvprQLNbYe+wnNHAkKoGblGmcpoxT7t69ufuGtSVmu6nDu2eL3h5wBOeM6MHQkHYerXm1xdbSTpcBsrMhMR8KguOSx7I5TKJJoITNuv8MjB/MFpAbL4LV3UfZN/G2yKhnnRA4FGajBuF5yXPOEHGAwbMaid4LR4crABhKYxwn3o9yp4GlDWSL2n0/CcC4xMYvNjqn6odThdIbyRN6vk9bPaimvs9XpZ5UE03HVbfiOrh1P9+JlHJLN+5vyfLRIbdHVsDF2jBrvWh9znFAssWbblRFRxcHPYHjaw9dhQrU8Gq5FjTc1kFi0B9OIoF6pH44Dw5TDZs3M5BoweDW20hHTBRe9/wWBgCpkGeXFq+oxQORlqidvyKmpTg6EzrOLYwb448arMB+KAVlVyxOnGXTQ6O/SIVgb1aUYRKSYRpwKrQ/m8rhdt3mwR5Dk/3MIMRGbnIC+sCn8ZjtjOxYMZf4wnI3yI3kSqor0F56FgPr8EkyKp2hNq3Gn9Pfd1X2jdWCZ8RQviV9dmvZ4Esn7Xqf1/uTbwTQECzcxARftthQhmFKnADcEZjGPnJXhd0OUZLnP0nO27uJPMYCgOFYZfkBKBJ36iURKfvZVdUnC/nfsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}

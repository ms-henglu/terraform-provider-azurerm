


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240105063243847846"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240105063243847846"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAxthsv8U0oKzLlPmbjTwHKl8BBOPcEAlnPWeVggOxvEzUBciB7pghRoeVJtfKO7e3MF+OK5KRO70TpwDrXPDSHFMHbO0LpB4A0o4LKBi9eq1FFP/KWu+Y93sOCX419fb1cGzloznPR2DXb/vFRohssO4UF6J9kWNSQchrUWdbiafvqtCvFWf3sDqEZeFO1qujDC9TDuI7LSCjJbhUUM9+OzxHbJjXkQU1Xkj6raB70VAzFx1zulxq6W0LQ1nyqbhCUmxsJFCTeRed5/3LwNLWwx3FjqnyItMsHY1xQhfC6niCD9B7S48km+7iXFheTmAbSW4jHeM4VPFhEzWTIbsNo/G4jczr38KSgI5NTuNRD+YU1iB3mLrbWNJtcb2Ulpwj3FqJb7vkl7opL+wBCvAH0FtSezIh/P71/buVMVRT3IYHVumDiPQ6MAuQd9YzFou8o+toOjZLlyS+cnmPJRx0xbdkSxDwBQg83rct8rJBmjl3bAgaoEfYkZiaEVf0D3A0rDIFkZVIcAj6f/wB4qEj1TuZQ+W9G/ZEBpg5PmWRtDJNxa0ciUBOGuOVWeXYq1+abcSHSbXXk0eRtZt0x0ig5lRhPhFr9X4qyG8gZPeuF7Wb1FYQzUUon9LK0WgCqAd2POEO75CzTnjK1x4E3DiAd8Fc8Cgl9nymgqtRDfTj/SUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}

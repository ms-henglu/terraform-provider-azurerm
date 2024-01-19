


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240119021511348663"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240119021511348663"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAzAiz5XFElV91UnWsKRoI4VCv2e3LJJglHUhgDLgHgpM4dImyPXMZf/p06+pMej7BHJzK6Sl9xYb4igQz6TYDnaWshLUKWLeJaIf/8ijD07lmgslvZKF6HaPqnc1diimpgNeiunlMRc5cKIUTRipVafeBta6+h3aZy45ayx31lXgvopY54584cQFI1DJI4GEphMCpoXFCRcRBG1U2bzQPxZf50EBFLGL74Gvs+gmlyJgpsbKbLoxbdHP71n+3fuXSAhTxpipHpsa1YUZvc2saqbLt7HCk+tp3O6GrxBnVb2WrsQZTabdr40pTMx9vww3SSQbBF1C9PQBVBb3Tk3TxGbwvBT3lX5vaOAO91rUAKZpWe9Wk2S1dDnijNln/LLqfiHFsjTFTOLgSR93J4TzVAtTNJ09hoBqfyhYUtrdgwpG1+b6WwL7luYkfP4UOmsh+JNcHNmGYFeInfOeWJDyJ9WM6oGxVVnrMQdv81N/M9DL6qpU3CNdi5Ops9Wb+ewYjdcSdijvJ6YUeQqL4vSPlwtTZajh6sIKUNW/1k0XjDOVKsGXoxeys8QIDeOmbilL4HtaroCchrEPdX+zeNHBUdo0lMPfzv586McFgXBckoub6Ymty24jrpIbP7zHoMfGCGLolT1hGQgplgJHLaZhwnq+iFWsJ3vT2U9RoPcwYlgkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}

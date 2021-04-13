---
subcategory: "Network"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_network_connectivity_configuration"
description: |-
  Manages a network ConnectivityConfiguration.
---

# azurerm_network_connectivity_configuration

Manages a network ConnectivityConfiguration.

## Example Usage

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-network"
  location = "West Europe"
}

resource "azurerm_network_manager" "example" {
  name = "example-manager"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
}

resource "azurerm_network_connectivity_configuration" "example" {
  name = "example-connectivityconfiguration"
  resource_group_name = azurerm_resource_group.example.name
  network_manager_name = azurerm_network_manager.example.name
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this network ConnectivityConfiguration. Changing this forces a new network ConnectivityConfiguration to be created.

* `resource_group_name` - (Required) The name of the Resource Group where the network ConnectivityConfiguration should exist. Changing this forces a new network ConnectivityConfiguration to be created.

* `network_manager_name` - (Required) The name of the network manager. Changing this forces a new network ConnectivityConfiguration to be created.

---

* `applies_to_groups` - (Optional) A `applies_to_groups` block as defined below.

* `connectivity_topology` - (Optional) Connectivity topology type. Possible values are "HubAndSpokeTopology" and "MeshTopology" is allowed.

* `delete_existing_peering` - (Optional) Flag if need to remove current existing peerings.

* `description` - (Optional) A description of the connectivity configuration.

* `display_name` - (Optional) A friendly name for the resource.

* `hub_id` - (Optional) The ID of the hub.

* `is_global` - (Optional) Flag if global mesh is supported.

---

An `applies_to_groups` block exports the following:

* `group_connectivity` - (Optional) Group connectivity type. Possible values are "None" and "DirectlyConnected" is allowed.

* `is_global` - (Optional) Flag if global is supported.

* `network_group_id` - (Optional) The ID of the network_group.

* `use_hub_gateway` - (Optional) Flag if need to use hub gateway.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported:

* `id` - The ID of the network ConnectivityConfiguration.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the network ConnectivityConfiguration.
* `read` - (Defaults to 5 minutes) Used when retrieving the network ConnectivityConfiguration.
* `delete` - (Defaults to 30 minutes) Used when deleting the network ConnectivityConfiguration.

## Import

network ConnectivityConfigurations can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_network_connectivity_configuration.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Network/networkManagers/networkManager1/connectivityConfigurations/configuration1
```
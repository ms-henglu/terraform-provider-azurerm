package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-provider-azurerm/helpers/azure"
)

type NetworkConnectivityConfigurationId struct {
	SubscriptionId                string
	ResourceGroup                 string
	NetworkManagerName            string
	ConnectivityConfigurationName string
}

func NewNetworkConnectivityConfigurationID(subscriptionId, resourceGroup, networkManagerName, connectivityConfigurationName string) NetworkConnectivityConfigurationId {
	return NetworkConnectivityConfigurationId{
		SubscriptionId:                subscriptionId,
		ResourceGroup:                 resourceGroup,
		NetworkManagerName:            networkManagerName,
		ConnectivityConfigurationName: connectivityConfigurationName,
	}
}

func (id NetworkConnectivityConfigurationId) String() string {
	segments := []string{
		fmt.Sprintf("Connectivity Configuration Name %q", id.ConnectivityConfigurationName),
		fmt.Sprintf("Network Manager Name %q", id.NetworkManagerName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Network Connectivity Configuration", segmentsStr)
}

func (id NetworkConnectivityConfigurationId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkManagers/%s/connectivityConfigurations/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.NetworkManagerName, id.ConnectivityConfigurationName)
}

// NetworkConnectivityConfigurationID parses a NetworkConnectivityConfiguration ID into an NetworkConnectivityConfigurationId struct
func NetworkConnectivityConfigurationID(input string) (*NetworkConnectivityConfigurationId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := NetworkConnectivityConfigurationId{
		SubscriptionId: id.SubscriptionID,
		ResourceGroup:  id.ResourceGroup,
	}

	if resourceId.SubscriptionId == "" {
		return nil, fmt.Errorf("ID was missing the 'subscriptions' element")
	}

	if resourceId.ResourceGroup == "" {
		return nil, fmt.Errorf("ID was missing the 'resourceGroups' element")
	}

	if resourceId.NetworkManagerName, err = id.PopSegment("networkManagers"); err != nil {
		return nil, err
	}
	if resourceId.ConnectivityConfigurationName, err = id.PopSegment("connectivityConfigurations"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}

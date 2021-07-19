package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
)

type NetworkSecurityUserConfigurationId struct {
	SubscriptionId            string
	ResourceGroup             string
	NetworkManagerName        string
	SecurityConfigurationName string
}

func NewNetworkSecurityUserConfigurationID(subscriptionId, resourceGroup, networkManagerName, securityConfigurationName string) NetworkSecurityUserConfigurationId {
	return NetworkSecurityUserConfigurationId{
		SubscriptionId:            subscriptionId,
		ResourceGroup:             resourceGroup,
		NetworkManagerName:        networkManagerName,
		SecurityConfigurationName: securityConfigurationName,
	}
}

func (id NetworkSecurityUserConfigurationId) String() string {
	segments := []string{
		fmt.Sprintf("Security Configuration Name %q", id.SecurityConfigurationName),
		fmt.Sprintf("Network Manager Name %q", id.NetworkManagerName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Network Security User Configuration", segmentsStr)
}

func (id NetworkSecurityUserConfigurationId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkManagers/%s/securityConfigurations/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName)
}

// NetworkSecurityUserConfigurationID parses a NetworkSecurityUserConfiguration ID into an NetworkSecurityUserConfigurationId struct
func NetworkSecurityUserConfigurationID(input string) (*NetworkSecurityUserConfigurationId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := NetworkSecurityUserConfigurationId{
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
	if resourceId.SecurityConfigurationName, err = id.PopSegment("securityConfigurations"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}

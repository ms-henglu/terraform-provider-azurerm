package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
)

type NetworkSecurityConfigurationId struct {
	SubscriptionId            string
	ResourceGroup             string
	NetworkManagerName        string
	SecurityConfigurationName string
}

func NewNetworkSecurityConfigurationID(subscriptionId, resourceGroup, networkManagerName, securityConfigurationName string) NetworkSecurityConfigurationId {
	return NetworkSecurityConfigurationId{
		SubscriptionId:            subscriptionId,
		ResourceGroup:             resourceGroup,
		NetworkManagerName:        networkManagerName,
		SecurityConfigurationName: securityConfigurationName,
	}
}

func (id NetworkSecurityConfigurationId) String() string {
	segments := []string{
		fmt.Sprintf("Security Configuration Name %q", id.SecurityConfigurationName),
		fmt.Sprintf("Network Manager Name %q", id.NetworkManagerName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Network Security Configuration", segmentsStr)
}

func (id NetworkSecurityConfigurationId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkManagers/%s/securityConfigurations/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName)
}

// NetworkSecurityConfigurationID parses a NetworkSecurityConfiguration ID into an NetworkSecurityConfigurationId struct
func NetworkSecurityConfigurationID(input string) (*NetworkSecurityConfigurationId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := NetworkSecurityConfigurationId{
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

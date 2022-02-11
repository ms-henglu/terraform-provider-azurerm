package resourceguards

import "github.com/Azure/go-autorest/autorest"

type ResourceGuardsClient struct {
	Client  autorest.Client
	baseUri string
}

func NewResourceGuardsClientWithBaseURI(endpoint string) ResourceGuardsClient {
	return ResourceGuardsClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}

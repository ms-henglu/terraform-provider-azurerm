package operationstatus

import "github.com/Azure/go-autorest/autorest"

type OperationStatusClient struct {
	Client  autorest.Client
	baseUri string
}

func NewOperationStatusClientWithBaseURI(endpoint string) OperationStatusClient {
	return OperationStatusClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}

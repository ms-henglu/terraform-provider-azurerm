package backupvaults

type ResourceMoveDetails struct {
	CompletionTimeUtc  *string `json:"completionTimeUtc,omitempty"`
	OperationId        *string `json:"operationId,omitempty"`
	SourceResourcePath *string `json:"sourceResourcePath,omitempty"`
	StartTimeUtc       *string `json:"startTimeUtc,omitempty"`
	TargetResourcePath *string `json:"targetResourcePath,omitempty"`
}

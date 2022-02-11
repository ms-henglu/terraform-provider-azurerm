package recoverypoint

import "strings"

type CreatedByType string

const (
	CreatedByTypeApplication     CreatedByType = "Application"
	CreatedByTypeKey             CreatedByType = "Key"
	CreatedByTypeManagedIdentity CreatedByType = "ManagedIdentity"
	CreatedByTypeUser            CreatedByType = "User"
)

func PossibleValuesForCreatedByType() []string {
	return []string{
		string(CreatedByTypeApplication),
		string(CreatedByTypeKey),
		string(CreatedByTypeManagedIdentity),
		string(CreatedByTypeUser),
	}
}

func parseCreatedByType(input string) (*CreatedByType, error) {
	vals := map[string]CreatedByType{
		"application":     CreatedByTypeApplication,
		"key":             CreatedByTypeKey,
		"managedidentity": CreatedByTypeManagedIdentity,
		"user":            CreatedByTypeUser,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := CreatedByType(input)
	return &out, nil
}

type RehydrationStatus string

const (
	RehydrationStatusCOMPLETED        RehydrationStatus = "COMPLETED"
	RehydrationStatusCREATEINPROGRESS RehydrationStatus = "CREATE_IN_PROGRESS"
	RehydrationStatusDELETED          RehydrationStatus = "DELETED"
	RehydrationStatusDELETEINPROGRESS RehydrationStatus = "DELETE_IN_PROGRESS"
	RehydrationStatusFAILED           RehydrationStatus = "FAILED"
)

func PossibleValuesForRehydrationStatus() []string {
	return []string{
		string(RehydrationStatusCOMPLETED),
		string(RehydrationStatusCREATEINPROGRESS),
		string(RehydrationStatusDELETED),
		string(RehydrationStatusDELETEINPROGRESS),
		string(RehydrationStatusFAILED),
	}
}

func parseRehydrationStatus(input string) (*RehydrationStatus, error) {
	vals := map[string]RehydrationStatus{
		"completed":          RehydrationStatusCOMPLETED,
		"create_in_progress": RehydrationStatusCREATEINPROGRESS,
		"deleted":            RehydrationStatusDELETED,
		"delete_in_progress": RehydrationStatusDELETEINPROGRESS,
		"failed":             RehydrationStatusFAILED,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := RehydrationStatus(input)
	return &out, nil
}

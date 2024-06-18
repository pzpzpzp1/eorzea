extends Node

enum Roles {
	T1,H1,M1,R1,T2,H2,M2,R2
}
enum Party {
	LIGHT_PARTY, FULL_PARTY
}

static func string_to_enum(enum_string, enumtype):
	if enumtype.has(enum_string):
		return enumtype[enum_string]
	else:
		push_error("Invalid enum string: " + enum_string)
		return -1  

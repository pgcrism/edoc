indexing

	description:

		"Compare features according to their name."

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class FEATURE_COMPARATOR

inherit

	KL_PART_COMPARATOR [ET_FEATURE]

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

feature -- Status report

	less_than (u, v: ET_FEATURE): BOOLEAN is
			-- Is `u' considered less than `v'?
		do
			Result := STRING_.three_way_case_insensitive_comparison (u.name.name, v.name.name) = -1
		end

end

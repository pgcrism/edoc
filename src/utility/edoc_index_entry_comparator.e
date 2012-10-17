indexing

	description:

		"Compare index entries according to their name."

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_INDEX_ENTRY_COMPARATOR

inherit

	KL_PART_COMPARATOR [EDOC_INDEX_ENTRY]

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

feature -- Status report

	less_than (u, v: EDOC_INDEX_ENTRY): BOOLEAN is
			-- Is `u' considered less than `v'?
		do
			Result := STRING_.three_way_comparison (u.index_name, v.index_name) = -1
		end

end

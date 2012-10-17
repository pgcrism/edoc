indexing

	description:

		"Compare clusters according to their name."

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class CLUSTER_COMPARATOR

inherit

	KL_PART_COMPARATOR [ET_CLUSTER]

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

feature -- Status report

	less_than (u, v: ET_CLUSTER): BOOLEAN is
			-- Is `u' considered less than `v'?
		do
			Result := STRING_.three_way_comparison (u.name, v.name) = -1
		end

end

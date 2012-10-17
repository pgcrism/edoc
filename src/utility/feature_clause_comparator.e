indexing

	description:

		"Compare feature clauses according to order defined by the options"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class FEATURE_CLAUSE_COMPARATOR

inherit

	KL_PART_COMPARATOR [DS_PAIR [ET_FEATURE_CLAUSE, DS_PAIR [INTEGER, STRING]]]

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

feature -- Status report

	less_than (u, v: DS_PAIR [ET_FEATURE_CLAUSE, DS_PAIR [INTEGER, STRING]]): BOOLEAN is
			-- Is `u' considered less than `v'?
		local
			name_comparison: INTEGER
		do
			if u.second.first = v.second.first then
				name_comparison := STRING_.three_way_comparison (u.second.second, v.second.second)
				if name_comparison = -1 then
					Result := True
				else
					Result := u.first.clients.count < v.first.clients.count
				end
			else
				Result := u.second.first < v.second.first
			end
		end

end

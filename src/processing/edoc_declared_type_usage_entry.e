indexing

	description: "[

		Usage entry of a class which is used as a declared type of a feature
		TODO: implement usage page

	]"
	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_DECLARED_TYPE_USAGE_ENTRY

inherit

	EDOC_USAGE_ENTRY

feature -- Processing

	process (a_processor: EDOC_USAGE_PROCESSOR) is
			-- Process entry with `a_processor'.
		do
			a_processor.process_declared_type_entry (Current)
		end

end

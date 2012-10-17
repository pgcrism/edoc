indexing

	description: "[

		Usage entry of a class which is used as an argument of a feature
		TODO: implement usage page

	]"
	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_ARGUMENT_USAGE_ENTRY

inherit

	EDOC_USAGE_ENTRY

feature -- Processing

	process (a_processor: EDOC_USAGE_PROCESSOR) is
			-- Process entry with `a_processor'.
		do
			a_processor.process_argument_entry (Current)
		end

end

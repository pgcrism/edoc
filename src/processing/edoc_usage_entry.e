indexing

	description:

		"Entry of global index"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class EDOC_USAGE_ENTRY

feature -- Processing

	process (a_processor: EDOC_USAGE_PROCESSOR) is
			-- Process entry with `a_processor'.
		require
			a_processor_not_void: a_processor /= Void
		deferred
		end

end

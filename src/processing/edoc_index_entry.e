indexing

	description:

		"Entry of global index"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class EDOC_INDEX_ENTRY

feature -- Access

	index_name: STRING
			-- String representation of index
			-- This is used to sort the index and should be lowercase

feature -- Processing

	process (a_processor: EDOC_INDEX_PROCESSOR) is
			-- Process entry with `a_processor'.
		require
			a_processor_not_void: a_processor /= Void
		deferred
		end

invariant
	
	index_name_not_void: index_name /= Void

end

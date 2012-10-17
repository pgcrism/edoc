indexing

	description: 

		"Shared access to context singleton"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_SHARED_CONTEXT

feature -- Access

	Context: EDOC_CONTEXT is
			-- Eiffeldoc context
		once
			create Result.make
		ensure
			result_exists: Result /= Void
		end

end

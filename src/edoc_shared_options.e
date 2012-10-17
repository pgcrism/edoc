indexing

	description: 

		"Shared access to options singleton"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_SHARED_OPTIONS

feature -- Access

	Options: EDOC_OPTIONS is
			-- Eiffeldoc options
		once
			create Result.make
		ensure
			result_exists: Result /= Void
		end

end

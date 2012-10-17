indexing

	description: 

		"Shared access to error handler singleton"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_SHARED_ERROR_HANDLER

feature -- Access

	Error_handler: EDOC_ERROR_HANDLER is
			-- Error handler
		once
			create Result.make
		ensure
			result_exists: Result /= Void
		end

end

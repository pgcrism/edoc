indexing

	description: 

		"Shared access to html context singleton"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_SHARED_HTML_CONTEXT

feature -- Access

	html_context: EDOC_HTML_CONTEXT is
			-- Eiffeldoc context
		once
			create Result
		ensure
			result_exists: Result /= Void
		end

end

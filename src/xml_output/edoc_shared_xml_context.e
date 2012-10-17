indexing
	description:

		"Shared access to XML context singleton"

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-23 13:50:29 -0800 (Fre, 23 Feb 2007) $"
	revision: "$Revision: 2548 $"

class EDOC_SHARED_XML_CONTEXT

feature -- Access

	xml_context: EDOC_XML_CONTEXT is
			-- Eiffeldoc context
		once
			create Result
		ensure
			result_exists: Result /= Void
		end

end

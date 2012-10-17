indexing

	description:

		"Usage processor"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class EDOC_USAGE_PROCESSOR

feature -- Processing

	process_argument_entry (an_entry: EDOC_ARGUMENT_USAGE_ENTRY) is
			-- Process `an_entry'.
		require
			an_entry_not_void: an_entry /= Void
		deferred
		end

	process_declared_type_entry (an_entry: EDOC_DECLARED_TYPE_USAGE_ENTRY) is
			-- Process `an_entry'.
		require
			an_entry_not_void: an_entry /= Void
		deferred
		end

end

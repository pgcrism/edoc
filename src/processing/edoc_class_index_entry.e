indexing

	description:

		"Index entry of a class"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_CLASS_INDEX_ENTRY

inherit
	
	EDOC_INDEX_ENTRY

create
	
	make

feature {NONE} -- Initialisation

	make (a_class: ET_CLASS) is
			-- Initialise with `a_class'.
		require
			a_class_not_void: a_class /= Void
		do
			et_class := a_class
			index_name := a_class.name.name.as_lower
		ensure
			et_class_set: et_class = a_class
		end

feature -- Access

	et_class: ET_CLASS
			-- Class of entry

feature -- Processing

	process (a_processor: EDOC_INDEX_PROCESSOR) is
			-- Process class entry with `a_processor'.
		do
			a_processor.process_class_entry (Current)
		end

invariant

	et_class_not_void: et_class /= Void

end

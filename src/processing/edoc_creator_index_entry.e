indexing

	description:

		"Index entry of a creator"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_CREATOR_INDEX_ENTRY

inherit
	
	EDOC_INDEX_ENTRY

create
	
	make

feature {NONE} -- Initialisation

	make (a_class: ET_CLASS; a_feature: ET_FEATURE) is
			-- Initialise with`a_class' and`a_feature'.
		require
			a_class_not_void: a_class /= Void
			a_feature_not_void: a_feature /= Void
		do
			et_class := a_class
			et_feature := a_feature
			index_name := a_feature.name.name.as_lower
		ensure
			et_class_set: et_class = a_class
			et_feature_set: et_feature = a_feature
		end

feature -- Access

	et_class: ET_CLASS
			-- Class 

	et_feature: ET_FEATURE
			-- Creator feature of `et_class'

feature -- Processing

	process (a_processor: EDOC_INDEX_PROCESSOR) is
			-- Process cluster entry with `a_processor'.
		do
			a_processor.process_creator_entry (Current)
		end

invariant

	et_class_not_void: et_class /= Void
	et_feature_not_void: et_feature /= Void

end

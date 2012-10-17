indexing

	description:

		"Index entry of a feature"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_FEATURE_INDEX_ENTRY

inherit
	
	EDOC_INDEX_ENTRY

create
	
	make

feature {NONE} -- Initialisation

	make (a_feature: ET_FEATURE) is
			-- Initialise with `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			et_feature := a_feature
			index_name := a_feature.name.name.as_lower
		ensure
			et_feature_set: et_feature = a_feature
		end

feature -- Access

	et_feature: ET_FEATURE
			-- Feature of entry

feature -- Processing

	process (a_processor: EDOC_INDEX_PROCESSOR) is
			-- Process cluster entry with `a_processor'.
		do
			a_processor.process_feature_entry (Current)
		end

invariant

	et_feature_not_void: et_feature /= Void

end

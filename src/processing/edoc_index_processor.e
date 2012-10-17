indexing

	description:

		"Index processor"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class EDOC_INDEX_PROCESSOR

feature -- Processing

	process_cluster_entry (an_entry: EDOC_CLUSTER_INDEX_ENTRY) is
			-- Process `an_entry'.
		require
			an_entry_not_void: an_entry /= Void
		deferred
		end

	process_class_entry (an_entry: EDOC_CLASS_INDEX_ENTRY) is
			-- Process `an_entry'.
		require
			an_entry_not_void: an_entry /= Void
		deferred
		end

	process_feature_entry (an_entry: EDOC_FEATURE_INDEX_ENTRY) is
			-- Process `an_entry'.
		require
			an_entry_not_void: an_entry /= Void
		deferred
		end

	process_creator_entry (an_entry: EDOC_CREATOR_INDEX_ENTRY) is
			-- Process `an_entry'.
		require
			an_entry_not_void: an_entry /= Void
		deferred
		end

end

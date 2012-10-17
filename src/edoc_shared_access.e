indexing

	description: 

		"Access to shared error handler, options and context"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_SHARED_ACCESS

inherit
	
	ANY

	EDOC_SHARED_ERROR_HANDLER
		export {NONE} all end

	EDOC_SHARED_OPTIONS
		export {NONE} all end

	EDOC_SHARED_CONTEXT
		export {NONE} all end

feature -- Access

	Cluster_sorter: DS_QUICK_SORTER [ET_CLUSTER] is
			-- Shared cluster sorter
		local
			a_comparator: CLUSTER_COMPARATOR
		once
			create a_comparator
			create Result.make (a_comparator)
		ensure
			result_not_void: Result /= Void
		end

	Class_sorter: DS_QUICK_SORTER [ET_CLASS] is
			-- Shared class sorter
		local
			a_comparator: CLASS_COMPARATOR
		once
			create a_comparator
			create Result.make (a_comparator)
		ensure
			result_not_void: Result /= Void
		end

	Feature_sorter: DS_QUICK_SORTER [ET_FEATURE] is
			-- Shared feature sorter.
		local
			a_comparator: FEATURE_COMPARATOR
		once
			create a_comparator
			create Result.make (a_comparator)
		ensure
			result_not_void: Result /= Void
		end

	Feature_clause_sorter: DS_QUICK_SORTER [DS_PAIR [ET_FEATURE_CLAUSE, DS_PAIR [INTEGER, STRING]]] is
			-- Shared feature sorter.
		local
			a_comparator: FEATURE_CLAUSE_COMPARATOR
		once
			create a_comparator
			create Result.make (a_comparator)
		ensure
			result_not_void: Result /= Void
		end

	Index_sorter: DS_QUICK_SORTER [EDOC_INDEX_ENTRY] is
			-- Shared index sorter
		local
			a_comparator: EDOC_INDEX_ENTRY_COMPARATOR
		once
			create a_comparator
			create Result.make (a_comparator)
		ensure
			result_not_void: Result /= Void
		end

end

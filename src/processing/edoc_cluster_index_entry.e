indexing

	description:

		"Index entry of a cluster"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_CLUSTER_INDEX_ENTRY

inherit
	
	EDOC_INDEX_ENTRY

create
	
	make

feature {NONE} -- Initialisation

	make (a_cluster: ET_CLUSTER) is
			-- Initialise with `a_cluster'.
		require
			a_cluster_not_void: a_cluster /= Void
		do
			cluster := a_cluster
			index_name := a_cluster.name.as_lower
		ensure
			cluster_set: cluster = a_cluster
		end

feature -- Access

	cluster: ET_CLUSTER
			-- Cluster of entry

feature -- Processing

	process (a_processor: EDOC_INDEX_PROCESSOR) is
			-- Process cluster entry with `a_processor'.
		do
			a_processor.process_cluster_entry (Current)
		end

invariant

	cluster_not_void: cluster /= Void

end

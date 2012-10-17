indexing

	description: "[

		Documentation context including the eiffel parser universe and 
		information about included clusters and classes

	]"
	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_CONTEXT

inherit

	ANY

	EDOC_SHARED_ACCESS
		export {NONE} all end

	DT_SHARED_SYSTEM_CLOCK
		export {NONE} all end

	KL_SHARED_FILE_SYSTEM
		export {NONE} all end

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

	KL_IMPORTED_CHARACTER_ROUTINES
		export {NONE} all end

create

	make

feature {NONE} -- Initialization

	make is
			-- Initialise context.
		do
			create clusters.make_empty
			create top_level_clusternames.make_equal
			create documented_clusters.make_equal (100)
			create documented_classes.make_equal (5000)
			create global_index.make_equal (10000)
			create global_usage.make_equal (5000)
		end

feature -- Access

	clusters: ET_CLUSTERS
			-- Clusters

	universe: ET_UNIVERSE
			-- Universe

	top_level_clusternames: DS_LINKED_LIST [STRING]
			-- Included top-level clusters

	documented_clusters: DS_ARRAYED_LIST [ET_CLUSTER]
			-- Clusters for which a documentation is generated

	documented_classes: DS_ARRAYED_LIST [ET_CLASS]
			-- Classes for which a documentation is generated

	global_index: DS_ARRAYED_LIST [EDOC_INDEX_ENTRY]
			-- Global index list

	global_usage: DS_HASH_TABLE [DS_LIST [EDOC_USAGE_ENTRY], ET_CLASS]
			-- Global usage map

	output_generator: EDOC_OUTPUT
			-- Output generator

feature -- Element change

	add_clusters (a_clusters: ET_CLUSTERS; include_clusters: BOOLEAN) is
			-- Add 'a_clusters' to 'clusters'.
			-- If 'include_clusters' is True also add clustesr to 'included_clusters'.
		require
			a_clusters_not_void: a_clusters /= Void
		local
			a_cluster_cursor: DS_LIST_CURSOR [ET_CLUSTER]
		do
			clusters.clusters.append_last (a_clusters.clusters)
			if include_clusters then
				a_cluster_cursor := a_clusters.clusters.new_cursor
				from
					a_cluster_cursor.start
				until
					a_cluster_cursor.after
				loop
					top_level_clusternames.put_last (a_cluster_cursor.item.prefixed_name)
					a_cluster_cursor.forth
				end
			end
		end

	set_output_generator (a_generator: like output_generator) is
			-- Set 'output_generator' to 'a_generator'.
		require
			a_generator_not_void: a_generator /= Void
		do
			output_generator := a_generator
		ensure
			output_generator_set: output_generator = a_generator
		end

feature -- Basic operations

	generate_universe is
			-- Generate universe.
		local
			decorated_ast_factory: ET_DECORATED_AST_FACTORY
			an_error_handler: ET_ERROR_HANDLER
		do
			if an_error_handler = Void then
				create an_error_handler.make_standard
			end

			create decorated_ast_factory.make
			decorated_ast_factory.set_keep_all_breaks (True)

			if universe = Void then
				create universe.make (clusters, an_error_handler)
				universe.set_ast_factory (decorated_ast_factory)
				universe.set_use_assign_keyword (True)
				universe.set_use_attribute_keyword (False)
				universe.set_use_convert_keyword (True)
				universe.set_use_recast_keyword (False)
				universe.set_use_reference_keyword (True)
				universe.set_use_void_keyword (True)
				universe.activate_processors
			end
		ensure
			universe_generated: universe /= Void
		end

	parse_universe is
			-- Parse 'universe'
		require
			universe_generated: universe /= Void
		local
			start_time: INTEGER
			a_time: DT_TIME
			dummy_classes: DS_LIST_CURSOR [STRING]
			a_class: ET_CLASS
		do
			start_time := system_clock.time_now.millisecond_count

			-- Parsing
			Error_handler.report_message ("EiffelParser: Parsing all - Start: "+system_clock.time_now.time_out)
			universe.parse_all
			universe.check_provider_validity
			Error_handler.report_message ("EiffelParser: Parsing done - Finish: "+system_clock.time_now.time_out)

			-- dummy classes
			from
				dummy_classes := options.dummy_classes.new_cursor
				dummy_classes.start
			until
				dummy_classes.off
			loop
				a_class := universe.class_by_name (dummy_classes.item)
				if a_class = Void then
					Error_handler.report_message ("Creating dummy class: "+a_class.name.name)
					a_class := universe.eiffel_class (create {ET_IDENTIFIER}.make (dummy_classes.item))
				else
					Error_handler.report_message ("Clearing dummy class: "+a_class.name.name)
					a_class.feature_clauses.wipe_out
					a_class.procedures.wipe_out
					a_class.procedures.set_declared_count (0)
					a_class.queries.wipe_out
					a_class.queries.set_declared_count (0)
				end
				dummy_classes.forth
			end

			Error_handler.report_message ("EiffelParser: Compiling degree 4 - Start: "+system_clock.time_now.time_out)
			universe.compile_degree_4
			Error_handler.report_message ("EiffelParser: Compiling done - Finish: "+system_clock.time_now.time_out)
			create a_time.make_from_millisecond_count (system_clock.time_now.millisecond_count-start_time)
			Error_handler.report_message ("EiffelParser: Total time: "+a_time.time_out)
		ensure
			universe_parsed: universe.is_preparsed
		end

	generate_documentation is
			-- Generate documentation.
		require
			universe_parsed: universe.is_preparsed
			output_generator_not_void: output_generator /= Void
		do
			index_clusters
			index_classes
			index_features

			processing_count := documented_clusters.count + documented_classes.count

			nested_directory_level := 0
			Error_handler.report_message ("Entering directory: "+Options.output_directory)
			output_generator.set_output_directory (Options.output_directory)

			process_clusters (universe.clusters.clusters)

			nested_directory_level := 0
			Error_handler.report_message ("Entering directory: "+Options.output_directory)
			output_generator.set_output_directory (Options.output_directory)

			if Options.is_index_generated then
				Error_handler.report_message ("Generating index")
				Index_sorter.sort (global_index)
				output_generator.generate_index (global_index)
			end
			if Options.is_classes_file_generated then
				Error_handler.report_message ("Generating classes file")
				output_generator.generate_classes_file (documented_classes)
			end
			if Options.is_clusters_file_generated then
				Error_handler.report_message ("Generating clusters file")
				output_generator.generate_clusters_file (documented_clusters)
			end
			if Options.is_overview_generated then
				Error_handler.report_message ("Generating overview")
				output_generator.generate_overview
			end
			output_generator.generate_additional_files
			Error_handler.report_message ("Documentation finished")
		end

feature -- Links

	relative_output_directory: STRING is
			-- Relative path to output directory
		local
			i: INTEGER
		do
			create Result.make_empty
			from i := 0 until i = nested_directory_level loop
				Result.append_string ("../")
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
		end

	cluster_file_directory (a_cluster: ET_CLUSTER): STRING is
			-- Generate cluster file path for `a_cluster' relative to output directory.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_parent: ET_CLUSTER
		do
			create Result.make_from_string (a_cluster.name)
			from
				a_parent := a_cluster.parent
			until
				a_parent = Void
			loop
				Result := STRING_.concat (a_parent.name+"/", Result)
				a_parent := a_parent.parent
			end
		ensure
			result_exists: Result /= Void
		end

	relative_cluster_directory (a_cluster: ET_CLUSTER): STRING is
			-- Relative path to directory of `a_cluster'.
		require
			a_cluster_not_void: a_cluster /= Void
		do
			if Options.is_output_flat then
				Result := relative_output_directory
			else
				Result := relative_output_directory+cluster_file_directory (a_cluster)
			end
		ensure
			result_exists: Result /= Void
		end

feature {NONE} -- Implementation

	processing_count: INTEGER
			-- Total number of clusters and classes which need processing

	nested_directory_level: INTEGER
			-- Nested directories from output directory

	index_clusters is
			-- Index all clusters which will be processed.
		local
			a_cluster_cursor: DS_LIST_CURSOR [ET_CLUSTER]
			a_cluster: ET_CLUSTER
			an_index_entry: EDOC_CLUSTER_INDEX_ENTRY
		do
			Error_handler.report_message ("Indexing clusters")
			Cluster_sorter.sort (universe.clusters.clusters)
			a_cluster_cursor := universe.clusters.clusters.new_cursor
			from
				a_cluster_cursor.start
			until
				a_cluster_cursor.after
			loop
				a_cluster := a_cluster_cursor.item
				if top_level_clusternames.has (a_cluster.prefixed_name) and not Options.ignored_clusters.has (a_cluster.prefixed_name) then
					documented_clusters.force_last (a_cluster)
					create an_index_entry.make (a_cluster)
					global_index.force_last (an_index_entry)
					if a_cluster.subclusters /= Void then
						index_subclusters (a_cluster.subclusters)
					end
				else
					Error_handler.report_message ("Ignoring cluster '"+a_cluster.prefixed_name+"'")
				end
				a_cluster_cursor.forth
			end
			documented_clusters.sort (Cluster_sorter)
			Error_handler.report_message ("Done ("+documented_clusters.count.out+" clusters selected)")
		end

	index_subclusters (subclusters: ET_CLUSTERS) is
			-- Index subclusters according to 'ignored_clusters'.
		local
			a_cluster_cursor: DS_LIST_CURSOR [ET_CLUSTER]
			a_cluster: ET_CLUSTER
			an_index_entry: EDOC_CLUSTER_INDEX_ENTRY
		do
			Cluster_sorter.sort (subclusters.clusters)
			a_cluster_cursor := subclusters.clusters.new_cursor
			from
				a_cluster_cursor.start
			until
				a_cluster_cursor.after
			loop
				a_cluster := a_cluster_cursor.item
				if Options.ignored_clusters.has (a_cluster.prefixed_name) then
					Error_handler.report_message ("Ignoring cluster '"+a_cluster.prefixed_name+"'")
				else
					documented_clusters.force_last (a_cluster)
					create an_index_entry.make (a_cluster)
					global_index.force_last (an_index_entry)
					if a_cluster.subclusters /= Void then
						index_subclusters (a_cluster.subclusters)
					end
				end
				a_cluster_cursor.forth
			end
		end

	index_classes is
			-- Index all classes which will be processed.
		local
			a_class_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
			a_class: ET_CLASS
			an_index_entry: EDOC_CLASS_INDEX_ENTRY
		do
			Error_handler.report_message ("Indexing classes")
			a_class_cursor := universe.classes.new_cursor
			from
				a_class_cursor.start
			until
				a_class_cursor.after
			loop
				a_class := a_class_cursor.item
				if a_class.group /= Void and then a_class.group.cluster /= Void and then documented_clusters.has (a_class.group.cluster) then
					documented_classes.force_last (a_class)
					create an_index_entry.make (a_class)
					global_index.force_last (an_index_entry)
				end
				a_class_cursor.forth
			end
			Class_sorter.sort (documented_classes)
			Error_handler.report_message ("Done ("+documented_classes.count.out+" classes selected)")
		end

	index_features is
			-- Index all features from processed classes.
		local
			a_class_cursor: DS_LIST_CURSOR [ET_CLASS]
			a_class: ET_CLASS
		do
			Error_handler.report_message ("Indexing features")
			a_class_cursor := documented_classes.new_cursor
			from
				a_class_cursor.start
			until
				a_class_cursor.after
			loop
				a_class := a_class_cursor.item
				if Options.is_index_generated then
					-- Index all creators from a_class (also inherited creators)

					-- Index features which are new or redefined in a_class and have the right export status (i.e. don't list inherited features)

				end
				if Options.are_usage_files_generated then

				end
				a_class_cursor.forth
			end
			Error_handler.report_message ("Done")
		end

	process_clusters (a_cluster_list: DS_LIST [ET_CLUSTER]) is
			-- Process 'a_clusters'.
		require
			a_cluster_list_not_void: a_cluster_list /= Void
		local
			a_cluster_cursor: DS_LIST_CURSOR [ET_CLUSTER]
		do
			a_cluster_cursor := a_cluster_list.new_cursor
			from
				a_cluster_cursor.start
			until
				a_cluster_cursor.after
			loop
				if documented_clusters.has (a_cluster_cursor.item) then
					process_cluster (a_cluster_cursor.item)
				end
				a_cluster_cursor.forth
			end
		end

	process_cluster (a_cluster: ET_CLUSTER) is
			-- Process 'a_cluster'.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			previous_directory: STRING
			a_class_cursor: DS_LIST_CURSOR [ET_CLASS]
		do
			-- Change to cluster directory
			if not Options.is_output_flat then
				previous_directory := output_generator.output_directory
				output_generator.set_output_directory (file_system.pathname (output_generator.output_directory, a_cluster.name.as_lower))
				nested_directory_level := nested_directory_level + 1
				Error_handler.report_message ("Entering directory: "+output_generator.output_directory)
			end

			Error_handler.report_message (processing_count.out+" Processing cluster '"+a_cluster.name+"'")
			processing_count := processing_count - 1

			if Options.are_cluster_files_generated then
				output_generator.generate_cluster_file (a_cluster)
			end

			a_class_cursor := universe.classes_by_group (a_cluster).new_cursor
			from
				a_class_cursor.start
			until
				a_class_cursor.after
			loop
				if documented_classes.has (a_class_cursor.item) then
					process_class (a_class_cursor.item)
				end
				a_class_cursor.forth
			end

			if a_cluster.subclusters /= Void then
				process_clusters (a_cluster.subclusters.clusters)
			end

			-- Change directory back to old directory
			if not Options.is_output_flat then
				output_generator.set_output_directory (previous_directory)
				nested_directory_level := nested_directory_level - 1
			end
		end

	process_class (a_class: ET_CLASS) is
			-- Process 'a_class'.
		require
			a_class_not_void: a_class /= Void
		do
			Error_handler.report_message (processing_count.out+" Processing class '"+a_class.name.name+"'")
			processing_count := processing_count - 1

			output_generator.generate_class_file (a_class)
		end

end

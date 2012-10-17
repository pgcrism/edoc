indexing

	description:

		"Base class of all output formats"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class EDOC_OUTPUT

inherit

	KL_SHARED_FILE_SYSTEM

	EDOC_SHARED_ACCESS

feature -- Access

	default_options_filename: STRING
			-- Name of default options file

	output_directory: STRING
			-- Directory to store generated files

feature -- Element change

	set_output_directory (a_directory: STRING) is
			-- Set 'output_directory' to 'a_directory'.
		require
			a_directory_not_void: a_directory /= Void
		do
			output_directory := file_system.canonical_pathname (a_directory)
			if not file_system.directory_exists (output_directory) then
				file_system.recursive_create_directory (output_directory)
			end
			if not file_system.directory_exists (output_directory) then
				Error_handler.raise_error (Error_handler.Error_create_directory, << a_directory >>)
			end
		ensure
			output_directory_set: output_directory.is_equal (file_system.canonical_pathname (a_directory))
			output_direcotry_exists: file_system.directory_exists (a_directory)
		end

feature -- File creation

	options_file (a_filename: STRING): EDOC_OPTIONS_FILE is
			-- Create an options file for 'a_filename'.
		require
			a_filename_not_void: a_filename /= Void
		deferred
		ensure
			options_file_not_void: Result /= Void
		end

	generate_cluster_file (a_cluster: ET_CLUSTER) is
			-- Generate file for 'a_cluster' in 'output_directory'.
		require
			a_cluster_not_void: a_cluster /= Void
			output_directory_not_void: output_directory /= Void
			output_directory_exists: file_system.directory_exists (output_directory)
		deferred
		end

	generate_class_file (a_class: ET_CLASS) is
			-- Generate file for 'a_class' in 'output_directory'.
		require
			a_class_not_void: a_class /= Void
			output_directory_not_void: output_directory /= Void
			output_directory_exists: file_system.directory_exists (output_directory)
		deferred
		end

	generate_usage_file (a_class: ET_CLASS) is
			-- Generate usage file for 'a_class' in 'output_directory'.
		require
			a_class_not_void: a_class /= Void
			output_directory_not_void: output_directory /= Void
			output_directory_exists: file_system.directory_exists (output_directory)
		deferred
		end

	generate_classes_file (a_class_list: DS_LIST [ET_CLASS]) is
			-- Generate file for 'a_class_list' in 'output_directory'.
		require
			a_class_list_not_void: a_class_list /= Void
			output_directory_not_void: output_directory /= Void
			output_directory_exists: file_system.directory_exists (output_directory)
		deferred
		end

	generate_clusters_file (a_cluster_list: DS_LIST [ET_CLUSTER]) is
			-- Generate file for 'a_cluster_list' in 'output_directory'.
		require
			a_cluster_list_not_void: a_cluster_list /= Void
			output_directory_not_void: output_directory /= Void
			output_directory_exists: file_system.directory_exists (output_directory)
		deferred
		end

	generate_index (an_index_list: DS_LIST [EDOC_INDEX_ENTRY]) is
			-- Generate index for 'an_index_list' in 'output_directory'.
		require
			an_index_list_not_void: an_index_list /= Void
			an_index_list_sorted: Index_sorter.sorted (an_index_list)
			output_directory_not_void: output_directory /= Void
			output_directory_exists: file_system.directory_exists (output_directory)
		deferred
		end
		
	generate_overview is
			-- Generate overview in 'output_directory'.
		require
			output_directory_not_void: output_directory /= Void
			output_directory_exists: file_system.directory_exists (output_directory)
		deferred
		end

	generate_additional_files is
			-- Generate additional files needed for output.
		require
			output_directory_not_void: output_directory /= Void
			output_directory_exists: file_system.directory_exists (output_directory)
		deferred
		end

invariant

	default_options_file_not_void: default_options_filename /= Void

end

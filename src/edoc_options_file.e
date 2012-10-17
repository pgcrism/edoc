indexing

	description:

		"Options file"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_OPTIONS_FILE

inherit

	ANY

	EDOC_SHARED_ACCESS
		export {NONE} all end

	KL_SHARED_FILE_SYSTEM
		export {NONE} all end

	KL_SHARED_EXECUTION_ENVIRONMENT
		export {NONE} all end

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

create

	make_from_filename

feature {NONE} -- Initialisation

	make_from_filename (a_filename: STRING) is
			-- Initialise options from `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
		do
			dirname := file_system.dirname (file_system.canonical_pathname (a_filename))
			filename := a_filename

			create option_processors.make_equal (40)

			-- Input options
			option_processors.put (agent process_ace (?), "ace")
			option_processors.put (agent process_system (?), "system")
			option_processors.put (agent process_library (?), "library")
			option_processors.put (agent process_mount (?), "mount")
			option_processors.put (agent process_boolean (?, agent Options.set_mounted_libraries_included (?)), "include_mounted_libraries")
			option_processors.put (agent process_ignored_clusters (?), "ignored_clusters")

			option_processors.put (agent process_env (?), "env")
			option_processors.put (agent process_env_default (?), "env-default")

			-- Parser options
			option_processors.put (agent process_boolean (?, agent Options.set_classes_flat (?)), "flatten_classes")
			option_processors.put (agent process_ignored_indexing_tags (?), "ignore_indexing")
			option_processors.put (agent process_boolean (?, agent Options.set_inherit_export_none_ignored (?)), "ignore_inherit_export_none")
			option_processors.put (agent process_ignore_inherit_classes (?), "ignore_inherit_classes")
			option_processors.put (agent process_boolean (?, agent Options.set_feature_clause_export_none_ignored (?)), "ignore_features_export_none")
			option_processors.put (agent process_feature_clause_order_file (?), "feature_clause_order_file")
			option_processors.put (agent process_ignore_feature_clauses (?), "ignore_feature_clauses")

			option_processors.put (agent process_dummy_classes (?), "dummy_classes")

			-- Output options
			option_processors.put (agent process_output_directory (?), "output_directory")
			option_processors.put (agent process_boolean (?, agent Options.set_output_flat (?)), "flat_output")
			option_processors.put (agent process_boolean (?, agent Options.set_feature_list_generated (?)), "generate_feature_list")
			option_processors.put (agent process_boolean (?, agent Options.set_ancestors_list_generated (?)), "generate_ancestors_list")
			option_processors.put (agent process_boolean (?, agent Options.set_descendants_list_generated (?)), "generate_descendants_list")
			option_processors.put (agent process_boolean (?, agent Options.set_inherit_tree_generated (?)), "generate_inherit_tree")
			option_processors.put (agent process_boolean (?, agent Options.set_cluster_files_generated (?)), "generate_cluster_files")
			option_processors.put (agent process_boolean (?, agent Options.set_index_generated (?)), "generate_index")
			option_processors.put (agent process_boolean (?, agent Options.set_index_all_generated (?)), "generate_index_all")
			option_processors.put (agent process_boolean (?, agent Options.set_usage_files_generated (?)), "generate_usage")
			option_processors.put (agent process_boolean (?, agent Options.set_classes_file_generated (?)), "generate_classes_file")
			option_processors.put (agent process_boolean (?, agent Options.set_clusters_file_generated (?)), "generate_clusters_file")
			option_processors.put (agent process_boolean (?, agent Options.set_overview_generated (?)), "generate_overview")

		end

feature -- Access

	dirname: STRING
			-- Options directory name

	filename: STRING
			-- Options filename

	option_processors: DS_HASH_TABLE [PROCEDURE [ANY, TUPLE [STRING]], STRING]
			-- Option processors

feature -- Basic operations

	apply_options is
			-- Apply options to `Options'.
		local
			input_file: KL_TEXT_INPUT_FILE
		do
			create input_file.make (filename)
			input_file. open_read
			if not input_file.exists then
				Error_handler.raise_error (Error_handler.Error_options_file_doesnt_exist, << filename >>)
			end
			if not input_file.is_open_read then
				Error_handler.raise_error (Error_handler.Error_options_file_open_read_failed, << filename >>)
			end
			from until input_file.end_of_file loop
				input_file.read_line
				if input_file.last_string.count > 0 and then input_file.last_string.item (1) /= '#' then
					process_line (input_file.last_string)
				end
			end
		end

feature {NONE} -- Implementation

	current_line: STRING
			-- Current options line

	process_line (a_line: STRING) is
			-- Process`a_line'.
		require
			a_line_not_void: a_line /= Void
		local
			i: INTEGER
			option, operand: STRING
		do
			current_line := a_line
			i := a_line.index_of ('=', 1)
			if i > 1 then
				option := a_line.substring (1, i-1)
				operand := a_line.substring (i+1, a_line.count)
				option.to_lower
				prune_string (option)
				prune_string (operand)
				if option_processors.has (option) then
					option_processors.item (option).call ([operand])
				else
					Error_handler.raise_warning (Error_handler.Error_unknown_option, << option, filename >>)
				end
			else
				Error_handler.raise_warning (Error_handler.Error_invalid_option_line, << a_line, filename >>)
			end
		end

	prune_string (a_string: STRING) is
			-- Prune all leading and trailing spaces and tabs.
		do
			STRING_.right_adjust (a_string)
			STRING_.left_adjust (a_string)
		end

	process_boolean (a_value: STRING; a_setter: PROCEDURE [ANY, TUPLE [BOOLEAN]]) is
			-- Call `a_setter' with `a_value'.
		do
			if a_value.as_lower.is_equal ("yes") or a_value.as_lower.is_equal ("true") then
				a_setter.call ([True])
			elseif a_value.as_lower.is_equal ("no") or a_value.as_lower.is_equal ("false") then
				a_setter.call ([False])
			else
				Error_handler.raise_warning (Error_handler.Error_invalid_boolean_option, << a_value, current_line >>)
			end
		end

	process_string (a_value: STRING; a_setter: PROCEDURE [ANY, TUPLE [STRING]]) is
			-- Call `a_setter' with `a_value'.
		do
			a_setter.call ([a_value])
		end

	process_ace (a_value: STRING) is
			-- Process 'ace' option.
		do
			Options.set_ace_file (file_system.absolute_pathname (Execution_environment.interpreted_string (a_value)))
		end

	process_system (a_value: STRING) is
			-- Process 'system' option.
		do
			Options.set_xace_system (file_system.absolute_pathname (Execution_environment.interpreted_string (a_value)))
		end

	process_library (a_value: STRING) is
			-- Process 'library' option.
		do
			Options.set_xace_library (file_system.absolute_pathname (Execution_environment.interpreted_string (a_value)))
		end

	process_mount (a_value: STRING) is
			-- Process 'mount' option.
		do
			Options.mounted_libraries.put_last (file_system.absolute_pathname (Execution_environment.interpreted_string (a_value)))
		end

	process_ignored_clusters (a_value: STRING) is
			-- Process 'ignored_clusters' option.
		do
			Options.ignored_clusters.wipe_out
			Options.ignored_clusters.extend_last (string_to_string_list (a_value))
		end

	process_ignored_indexing_tags (a_value: STRING) is
			-- Process 'ignore_indexing' option.
		do
			Options.ignored_indexing_tags.wipe_out
			Options.ignored_indexing_tags.extend_last (string_to_string_list (a_value))
		end

	process_output_directory (a_value: STRING) is
			-- Process 'output_directory' option.
		local
			a_dirname: STRING
		do
			a_dirname := file_system.canonical_pathname (file_system.absolute_pathname (Execution_environment.interpreted_string (a_value)))
			Options.set_output_direcotry (a_dirname)
		end

	process_feature_clause_order_file (a_value: STRING) is
			-- Process 'feature_clause_order_file' option.
		local
			a_filename: STRING
		do
			a_filename := file_system.absolute_pathname (Execution_environment.interpreted_string (a_value))
			if not file_system.file_exists (a_filename) then
				a_filename := file_system.pathname (dirname, Execution_environment.interpreted_string (a_value))
			end
			if file_system.file_exists (a_filename) then
				Options.feature_clause_order.wipe_out
				Options.feature_clause_order.extend_last (file_to_string_list (a_filename))
			else
				Error_handler.raise_warning (Error_handler.Error_feature_order_file_not_found, << a_value >>)
			end
			Options.feature_clause_order.start
			Options.feature_clause_order.search_forth ("$user_defined$")
			if Options.feature_clause_order.index > 0 then
				Options.set_user_defined_feature_clause_index (Options.feature_clause_order.index)
			else
				Options.set_user_defined_feature_clause_index (Options.feature_clause_order.count + 1)
			end
		end

	process_ignore_inherit_classes (a_value: STRING) is
			-- Process 'ignore_inherit_classes' option.
		do
			Options.ignored_inherit_classes.extend_last (string_to_string_list (a_value))
		end

	process_ignore_feature_clauses (a_value: STRING) is
			-- Process 'ignore_feature_clauses' option.
		do
			Options.ignored_feature_clauses.extend_last (string_to_string_list (a_value))
		end

	process_env (a_value: STRING) is
			-- Process 'env' option.
		local
			env_value: DS_PAIR [STRING, STRING]
		do
			env_value := split_string (a_value, '=')
			if env_value = Void then
				Error_handler.raise_warning (Error_handler.Error_invalid_env_option, << a_value, current_line >>)
			else
				Execution_environment.set_variable_value (env_value.first, env_value.second)
			end
		end

	process_env_default (a_value: STRING) is
			-- Process 'env_defualt' options.
		local
			env_value: DS_PAIR [STRING, STRING]
			old_value: STRING
		do
			env_value := split_string (a_value, '=')
			if env_value = Void then
				Error_handler.raise_warning (Error_handler.Error_invalid_env_option, << a_value, current_line >>)
			else
				old_value := Execution_environment.variable_value (env_value.first)
				if old_value = Void then
					Execution_environment.set_variable_value (env_value.first, env_value.second)
				end
			end
		end

	process_dummy_classes (a_value: STRING) is
			-- Process 'dummy_classes' option.
		do
			Options.dummy_classes.extend_last (string_to_string_list (a_value))
		end


	string_to_string_list (a_string: STRING): DS_LIST [STRING] is
			-- Parse 'a_string' and return the list of entries.
		require
			a_string_not_void: a_string /= Void
		local
			splitter: ST_SPLITTER
		do
			create splitter.make
			splitter.set_separators (" ,%T")
			Result := splitter.split (a_string)
		end

	file_to_string_list (a_filename: STRING): DS_LIST [STRING] is
			-- Parse 'a_filename' and read all non-empty lines which don't start with a '#'.
		require
			a_filename_not_void: a_filename /= Void
		local
			a_file: KL_TEXT_INPUT_FILE
			a_string: STRING
		do
			create {DS_LINKED_LIST [STRING]}Result.make
			if file_system.file_exists (a_filename) then
				create a_file.make (a_filename)
				a_file.open_read
				if a_file.is_open_read then
					from
					until
						a_file.end_of_file
					loop
						a_file.read_line
						if a_file.last_string.count > 0 and then a_file.last_string.item (1) /= '#' then
							create a_string.make_from_string (a_file.last_string)
							prune_string (a_string)
							Result.force_last (a_string)
						end
					end
				else
					Error_handler.raise_warning (Error_handler.Error_file_not_readable, << a_filename >>)
				end
			else
				Error_handler.raise_warning (Error_handler.Error_file_not_found, << a_filename >>)
			end
		end

	split_string (a_string: STRING; a_split_character: CHARACTER): DS_PAIR [STRING, STRING] is
			-- Split 'a_string' at 'a_split_character'.
		require
			a_string_not_void: a_string /= Void
		local
			first_part, second_part: STRING
			i: INTEGER
		do
			i := a_string.index_of ('=', 1)
			if i > 1 then
				first_part := a_string.substring (1, i-1)
				second_part := a_string.substring (i+1, a_string.count)
				prune_string (first_part)
				prune_string (second_part)
				create Result.make (first_part, second_part)
			end
		end

end

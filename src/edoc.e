indexing

	description:

		"Eiffel documentation generator."

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC

inherit

	ANY

	EDOC_SHARED_ACCESS
		export {NONE} all end

	KL_SHARED_ARGUMENTS
		export {NONE} all end

	KL_SHARED_EXCEPTIONS
		export {NONE} all end

	KL_SHARED_FILE_SYSTEM
		export {NONE} all end

	KL_SHARED_EXECUTION_ENVIRONMENT
		export {NONE} all end

	KL_SHARED_STANDARD_FILES
		export {NONE} all end

create

	make

feature {NONE} -- Initialization

	make is
			-- Execute 'edoc'.
		local
			output_format_list: DS_LINKED_LIST [EDOC_OUTPUT]
				-- list that contains all output formats
			is_generated_and_parsed: BOOLEAN
				-- flag so we only generate & parse the universe once
		do
			Arguments.set_program_name ("edoc")
			parse_arguments

			-- Set verbose by default and set silent by option
			Error_handler.set_verbose (not is_silent)
			Error_handler.set_file_output_enabled (False)
			Error_handler.report_message ("%Nedoc in verbose mode")
			Error_handler.report_message ("-------------------------")

			-- Select output format, put all of them into a list
			create output_format_list.make
			if is_html_output then
				output_format_list.put_last (create {EDOC_HTML_OUTPUT}.make)
			elseif is_xml_output then
				output_format_list.put_last (create {EDOC_XML_OUTPUT}.make)
			elseif is_both_output then
				output_format_list.put_last (create {EDOC_HTML_OUTPUT}.make)
				output_format_list.put_last (create {EDOC_XML_OUTPUT}.make)
			end

			from output_format_list.start
			until output_format_list.after
			loop
				edoc_output := output_format_list.item_for_iteration

				-- Load default options file
				select_default_options_directory
				load_options_file (file_system.pathname (default_options_directory, edoc_output.default_options_filename))

				-- Load user-specified input
				load_input_file

				-- verify
				check_options

				Error_handler.report_message ("%NParsing input files")
				if Options.ace_file /= Void then
					load_ace
				end
				if Options.xace_system /= Void then
					load_xace_system (Options.xace_system)
				end
				if Options.xace_library /= Void then
					load_xace_system (Options.xace_library)
				end
				if Options.ecf_file /= Void then
					load_ecf_file (Options.ecf_file)
				end

				if options.are_mounted_libraries_included then
					from Options.mounted_libraries.start until Options.mounted_libraries.after loop
						load_xace_library (Options.mounted_libraries.item_for_iteration, Options.are_mounted_libraries_included, False)
						Options.mounted_libraries.forth
					end
				end

				if Error_handler.is_verbose then
					print_options
				end

				Context.set_output_generator (output_format_list.item_for_iteration)

				if not is_generated_and_parsed then
					Context.generate_universe
					Context.parse_universe
					is_generated_and_parsed := true
				end

				Context.generate_documentation

				-- increment
				output_format_list.forth
			end
		rescue
			if Error_handler.is_file_output_enabled then
				Error_handler.print_to_error_log_file ("An unrecoverable error occured", True)
			end
			std.output.put_string ("An unrecoverable error occured%N")
			if not Error_handler.is_verbose then
				if Error_handler.last_error_message /= Void then
					std.output.put_string ("Last error is "+Error_handler.last_error_code.out+": "+Error_handler.last_error_message+"%N")
				else
					std.output.put_string ("Last error code is: '"+Error_handler.last_error_code.out+"'%N")
				end
			end
			-- 'die' so no stack trace is shown (which is useless anyway in finalized mode)
			Error_handler.die (1)
		end

	select_default_options_directory is
			-- Select directory with default options.
		local
			a_directory: STRING
		do
			Error_handler.report_message ("Searching options directory")
			-- 1. check environment variable
			a_directory := Execution_environment.variable_value ("EDOC")
			if a_directory = Void then
				Error_handler.report_message ("No environment variable 'EDOC' found. Checking current directory.")
			else
				a_directory := file_system.pathname (a_directory, "options")
				if not file_system.directory_exists (a_directory) then
					a_directory := Void
					Error_handler.report_message ("No 'options' directory found in 'EDOC' directory. Checking current directory.")
				end
			end
			if a_directory = Void then
				-- 2. check working directory
				a_directory := file_system.pathname (file_system.absolute_pathname (file_system.current_working_directory), "options")
				if not file_system.directory_exists (a_directory) then
					Error_handler.report_message ("No 'options' directory found in current directory. Checking Execution command.")
					-- 3. check execution command
					a_directory := file_system.pathname (file_system.dirname (file_system.absolute_pathname (input_filename)), "options")
					if not file_system.directory_exists (a_directory) then
						Error_handler.report_message ("No 'options' directory found in '"+file_system.dirname (file_system.absolute_pathname (input_filename))+"'.")
						Error_handler.raise_error (Error_handler.Error_no_options_directory_found, Void)
					end
				end
			end
			create default_options_directory.make_from_string (a_directory)
			Error_handler.report_message ("Options directory '"+a_directory+"' selected")
		ensure
			directory_selected: default_options_directory /= Void
			directory_exists: file_system.directory_exists (default_options_directory)
		end

	load_options_file (a_filename: STRING) is
			-- Load options file.
		local
			an_options_file: EDOC_OPTIONS_FILE
		do
			an_options_file := edoc_output.options_file (a_filename)
			an_options_file.apply_options
		end

	load_input_file is
			-- load the input file as specified by `input_filename'
		local
			a_filename: STRING
		do
			a_filename := Execution_environment.interpreted_string (input_filename)
			if file_system.file_exists (a_filename) then
				-- Check if xace or options file
				if file_system.has_extension (a_filename, "xace") then
					-- Load xace file
					-- TODO: check if library or system (this is a wild guess here...)
					if a_filename.has_substring ("library") then
						Options.set_xace_library (a_filename)
					else
						Options.set_xace_system (a_filename)
					end
				elseif file_system.has_extension (a_filename, "ace") then
					-- Load ace file
					Options.set_ace_file (a_filename)
				elseif file_system.has_extension (a_filename, "ecf") then
					-- Load ecf file
					Options.set_ecf_file (a_filename)
				else
					-- Load options file
					load_options_file (a_filename)
				end
			else
				a_filename := file_system.pathname (default_options_directory, input_filename+".options")
				if file_system.file_exists (a_filename) then
					load_options_file (a_filename)
				end
			end
		end

	check_options is
			-- Check essential options if they are valid.
		local
			a_directory: KL_DIRECTORY
		do
			-- Check input files
			if Options.ace_file /= Void then
				if not file_system.file_exists (Options.ace_file) then
					Error_handler.raise_error (Error_handler.Error_ace_file_not_found, << Options.ace_file >>)
				end
			end
			if Options.xace_system /= Void then
				if not file_system.file_exists (Options.xace_system) then
					Error_handler.raise_error (Error_handler.Error_xace_file_not_found, << Options.xace_system >>)
				end
			end
			if Options.xace_library /= Void then
				if not file_system.file_exists (Options.xace_library) then
					Error_handler.raise_error (Error_handler.Error_xace_file_not_found, << Options.xace_library >>)
				end
			end
			if Options.ecf_file /= Void then
				if not file_system.file_exists (Options.ecf_file) then
					Error_handler.raise_error (Error_handler.Error_ecf_file_not_found, << Options.ecf_file >>)
				end
			end
			if Options.ace_file = Void and Options.xace_system = Void and Options.xace_library = Void and Options.ecf_file = Void then
				Error_handler.raise_error (Error_handler.Error_no_input_file, Void)
			end
			from Options.mounted_libraries.start until Options.mounted_libraries.after loop
				if not file_system.file_exists (Options.mounted_libraries.item_for_iteration) then
					Error_handler.raise_warning (Error_handler.Error_mounted_xace_not_found, << Options.mounted_libraries.item_for_iteration >>)
					Options.mounted_libraries.remove_at
				end
				if not options.mounted_libraries.after then
					Options.mounted_libraries.forth
				end
			end
			-- Check output directory
			create a_directory.make (Options.output_directory)
			if not a_directory.exists then
				a_directory.recursive_create_directory
			end
			if not a_directory.exists then
				Error_handler.raise_error (Error_handler.Error_create_output_directory, << Options.output_directory >>)
			end
		ensure
			ace_file_exists: Options.ace_file /= Void implies file_system.file_exists (Options.ace_file)
			xace_system_exists: Options.xace_system /= Void implies file_system.file_exists (Options.xace_system)
			xace_library_exists: Options.xace_library /= Void implies file_system.file_exists (Options.xace_library)
			output_directory_exists: file_system.directory_exists (Options.output_directory)
		end

	print_options is
			-- Print options to commandline
		do
			Error_handler.report_message ("%NInput options")
			if Options.ace_file /= Void then
				Error_handler.report_message ("Ace file: "+Options.ace_file)
			end
			if Options.xace_system /= Void then
				Error_handler.report_message ("XAce system: "+Options.xace_system)
			end
			if Options.xace_library /= Void then
				Error_handler.report_message ("XAce library: "+Options.xace_library)
			end
			from Options.mounted_libraries.start until Options.mounted_libraries.after loop
				Error_handler.report_message ("Mounted library: "+Options.mounted_libraries.item_for_iteration)
				Options.mounted_libraries.forth
			end
			if not Options.mounted_libraries.is_empty then
				Error_handler.report_message ("Mounted libraries included: "+boolean_to_string (Options.are_mounted_libraries_included))
			end
			Error_handler.report_message ("Ignored clusters: "+list_to_string (Options.ignored_clusters))

			Error_handler.report_message ("%NOutput options")
			Error_handler.report_message ("Output directory: "+Options.output_directory)
			Error_handler.report_message ("Flat output: "+boolean_to_string (Options.is_output_flat))
			Error_handler.report_message ("Generate feature list: "+boolean_to_string (Options.is_feature_list_generated))
			Error_handler.report_message ("Generate cluster files: "+boolean_to_string (Options.are_cluster_files_generated))
			Error_handler.report_message ("Generate index files: "+boolean_to_string (Options.is_index_generated))
			Error_handler.report_message ("Generate usage files: "+boolean_to_string (Options.are_usage_files_generated))

			Error_handler.report_message ("%NParser options")
			Error_handler.report_message ("Flatten classes: "+boolean_to_string (Options.are_classes_flat))
			Error_handler.report_message ("Ignored indexing tags: "+list_to_string (Options.ignored_indexing_tags))
			Error_handler.report_message ("Ignore inherit exported NONE: "+boolean_to_string (Options.is_inherit_export_none_ignored))
			Error_handler.report_message ("Ignored inherit classes: "+list_to_string (Options.ignored_inherit_classes))
			Error_handler.report_message ("Ignore feature clauses exported to NONE: "+boolean_to_string (Options.is_feature_clause_export_none_ignored))
			Error_handler.report_message ("Feature clause order: "+list_to_string (Options.feature_clause_order))
			Error_handler.report_message ("Ignored feature clauses: "+list_to_string (Options.ignored_feature_clauses))
			Error_handler.report_message ("Dummy classes: "+list_to_string (Options.dummy_classes))

			-- TODO: As soon as multiple output formats are supported this has to move to the corresponding EDOC_OUTPUT class
			Error_handler.report_message ("%NHTML options")
			Error_handler.report_message ("Title: "+Options.title)
			Error_handler.report_message ("Short title: "+Options.short_title)
			Error_handler.report_message ("Version: "+Options.version)
			Error_handler.report_message ("CSS file: "+Options.original_css_file)
			Error_handler.report_message ("")
		end

	load_ace is
			-- Load ace file.
		require
			ace_file_not_void: Options.ace_file /= Void
			ace_file_exists: file_system.file_exists (Options.ace_file)
		local
			lace_parser: ET_LACE_PARSER
			a_file: KL_TEXT_INPUT_FILE
		do
			create a_file.make (Options.ace_file)
			a_file.open_read
			if not a_file.is_open_read then
				Error_handler.raise_error (Error_handler.Error_ace_file_not_readable, << Options.ace_file >>)
			end
			create lace_parser.make_standard
			lace_parser.parse_file (a_file)
			if Options.title = Void then
				Options.set_title (Options.ace_file)
			end
			if Options.short_title = Void then
				Options.set_short_title (Options.ace_file)
			end
			if lace_parser.last_system = Void then
				Error_handler.raise_error (Error_handler.Error_parsing_ace, << Options.ace_file >>)
			end
			Error_handler.report_message ("Done. "+lace_parser.last_system.clusters.count.out+" clusters")
			Context.add_clusters (lace_parser.last_system.clusters, True)
			context.universe := lace_parser.last_system
		end

	load_xace_system (a_system_name: STRING) is
			-- Load xace system file.
		require
			a_system_name_not_void: a_system_name /= Void
			a_system_name_exists: file_system.file_exists (a_system_name)
		local
			xace_error_handler: ET_XACE_DEFAULT_ERROR_HANDLER
			xace_parser: ET_XACE_SYSTEM_PARSER
			a_file: KL_TEXT_INPUT_FILE
			i, nb: INTEGER
		do
			create a_file.make (a_system_name)
			a_file.open_read
			if not a_file.is_open_read then
				Error_handler.raise_error (Error_handler.Error_xace_file_not_readable, << a_system_name >>)
			end
			create xace_error_handler.make_standard
			create xace_parser.make (xace_error_handler)
			xace_parser.set_shallow (True)
			xace_parser.parse_file (a_file)
			if xace_error_handler.has_error then
				Error_handler.raise_error (Error_handler.Error_parsing_xace, << a_system_name >> )
			end
			if Options.title = Void then
				Options.set_title (xace_parser.last_system.system_name)
			end
			if Options.short_title = Void then
				Options.set_short_title (xace_parser.last_system.system_name)
			end
			if xace_parser.last_system.clusters /= Void then
				Error_handler.report_message ("Done. "+xace_parser.last_system.clusters.count.out+" clusters")
				Context.add_clusters (xace_parser.last_system.clusters, True)
			else
				Error_handler.report_message ("Done. 0 new top-level clusters")
			end

			if xace_parser.last_system.libraries /= Void then
				nb := xace_parser.last_system.libraries.libraries.count
			else
				nb := 0
			end
			from i := 1 until i > nb loop
				Options.mounted_libraries.force_last (Execution_environment.interpreted_string (xace_parser.last_system.libraries.libraries.item (i).library.pathname))
				i := i + 1
			end
			context.universe := xace_parser.last_system

		end

	load_ecf_file (a_system_name: STRING) is
			-- Load ecf file.
		require
			ecf_system_not_void: Options.ecf_file /= Void
			ecf_file_exists: file_system.file_exists (Options.ecf_file)
		local
			ecf_error_handler: ET_ECF_ERROR_HANDLER --ET_XACE_DEFAULT_ERROR_HANDLER
			ecf_parser: ET_ECF_SYSTEM_PARSER
			a_file: KL_TEXT_INPUT_FILE
			i, nb: INTEGER
		do
			create a_file.make (a_system_name)
			a_file.open_read
			if not a_file.is_open_read then
				Error_handler.raise_error (Error_handler.Error_xace_file_not_readable, << Options.xace_system >>)
			end
			create ecf_error_handler.make_standard
			create ecf_parser.make (ecf_error_handler)
			ecf_parser.parse_file (a_file)
			if ecf_error_handler.has_error then
				Error_handler.raise_error (Error_handler.Error_parsing_ecf, << Options.ecf_file >> )
			end
			if Options.title = Void then
				Options.set_title (ecf_parser.last_system.system_name)
			end
			if Options.short_title = Void then
				Options.set_short_title (ecf_parser.last_system.system_name)
			end
			if ecf_parser.last_system.clusters /= Void then
				Error_handler.report_message ("Done. "+ecf_parser.last_system.clusters.count.out+" clusters")
				Context.add_clusters (ecf_parser.last_system.clusters, True)
			else
				Error_handler.report_message ("Done. 0 new top-level clusters")
			end

			if ecf_parser.last_system.libraries /= Void then
				nb := ecf_parser.last_system.libraries.libraries.count
			else
				nb := 0
			end
			from i := 1 until i > nb loop
				Options.mounted_libraries.force_last (Execution_environment.interpreted_string (ecf_parser.last_system.libraries.libraries.item (i).library.pathname))
				i := i + 1
			end
			context.universe := ecf_parser.last_system

		end

	load_xace_library (a_filename: STRING; add_clusters: BOOLEAN; use_title: BOOLEAN) is
			-- Load xace library file.
		require
			a_filename_not_void: a_filename /= Void
			a_filename_exists: file_system.file_exists (a_filename)
		local
			xace_error_handler: ET_XACE_DEFAULT_ERROR_HANDLER
			xace_parser: ET_XACE_LIBRARY_CONFIG_PARSER
			a_file: KL_TEXT_INPUT_FILE
		do
			create a_file.make (a_filename)
			a_file.open_read
			if not a_file.is_open_read then
				Error_handler.raise_error (Error_handler.Error_xace_file_not_readable, << a_filename >>)
			end
			create xace_error_handler.make_standard
			create xace_parser.make_with_variables (Execution_environment, xace_error_handler)
			Error_handler.report_message ("Parsing xace library '"+a_filename+"'")
			xace_parser.parse_file (a_file)
			if xace_error_handler.has_error then
				Error_handler.raise_error (Error_handler.Error_parsing_xace, << a_filename >> )
			end
			if use_title then
				if Options.title = Void then
					Options.set_title (xace_parser.last_library.name)
				end
				if Options.short_title = Void then
					Options.set_short_title (xace_parser.last_library.name)
				end
			end
			if xace_parser.last_library.clusters /= Void then
				Error_handler.report_message ("Done. "+xace_parser.last_library.clusters.count.out+" clusters")
				Context.add_clusters (xace_parser.last_library.clusters, add_clusters)
			else
				Error_handler.report_message ("Done. 0 new top-level clusters")
			end
--			context.universe := xace_parser.last_library
		end

feature -- Access

	version : UT_VERSION
		once
			create Result.make (1, 5, 0, 1)
		end

	edoc_output: EDOC_OUTPUT
			-- Selected output type

	default_options_directory: STRING
			-- Directory with default options
			-- Normally '$EDOC/options'

feature -- Status report

	is_silent: BOOLEAN is
			-- Should EDoc run in silent mode?
		do
			Result := silent_flag.was_found
		end

	is_html_output: BOOLEAN is
			-- Should edoc produce html output?
		do
			Result := output_flag.was_found and then output_flag.parameter.is_equal ("html")
		end

	is_xml_output: BOOLEAN is
			-- Should edoc produce xml output?
		do
			Result := output_flag.was_found and then output_flag.parameter.is_equal ("xml")
		end

	is_both_output: BOOLEAN
			-- Should edoc produce both html and xml output?
		do
			Result := output_flag.was_found and then output_flag.parameter.is_equal ("both")
		end

feature -- Argument parsing

	input_filename: STRING
			-- Name of the input file, may be an ace file or an options file

	silent_flag: AP_FLAG
			-- Flag for '--silent'

	output_flag: AP_ENUMERATION_OPTION
			-- Option for chosing html/xml/both output format

	parse_arguments is
			-- Initialize options and parse the command line.
		local
			a_parser: AP_PARSER
		do
			create a_parser.make
			a_parser.set_application_description ("Eiffel documentation generator. Version: "+ version.out)

			a_parser.set_parameters_description ("{path_to_xace_file/path_to_options_file}")

			-- Options
			create silent_flag.make ('s', "silent")
			silent_flag.set_description ("Run EDoc in silent mode.")
			silent_flag.show_in_help_text
			a_parser.options.force_last (silent_flag)

			create output_flag.make ('o', "output")
			output_flag.set_description ("Sets the output format to HTML, XML or both of them.")
			output_flag.show_in_help_text
			output_flag.extend ("html")
			output_flag.extend ("xml")
			output_flag.extend ("both")
			a_parser.options.force_last (output_flag)

			-- Parsing
			a_parser.parse_arguments

			if a_parser.parameters.count /= 1 then
				error_handler.report_message (a_parser.help_option.full_usage_instruction (a_parser))
				Exceptions.die (1)
			else
				input_filename := a_parser.parameters.first

				if not output_flag.was_found then
					output_flag.parameters.force_first ("html")
				end
			end
		end

feature {NONE} -- Implementation

	boolean_to_string (a_boolean: BOOLEAN): STRING is
			-- String of 'a_boolean'.
		do
			if a_boolean then
				Result := "Yes"
			else
				Result := "No"
			end
		end

	list_to_string (a_list: DS_LIST [ANY]): STRING is
			-- String of 'a_list'.
		do
			create Result.make (a_list.count*10)
			from a_list.start until a_list.after loop
				Result.append_string (a_list.item_for_iteration.out)
				a_list.forth
				if not a_list.after then
					Result.append_string (", ")
				end
			end
		end

end

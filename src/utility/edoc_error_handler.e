indexing

	description: 

		"Error handler"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_ERROR_HANDLER

inherit

	EDOC_ERROR_CODES

	EDOC_ERROR_MESSAGES
		export {NONE} all end

	KL_SHARED_STANDARD_FILES
		export {NONE} all end

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

	EXCEPTIONS
		export 
			{NONE} all
			{ANY} die
		end

create

	make

feature {NONE} -- Initialization

	make is
			-- Create an error handler instance
		do
			is_verbose := True
			is_file_output_enabled := True
		end

feature -- Access

	last_error_code: INTEGER
			-- Code of last error

	last_error_message: STRING
			-- Message of last error

feature -- Status report

	is_verbose: BOOLEAN
			-- Is error handler printing error messages?

	is_file_output_enabled: BOOLEAN
			-- Is output of errors in a file enabled?

feature -- Status setting

	set_verbose (a_value: like is_verbose) is
			-- Set `is_verbose' to `a_value'.
		do
			is_verbose := a_value
		ensure
			is_verbose_set: is_verbose = a_value
		end

	set_file_output_enabled (a_value: like is_file_output_enabled) is
			-- Set `is_file_output_enabled' to `a_value'.
		do
			is_file_output_enabled := a_value
		ensure
			is_file_output_enabled_set: is_file_output_enabled = a_value
		end

feature -- Basic operations

	report_message (a_message: STRING) is
			-- Print `a_message' in verbose mode.
		require
			a_message_not_void: a_message /= Void
		do
			if is_verbose then
				std.output.put_string (a_message+"%N")
			end
		end

	raise_warning (an_error_code: INTEGER; error_data: ARRAY [ANY]) is
			-- Set `last_error' to `error_code' and display an error message.
		local
			an_array: ARRAY [ANY]
		do
			last_error_code := an_error_code
			if error_data = Void then
				create an_array.make (1, 0)
				last_error_message := generate_message (an_error_code, an_array)
			else
				last_error_message := generate_message (an_error_code, error_data)
			end
			if is_verbose then
				std.error.put_string ("Warning "+an_error_code.out+": "+last_error_message+"%N")
				std.error.flush
			end
			if is_file_output_enabled then
				print_to_error_log_file ("Warning "+an_error_code.out+": "+last_error_message, True)
			end
		ensure
			error_set: last_error_code = an_error_code
			error_message_set: not last_error_message.is_empty
		end

	raise_error (an_error_code: INTEGER; error_data: ARRAY [ANY]) is
			-- Set `last_error' to `error_code', display an error message and raise developer exception.
		local
			an_array: ARRAY [ANY]
		do
			last_error_code := an_error_code
			if error_data = Void then
				create an_array.make (1, 0)
				last_error_message := generate_message (an_error_code, an_array)
			else
				last_error_message := generate_message (an_error_code, error_data)
			end
			if is_verbose then
				std.error.put_string ("Error "+an_error_code.out+": "+last_error_message+"%N")
				std.error.flush
			end
			if is_file_output_enabled then
				print_to_error_log_file ("Error "+an_error_code.out+": "+last_error_message, True)
			end
			raise (an_error_code.out)
		ensure
			error_set: last_error_code = an_error_code
			error_message_set: not last_error_message.is_empty
		end

	print_to_error_log_file (a_message: STRING; prepend_date: BOOLEAN) is
			-- Print `a_message' to error log file.
		local
			clock: DT_SYSTEM_CLOCK
		do
			Error_log_file.open_append
			if Error_log_file.is_open_write then
				if prepend_date then
					create clock.make
					Error_log_file.put_string (clock.date_time_now.out+" - "+a_message)
				else
					Error_log_file.put_string (a_message)
				end
				Error_log_file.put_new_line
				Error_log_file.close
			end
		end

feature {NONE} -- Implementation

	generate_message (an_error_code: INTEGER; error_data: ARRAY [ANY]): STRING is
			-- Generate message for `an_error_code' and use `error_data' to fill placeholders in the error message.
		require
			error_data_not_void: error_data /= Void
		local
			a_message, a_replacement, a_data: STRING
			i: INTEGER
		do
			if Error_messages.has (an_error_code) then
				a_message := Error_messages.item (an_error_code)
			else
				a_message := Default_error_message
			end

			create Result.make_from_string (a_message)
			Result := STRING_.replaced_all_substrings (Result, "{0}", an_error_code.out)
			from i := error_data.lower until i > error_data.upper loop
				a_replacement := "{"+i.out+"}"
				a_data := error_data.item (i).out
				Result := STRING_.replaced_all_substrings (Result, a_replacement, a_data)
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
		end

	Error_log_file_name: STRING is "error.txt"
			-- Name of error log file

	Error_log_file: KL_TEXT_OUTPUT_FILE is
			-- Error log file
		local
			alredy_exists: BOOLEAN
		once
			create Result.make (Error_log_file_name)
			alredy_exists := Result.exists
			Result.open_append
			if Result.is_open_write and alredy_exists then
				Result.put_string ("------%N")
			end
			Result.close
		ensure
			result_exists: Result /= Void
		end

end

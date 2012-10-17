indexing

	description:

		"An XML overview file"

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_OVERVIEW_FILE

inherit

	EDOC_XML_OUTPUT_FILE

create

	make

feature -- File creation

	generate is
			-- Generate overview file.
		local
			a_character: CHARACTER
		do
			open_write
			print_xml_head ("Overview", xml_context.relative_xsd_link)

			print_header_start
			print_header_end

			if Options.version /= Void and then Options.version.count > 0 then
				tag_content ("title", Options.title+" "+Options.version)
			else
				tag_content ("title", Options.title)
			end

			generate_overview_description
			if overview_description /= Void then
				print_comment (overview_description, Void, Void, False)
			end

			start_tag ("itemizedlist")
			if Options.is_clusters_file_generated then
				start_tag ("listitem")
				content_line (link_content_to_string (xml_context.relative_clusters_link, "Clusters")+" - List of clusters")
				end_tag
			end
			if Options.is_classes_file_generated then
				start_tag ("listitem")
				content_line (link_content_to_string (xml_context.relative_classes_link, "Classes")+" - List of classes")
				end_tag
			end
			if Options.is_index_generated then
				start_tag ("listitem")
				content_line ("Index:")
				from a_character := 'A' until a_character > 'Z' loop
					link_content (xml_context.relative_index_link (a_character), a_character.out)
					a_character := a_character.next
				end
				if Options.is_index_all_generated then
					link_content (xml_context.relative_index_all_link, "All")
				end
				end_tag
			end
			end_tag -- itemizedlist

			print_footer_start
			print_buttons
			print_footer_end

			print_xml_footer
			close
		end

feature {NONE} -- Implementation

-- TODO: copied from EDOC_HTML_CLUSTER_FILE -> refactor

	overview_description: STRING
			-- Overview text

	generate_overview_description is
			-- Try to find an overview description and store it in `overview_description'.
		local
--			directory: KL_DIRECTORY
--			files: ARRAY [STRING]
--			i: INTEGER
		do
			overview_description := Void
--			create directory.make (file_system.canonical_pathname (Execution_environment.interpreted_string (Void))) -- TODO: select appropriate directory
--			if directory.exists then
--				files := directory.filenames
--				from i := files.lower until i > files.upper or overview_description /= Void loop
--					if
--						file_system.has_extension (files.item (i), ".txt") and then
--						(STRING_.same_case_insensitive (files.item (i), "overview.txt") or else
--						 STRING_.same_case_insensitive (files.item (i), "description.txt"))
--					then
--						extract_text_documentation (file_system.pathname (directory.name, files.item (i)))
--					elseif
--						file_system.has_extension (files.item (i), ".html") and then
--						(STRING_.same_case_insensitive (files.item (i), "overview.html") or else
--						 STRING_.same_case_insensitive (files.item (i), "description.html"))
--					then
--						extract_html_documentation (file_system.pathname (directory.name, files.item (i)))
--					end
--					i := i + 1
--				end
--			end
		end

	extract_text_documentation (a_filename: STRING) is
			-- Get documentation from `a_filename' when `a_filename' is a text file.
		require
			a_filename_not_void: a_filename /= Void
			a_filename_exists: file_system.file_exists (a_filename)
		local
			a_file: KL_TEXT_INPUT_FILE
		do
			create a_file.make (a_filename)
			create overview_description.make (a_file.count.max (0))
			a_file.open_read
			if a_file.is_open_read then
				from until a_file.end_of_input loop
					a_file.read_line
					overview_description.append_string (a_file.last_string+"%N")
				end
			end
		end

	extract_html_documentation (a_filename: STRING) is
			-- Get documentation from `a_filename' when `a_filename' is an html file.
		require
			a_filename_not_void: a_filename /= Void
			a_filename_exists: file_system.file_exists (a_filename)
		local
			a_file: KL_TEXT_INPUT_FILE
			in_body: BOOLEAN
		do
			create a_file.make (a_filename)
			create overview_description.make (a_file.count.max (0))
			a_file.open_read
			if a_file.is_open_read then
				from until a_file.end_of_input loop
					a_file.read_line
					if a_file.last_string.has_substring ("</body>") then
						in_body := False
					end
					if in_body then
						overview_description.append_string (a_file.last_string+"%N")
					end
					if a_file.last_string.has_substring ("<body") then
						in_body := True
					end
				end
			end
		end

end

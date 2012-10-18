indexing

	description:

		"Generate an XML file for an Eiffel cluster."

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_CLUSTER_FILE

inherit

	EDOC_XML_OUTPUT_FILE

	KL_SHARED_EXECUTION_ENVIRONMENT
		export {NONE} all end

create

	make

feature -- Access

	cluster: ET_CLUSTER
			-- Cluster

	documentation: STRING
			-- Cluster documentation

feature -- Element change

	set_cluster (a_cluster: ET_CLUSTER) is
			-- Set `cluster' to `a_cluster'.
		require
			a_cluster_not_void: a_cluster /= Void
		do
			cluster := a_cluster
		ensure
			cluster_set: cluster = a_cluster
		end

feature -- Basic operations

	generate is
			-- Generate cluster file for `cluster'.
		require
			cluster_not_void: cluster /= Void
		local
			class_list: DS_ARRAYED_LIST [ET_CLASS]
			class_cursor: DS_LIST_CURSOR [ET_CLASS]
		do
			generate_cluster_description

			open_write
			print_xml_head (cluster.name, xml_context.relative_xsd_link)

			print_header_start
			print_header_end
			tag_content ("title", "Cluster "+print_qualified_cluster_name_to_string (cluster, False))


			if documentation /= Void and then not documentation.is_empty then
				print_comment (documentation, Void, create {DS_LINKED_LIST [ET_FEATURE]}.make, False)
			end

			if cluster.subclusters /= Void then
				tag_content ("title", "Clusters")

				start_tag ("itemizedlist")
				print_subclusters_tree (cluster)
				end_tag -- itemizedlist
			end

			class_list := Context.universe.classes_in_group (cluster)
			if class_list.count > 0 then
				Class_sorter.sort (class_list)
				tag_content ("title", "Classes")

				start_tag ("itemizedlist")
				from
					class_cursor := class_list.new_cursor
					class_cursor.start
				until
					class_cursor.after
				loop
					start_tag ("listitem")
					print_class_name (class_cursor.item)
					end_tag -- listitem

					class_cursor.forth
				end
				end_tag -- itemizedlist
			end

			print_footer_start
			print_buttons
			print_footer_end

			print_xml_footer
			close
		end

feature {NONE} -- Implementation

	generate_cluster_description is
			-- Try to find a cluster description and store it in `cluster_description'.
		local
			directory: KL_DIRECTORY
			files: ARRAY [STRING]
			i: INTEGER
		do
			documentation := Void
			create directory.make (file_system.canonical_pathname (Execution_environment.interpreted_string (cluster.full_pathname)))
			if directory.exists then
				files := directory.filenames
				from i := files.lower until i > files.upper or documentation /= Void loop
					if
						file_system.has_extension (files.item (i), ".txt") and then
						(STRING_.same_case_insensitive (files.item (i), cluster.name+".txt") or else
						 STRING_.same_case_insensitive (files.item (i), "cluster.txt") or else
						 STRING_.same_case_insensitive (files.item (i), "readme.txt"))
					then
						extract_text_documentation (file_system.pathname (directory.name, files.item (i)))
					elseif
						file_system.has_extension (files.item (i), ".html") and then
						(STRING_.same_case_insensitive (files.item (i), cluster.name+".html") or else
						 STRING_.same_case_insensitive (files.item (i), "cluster.html") or else
						 STRING_.same_case_insensitive (files.item (i), "readme.html"))
					then
						extract_html_documentation (file_system.pathname (directory.name, files.item (i)))
					end
					i := i + 1
				end
			end
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
			create documentation.make (a_file.count.max (0))
			a_file.open_read
			if a_file.is_open_read then
				from until a_file.end_of_input loop
					a_file.read_line
					documentation.append_string (a_file.last_string+"%N")
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
			create documentation.make (a_file.count.max (0))
			a_file.open_read
			if a_file.is_open_read then
				from until a_file.end_of_input loop
					a_file.read_line
					if a_file.last_string.has_substring ("</body>") then
						in_body := False
					end
					if in_body then
						documentation.append_string (a_file.last_string+"%N")
					end
					if a_file.last_string.has_substring ("<body") then
						in_body := True
					end
				end
			end
		end

end

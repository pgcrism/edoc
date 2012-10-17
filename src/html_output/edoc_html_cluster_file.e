indexing

	description:

		"Generate an HTML file for an Eiffel cluster."

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_HTML_CLUSTER_FILE

inherit

	EDOC_HTML_OUTPUT_FILE

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

			print_html_head (cluster.name, html_context.relative_css_link)

			start_tag ("body")

				print_header_start
				print_buttons
				print_header_end

				tag_content ("h1", "Cluster "+print_qualified_cluster_name_to_string (cluster, False))

				if documentation /= Void and then not documentation.is_empty then
					tag ("hr")
					print_comment (documentation, Void, create {DS_LINKED_LIST [ET_FEATURE]}.make, False)
				end

				if cluster.subclusters /= Void then
					tag ("hr")
					tag_content ("h2", "Clusters")
					start_tag_css ("ul", css_cluster_tree)
					print_subclusters_tree (cluster)
					end_tag
				end

				class_list := Context.universe.classes_by_group (cluster)
				if class_list.count > 0 then
					Class_sorter.sort (class_list)
					tag ("hr")
					tag_content ("h2", "Classes")
					start_tag ("ul")
					from
						class_cursor := class_list.new_cursor
						class_cursor.start
					until
						class_cursor.after
					loop
						start_tag ("li")
						print_class_name (class_cursor.item)
						end_tag
						class_cursor.forth
					end
					end_tag
				end

				print_footer_start
				print_buttons
				print_footer_end

			end_tag
			end_tag

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

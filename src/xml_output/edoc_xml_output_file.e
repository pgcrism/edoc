indexing

	description:

		"An XML output file"

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_OUTPUT_FILE

inherit

	KL_TEXT_OUTPUT_FILE
		redefine
			make
		end

	EDOC_SHARED_XML_CONTEXT
		export {NONE} all end

	EDOC_SHARED_ACCESS
		export {NONE} all end

	KL_SHARED_FILE_SYSTEM
		export {NONE} all end

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

	KL_IMPORTED_CHARACTER_ROUTINES
		export {NONE} all end

create

	make

feature {NONE} -- Initialisation

	make (a_name: like name) is
			-- Create a new file named `a_name'.
			-- (`a_name' should follow the pathname convention
			-- of the underlying platform. For pathname conversion
			-- use KI_FILE_SYSTEM.pathname_from_file_system.)
		do
			Precursor {KL_TEXT_OUTPUT_FILE} (a_name)
			if not file_system.directory_exists (file_system.dirname (a_name)) then
				file_system.recursive_create_directory (file_system.dirname (a_name))
			end
			create open_tags.make
		ensure then
			name_set: name = a_name
		end

feature -- Access

	open_tags: DS_LINKED_STACK [STRING]
			-- Open XML tags

feature -- Basic operations

	indent is
			-- Indent.
		require
			open_write: is_open_write
		local
			a_string: STRING
		do
			-- TODO: activate indentation only for html-debugging and disable when released to reduce doc-size
			create a_string.make_filled (' ', open_tags.count*2)
			put_string (a_string)
		end

	start_tag (a_tag: STRING) is
			-- Print start tag `a_tag'.
		require
			a_tag_not_void: a_tag /= Void
			open_write: is_open_write
		do
			start_tag_attributes (a_tag, Void)
		end

	start_tag_attributes (a_tag: STRING; an_attributes: ARRAY [STRING]) is
			-- Print start tag `a_tag' with attributes `an_attributes'.
		require
			a_tag_not_void: a_tag /= Void
			an_attributes_count_even: an_attributes /= Void implies an_attributes.count \\ 2 = 0
			open_write: is_open_write
		do
			indent
			if an_attributes = Void then
				put_string ("<"+xml_context.edoc_namespace+":"+a_tag+">%N")
			else
				put_string ("<"+xml_context.edoc_namespace+":"+a_tag+attributes_string (an_attributes)+">%N")
			end
			open_tags.put (a_tag)
		end

	content_line (a_line: STRING) is
			-- Print content line.
		require
			a_line_not_void: a_line /= Void
			open_write: is_open_write
		do
			indent
			put_string (a_line)
			put_new_line
		end

	end_tag is
			-- Print end tag.
		require
			open_write: is_open_write
		local
			a_tag: STRING
		do
			a_tag := open_tags.item
			open_tags.remove
			indent
			put_string ("</"+xml_context.edoc_namespace+":"+a_tag+">%N")
		end

	tag (a_tag: STRING) is
			-- Print single tag.
		require
			a_tag_not_void: a_tag /= Void
			open_write: is_open_write
		do
			tag_attributes (a_tag, Void)
		end

	tag_to_string (a_tag: STRING): STRING is
				-- Returns single tag.
		require
			a_tag_not_void: a_tag /= Void
		do
			Result := tag_attributes_to_string (a_tag, Void)
		end

	tag_attributes (a_tag: STRING; an_attributes: ARRAY [STRING]) is
			-- Print single tag with attributes.
			-- Ends with newline.
		require
			a_tag_not_void: a_tag /= Void
			an_attributes_count_even: an_attributes /= Void implies an_attributes.count \\ 2 = 0
			open_write: is_open_write
		do
			indent
			if an_attributes = Void then
				put_string ("<"+xml_context.edoc_namespace+":"+a_tag+"/>%N")
			else
				put_string ("<"+xml_context.edoc_namespace+":"+a_tag+attributes_string (an_attributes)+"/>%N")
			end
		end

	tag_attributes_to_string (a_tag: STRING; an_attributes: ARRAY [STRING]): STRING is
			-- Returns single tag with attributes, including newline character
		require
			a_tag_not_void: a_tag /= Void
			an_attributes_count_even: an_attributes /= Void implies an_attributes.count \\ 2 = 0
			open_write: is_open_write
		do
			create Result.make_empty
			if an_attributes = Void then
				Result.append ("<"+xml_context.edoc_namespace+":"+a_tag+"/>")
			else
				Result.append ("<"+xml_context.edoc_namespace+":"+a_tag+attributes_string (an_attributes)+"/>")
			end
		end

	tag_content (a_tag, a_content: STRING) is
			-- Singe tag with content.
			-- Ends with newline.
		do
			content_line (tag_content_to_string (a_tag, a_content))
		end

	tag_attributes_content (a_tag: STRING; an_attributes: ARRAY [STRING]; a_content: STRING) is
			-- Single tag with attributes and content.
			-- Ends with newline.
		require
			open_write: is_open_write
			a_tag_not_void: a_tag /= Void
			a_content_not_void: a_content /= Void
		do
			content_line (tag_attributes_content_to_string (a_tag, an_attributes, a_content))
		end

	tag_content_to_string (a_tag, a_content: STRING): STRING is
			-- String of single tag with content.
		require
			a_tag_not_void: a_tag /= Void
			a_content_not_void: a_content /= Void
		do
			Result := tag_attributes_content_to_string (a_tag, Void, a_content)
		ensure
			result_not_void: Result /= Void
		end

	tag_attributes_content_to_string (a_tag: STRING; an_attributes: ARRAY [STRING]; a_content: STRING): STRING is
			-- Single tag with attributes and content.
		require
			a_tag_not_void: a_tag /= Void
			an_attributes_count_even: an_attributes /= Void implies an_attributes.count \\ 2 = 0
			a_content_not_void: a_content /= Void
			open_write: is_open_write
		do

			if an_attributes = Void then
				Result := "<"+xml_context.edoc_namespace+":"+a_tag+">"+a_content+"</"+xml_context.edoc_namespace+":"+a_tag+">"
			else
				Result := "<"+xml_context.edoc_namespace+":"+a_tag+attributes_string (an_attributes)+">"+a_content+"</"+xml_context.edoc_namespace+":"+a_tag+">"
			end
		ensure
			result_not_void: Result /= Void
		end

	link_content (a_link, a_content: STRING) is
			-- Print a link to 'a_link' with 'a_content'.
		require
			a_link_not_void: a_link /= Void
			a_content_not_void: a_content /= Void
		do
			indent
			put_string ("<"+xml_context.edoc_namespace+":link url=%""+a_link+"%">"+a_content+"</"+xml_context.edoc_namespace+":link>%N")
		end

	link_content_to_string (a_link, a_content: STRING): STRING is
			-- Print a link to 'a_link' with 'a_content' to a string.
		require
			a_link_not_void: a_link /= Void
			a_content_not_void: a_content /= Void
		do
			Result := "<"+xml_context.edoc_namespace+":link url=%""+a_link+"%">"+a_content+"</"+xml_context.edoc_namespace+":link>%N"
		ensure
			result_not_void: Result /= Void
		end

	anchor_content (a_name, a_content: STRING) is
			-- Print an anchor with 'a_name' and 'a_content' to a string.
		do
			indent
			put_string (anchor_content_to_string (a_name, a_content)+"%N")
		end

	anchor_content_to_string (a_name, a_content: STRING): STRING is
			-- Print an anchor with 'a_name' and 'a_content' to a string.
		do
			Result := "<a name=%""+a_name+"%">"+a_content+"</a>"
		end

feature -- Conveniance printing

	print_xml_head (a_title: STRING; an_xsd_link: STRING) is
			-- Print an html tag with a head section with `a_title' and `a_css_stylesheet'.
		require
			a_title_not_void: a_title /= Void
			open_write: is_open_write
		local
			xml_attribute_string: STRING
		do
			if options.xml_header_file /= Void then
				-- custom header
				print_whole_file(options.xml_header_file)
			else
				-- default xml header
				put_line ("<?xml version=%"1.0%" encoding=%"ISO-8859-1%"?>%N")
				put_line ("<!--")
				put_line ("%Tdescription:")
				put_line ("")
				put_line ("%Tdate: %"$$%"")
				put_line ("%Trevision: %"$$%"")
				put_line ("-->")
			end

			-- print root element directly to the file, add manually to tag-stack.
			-- this way, the default namespace won't get added to the root element,
			-- nor to the tag-stack
			-- will/has to be closed in feature `print_xml_footer'
			xml_attribute_string := "xmlns:edoc=%"http://edoc.origo.ethz.ch%"%N%T"
			xml_attribute_string.append ("xmlns:xsi=%"http://www.w3.org/2001/XMLSchema-instance%"%N%T")
			xml_attribute_string.append ("xsi:schemaLocation=%"http://edoc.origo.ethz.ch " + an_xsd_link + "%"")
			content_line ("<edoc:root " + xml_attribute_string + " >")

			tag_content ("title",  a_title +" ("+Options.short_title+")")
			start_tag ("body") -- will/has to be closed in feature `print_xml_footer'
		end

	print_xml_footer is
			-- Print an xml footer
		require
			open_write: is_open_write
		do
			end_tag -- body

			if options.xml_footer_file /= Void then
				-- custom footer
				print_whole_file(options.xml_footer_file)
			else
				-- default footer
			end
			content_line ("</edoc:root>")
		end

	print_cluster_name (a_cluster: ET_CLUSTER) is
			-- Print class name of 'a_cluster' to string.
		do
			put_string (print_cluster_name_to_string (a_cluster))
		end

	print_cluster_name_to_string (a_cluster: ET_CLUSTER): STRING is
			-- Print cluster name of 'a_cluster' to string.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_link: STRING
		do
			a_link := xml_context.cluster_link_by_cluster (a_cluster)
			if a_link = Void then
				Result := tag_content_to_string ("cluster", a_cluster.name)
			else
				Result := tag_attributes_content_to_string ("cluster", << "url", a_link>>, a_cluster.name)
			end
		ensure
			result_exists: Result /= Void
		end

	print_qualified_cluster_name_single_link (a_cluster: ET_CLUSTER) is
			-- Print qualified cluster name of 'a_cluster' as a link to 'a_cluster'.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_parent: ET_CLUSTER
			a_content: STRING
			a_link: STRING
		do
			create a_content.make_from_string (a_cluster.name)
			from
				a_parent := a_cluster.parent
			until
				a_parent = Void
			loop
				a_content := STRING_.concat (a_parent.name+".", a_content)
				a_parent := a_parent.parent
			end
			indent
			a_link := xml_context.cluster_link_by_cluster (a_cluster)
			if a_link = Void then
				tag_content ("cluster", a_content)
			else
				tag_attributes_content ("cluster", << "url", a_link>>, a_content)
			end
		end

	print_qualified_cluster_name_to_string (a_cluster: ET_CLUSTER; link_a_cluster: BOOLEAN): STRING is
			-- Print cluster name of 'a_cluster' and all its parents to string.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_parent: ET_CLUSTER
		do
			create Result.make_empty
			a_parent := a_cluster.parent
			if a_parent /= Void then
				if link_a_cluster then
					Result.append (print_cluster_name_to_string (a_cluster))
				else
					Result.append (tag_content_to_string ("cluster", a_cluster.name))
				end

				from
				until
					a_parent = Void
				loop
					Result := STRING_.concat (print_cluster_name_to_string (a_parent)+".", Result)
					a_parent := a_parent.parent
				end
				Result := tag_content_to_string ("cluster_qualified_name", Result)
			end
		ensure
			result_exists: Result /= Void
		end

	print_class_name (a_class: ET_CLASS) is
			-- Print class name of 'a_class'.
		do
			put_string (print_class_name_to_string (a_class))
		end

	print_class_name_to_string (a_class: ET_CLASS): STRING is
			-- Print class name of 'a_class' to string.
		require
			a_class_not_void: a_class /= Void
		local
			a_link: STRING
		do
			a_link := xml_context.class_link_by_class (a_class)
			if a_link = Void then
				Result := tag_content_to_string ("class", a_class.name.name)
			else
				Result := tag_attributes_content_to_string ("class", << "url", a_link>>, a_class.name.name)
			end
		ensure
			result_exists: Result /= Void
		end

	print_qualified_class_name (a_class: ET_CLASS) is
			-- Print qualified class name of 'a_class'.
		do
			put_string (print_qualified_class_name_to_string (a_class))
		end

	print_qualified_class_name_to_string (a_class: ET_CLASS): STRING is
			-- Print qualified class name of 'a_class' to string.
		do
			Result := print_qualified_cluster_name_to_string (a_class.group.cluster, True)+"."+print_class_name_to_string (a_class)
		end

	print_header_start is
			-- Start with the header.
			-- Call `print_header_end' to finish the header.
		do
			start_tag ("header")
			if Options.home_url /= Void and then Options.home_url.count > 0 then
				tag_attributes_content ("title", << "url", options.home_url>>, options.short_title)
			else
				tag_content ("title", options.short_title)
			end
			print_buttons
		end

	print_header_end is
			-- ends the header.
		do
			end_tag -- header
		end


	print_footer_start is
			-- Start with the footer.
			-- Call `print_footer_end' to finish the footer.
		local
			title: STRING
		do
			if Options.home_url /= Void and then Options.home_url.count > 0 then
				title := link_content_to_string (Options.home_url, Options.short_title)
			else
				title := Options.short_title
			end
			start_tag ("footer")
			if Options.is_edoc_notice_printed then
				link_content (Options.edoc_website_link, "Documentation generated by edoc")
			end

			if Options.version /= Void and then Options.version.count > 0 then
				tag_content ("version", title+" "+Options.version)
			else
				tag_content ("footer_title", title)
			end
		end

	print_footer_end is
			-- End the footer.
			-- Call `print_footer_start' before.
		do
			end_tag
		end

	print_buttons is
			-- Print buttons.
		do
			start_tag ("button_list")
			if Options.is_overview_generated then
				print_button ("Overview", xml_context.overview_page_link)
			end
			if Options.is_clusters_file_generated then
				print_button ("Clusters", xml_context.clusters_page_link)
			end
			if Options.is_classes_file_generated then
				print_button ("Classes", xml_context.classes_page_link)
			end
			if Options.are_cluster_files_generated then
				print_button ("Cluster", xml_context.cluster_page_link)
			end
			print_button ("Class", xml_context.class_page_link)
			if Options.are_usage_files_generated then
				print_button ("Usage", xml_context.usage_page_link)
			end
			if Options.is_index_generated then
				print_button ("Index", xml_context.index_page_link)
			end
			start_tag_attributes ("button", << "url", "#top" >>)
				content_line ("Top")
			end_tag
			if Options.is_feature_list_generated and then xml_context.class_page_link /= Void and then xml_context.class_page_link.is_equal (xml_context.Active_page_link) then
				start_tag_attributes ("button", << "url", "#features-list" >>)
					content_line ("Features")
				end_tag
			end
			end_tag
		end

	print_button (a_title, a_link: STRING) is
			-- Print button.
		require
			a_title_not_void: a_title /= Void
		do
			if a_link = Void then
				tag_content ("inactive_button", a_title)
			elseif a_link.is_equal (xml_context.Active_page_link) then
				tag_content ("active_button", a_title)
			else
				start_tag_attributes ("button", << "url", a_link >>)
					content_line (a_title)
				end_tag
			end
		end

	print_subclusters_tree (a_cluster: ET_CLUSTER) is
			-- Print tree of subclusters of 'a_cluster'.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			cluster_cursor: DS_LIST_CURSOR [ET_CLUSTER]
			a_item: ET_CLUSTER
		do
			if a_cluster.subclusters /= Void then
				Cluster_sorter.sort (a_cluster.subclusters.clusters)
				cluster_cursor := a_cluster.subclusters.clusters.new_cursor
				from
					cluster_cursor.start
				until
					cluster_cursor.after
				loop
					a_item := cluster_cursor.item
					if Context.documented_clusters.has (a_item) then
						start_tag ("listitem")
						start_tag ("cluster_qualified_name")
						print_qualified_cluster_name_single_link (a_item)
						end_tag -- cluster_qualified_name
						end_tag -- listitem
						print_subclusters_tree (a_item)
					end
					cluster_cursor.forth
				end
			end
		end

	print_comment (a_string: STRING; a_class: ET_CLASS; a_features_list: DS_LIST [ET_FEATURE]; add_breaks: BOOLEAN) is
			-- Print `a_string' as comment.
			-- Set links to features listed in `a_features_list'.
			-- When called from the class printer provide `a_class' as current class.
		require
			a_string_not_void: a_string /= Void
			a_features_list_not_void: a_features_list /= Void
		local
--			lines: DS_LIST [STRING]
--			splitter: ST_SPLITTER
--			processed_line: STRING
--			printed_empty_line: BOOLEAN
			a_comment: STRING
		do
			a_comment := a_string.twin
			replace_features_in_comment (a_comment, a_class, a_features_list)
			replace_classes_in_comment (a_comment)

--			start_tag ("comment")
--			content_line (a_comment)
--			end_tag
			tag_content ("comment", a_comment)


--			create splitter.make
--			splitter.set_separators ("%R%N")

--			start_tag ("comment")
--			lines := splitter.split_greedy (a_string)
--			from
--				lines.start
--			until
--				lines.after
--			loop
--				processed_line := lines.item_for_iteration
--				STRING_.left_adjust (processed_line)
--				STRING_.right_adjust (processed_line)

--				lines.forth

--				if processed_line.is_empty then
--					if not printed_empty_line then
--						end_tag
--						start_tag ("comment")
--						printed_empty_line := True
--					end
--				else
--					printed_empty_line := False
--					replace_features_in_comment (processed_line, a_class, a_features_list)
--					replace_classes_in_comment (processed_line)

--					content_line (processed_line)
----					if lines.after or not add_breaks then
----						content_line (processed_line)
----					else
----						content_line (processed_line+"<br/>")
----					end
--				end
--			end
--			end_tag -- comment
		end

feature {NONE} -- Implementation

	replace_features_in_comment (a_string: STRING; a_class: ET_CLASS; a_features_list: DS_LIST [ET_FEATURE]) is
			-- Replace features in `a_string' with links.
		require
			a_string_not_void: a_string /= Void
			a_features_list_not_void: a_features_list /= Void
		local
			i, j: INTEGER
			a_feature: ET_FEATURE
			substring, replacement, a_link: STRING
		do
			from  i := 1; j := 1 until i = 0 or j = 0 	loop
				i := a_string.index_of ('`', j)
				j := a_string.index_of ('%'', i+1)
				if i > 0 and j > 0 then
					substring := a_string.substring (i+1, j-1)
					if a_class /= Void then
						a_feature := a_class.named_feature (create {ET_IDENTIFIER}.make (substring))
					end
					if a_feature /= Void and then a_features_list.has (a_feature) then
						a_link := xml_context.feature_link_by_feature (a_feature, Void)
						if a_link /= Void then
							replacement := link_content_to_string (a_link, substring)
						else
							replacement := tag_content_to_string ("feature", substring)
						end
					else
						replacement := tag_content_to_string ("feature", substring)
					end
					a_string.replace_substring (replacement, i, j)
					j := j + replacement.count - substring.count - 2
				end
			end
		end

	replace_classes_in_comment (a_string: STRING) is
			-- Replace classes in `a_string' with links.
		require
			a_string_not_void: a_string /= Void
		local
			i, j: INTEGER
			in_word: BOOLEAN
			substring, replacement: STRING
			a_class: ET_CLASS
		do
			j := 0
			from i := 1 until i > a_string.count loop
				if is_valid_word_character (a_string.item (i)) then
					if not in_word then
						in_word := True
						j := i
					end
				else
					if in_word then
						in_word := False
						substring := a_string.substring (j, i-1)
						if is_valid_classname (substring) then
							a_class := Context.universe.class_by_name (substring)
							if a_class /= Void then
								replacement := print_class_name_to_string (a_class)
								a_string.replace_substring (replacement, j, i-1)
								i := i + replacement.count - substring.count
							end
						end
					end
				end
				i := i + 1
			end
			if in_word then
				substring := a_string.substring (j, i-1)
				if is_valid_classname (substring) then
					a_class := Context.universe.class_by_name (substring)
					if a_class /= Void then
						replacement := print_class_name_to_string (a_class)
						a_string.replace_substring (replacement, j, i-1)
						i := i + replacement.count - substring.count
					end
				end
			end
		end

	is_valid_word_character (a_character: CHARACTER): BOOLEAN is
			-- Is `a_character' a valid classname character?
		do
			Result := (a_character >= '0' and a_character <= '9') or a_character.is_upper or a_character.is_lower or a_character = '_'
		end

	is_valid_classname (a_string: STRING): BOOLEAN is
			-- Is `a_string' a valid classname to be replaced?
		require
			a_string_not_void: a_string /= Void
		local
			i, nb: INTEGER
		do
			Result := True
			nb := a_string.count
			from i := 1 until i > nb or not Result loop
				if a_string.item (i).is_lower then
					Result := False
				end
				i := i + 1
			end
		end

	attributes_string (a_attributes: ARRAY [STRING]): STRING is
			-- Start new tag `a_tag' with attributes `a_attributes'.
		require
			a_attributes_not_void: a_attributes /= Void
		local
			attribute_name, attribute_value: STRING
			i: INTEGER
		do
			create Result.make_empty
			from
				i := 1
			variant
				a_attributes.count + 1 - i
			until
				i > a_attributes.count
			loop
				attribute_name := a_attributes.item (i)
				attribute_value := a_attributes.item (i+1)
				Result := STRING_.concat (Result, " "+attribute_name+"=%""+attribute_value+"%"")
				i := i + 2
			end
		end

	print_whole_file(a_filename: STRING) is
			-- Prints all content from `a_filename' to the output file.
		require
			a_string_not_void: a_filename /= Void
		local
			in_file: KI_TEXT_INPUT_FILE
		do
			if file_system.file_exists (a_filename) then
				-- read file
				in_file := file_system.new_input_file (a_filename)

				from in_file.open_read
				until in_file.end_of_file
				loop
					in_file.read_line
					put_line (in_file.last_string)
				end
				in_file.close
			else
				Error_handler.raise_warning (Error_handler.error_file_not_found, << a_filename >>)
			end
		end

invariant

	name_not_void: name /= Void
	open_tags_not_void: open_tags /= Void

end

indexing

	description:

		"Generate an XML file of an Eiffel class"

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_CLASS_FILE

inherit

	EDOC_XML_OUTPUT_FILE

create

	make

feature -- Access

	et_class: et_class
			-- Class

feature -- Element change

	set_class (a_class: ET_CLASS) is
			-- Set `et_class' to `a_class'.
		require
			a_class_not_void: a_class /= Void
		do
			et_class := a_class
		ensure
			class_set: et_class = a_class
		end

feature -- Basic operations

	generate is
			-- Generate class file for `et_class'.
		local
			a_class_name_list: DS_LIST [ET_CLASS_NAME]
			an_ast_printer: EDOC_XML_AST_PRINTER
		do
			open_write

			print_xml_head (et_class.name.name, xml_context.relative_xsd_link)

			print_header_start
			print_header_end

			content_line (print_qualified_cluster_name_to_string (et_class.group.cluster, True))

			tag_content ("title", "Class " + et_class.name.name)


			if Options.is_ancestors_list_generated then
				a_class_name_list := ancestors_list (et_class)
				if not a_class_name_list.is_empty then
					start_tag ("ancestors")
					tag_content ("title", "Direct ancestors")
					print_class_list (a_class_name_list)
					end_tag -- ancestors
				end
			end
			if Options.is_descendants_list_generated then
				a_class_name_list := descendants_list
				if not a_class_name_list.is_empty then
					start_tag ("descendants")
					tag_content ("title", "Known direct descendants")
					print_class_list (a_class_name_list)
					end_tag -- descendants	
				end
			end

			create an_ast_printer.make (Context.universe)
			an_ast_printer.set_file (Current)

			start_tag ("class_body")
			an_ast_printer.process_class (et_class)
			end_tag -- class_body

			print_footer_start
			print_buttons
			print_footer_end

			print_xml_footer
			close
		end

feature {NONE} -- Implementation

	print_class_list (a_list: DS_LIST [ET_CLASS_NAME]) is
			-- Print `a_list' of classes.
		local
			cursor: DS_LIST_CURSOR [ET_CLASS_NAME]
			a_class: ET_CLASS
		do
--			Class_sorter.sort (a_list)
			start_tag ("classlist")
			indent
			from
				cursor := a_list.new_cursor
				cursor.start
			until
				cursor.after
			loop
				a_class := Context.universe.class_by_name (cursor.item.name)
				if a_class /= Void then
					put_string (print_class_name_to_string (a_class))
				else
					put_string (tag_content_to_string ("class", cursor.item.name))
				end
				cursor.forth
				if not cursor.after then
					put_string ("%N")
					indent
				end
			end
			put_string ("%N")
			end_tag -- classlist
		end

	ancestors_list (a_class: ET_CLASS): DS_LINKED_LIST [ET_CLASS_NAME] is
			-- List of ancestors of `a_class'
		local
			i: INTEGER
			class_name: ET_CLASS_NAME
		do
			create Result.make
			if a_class.parents /= Void then
				from i := 1 until i > a_class.parents.count loop
					class_name := a_class.parents.item (i).parent.type.name
					if not Options.ignored_inherit_classes.has (class_name.name) then
						Result.force_last (class_name)
					end
					i := i + 1
				end
			end
		end

	descendants_list: DS_LINKED_LIST [ET_CLASS_NAME] is
			-- List of direct descendants of `et_class'
		local
			class_cursor: DS_HASH_TABLE_CURSOR [ET_MASTER_CLASS, ET_CLASS_NAME]
			l_master_class: ET_MASTER_CLASS
			ancestors_cursor: DS_LIST_CURSOR [ET_CLASS_NAME]
			ancestor_found: BOOLEAN
		do
			create Result.make
			class_cursor := Context.universe.master_classes.new_cursor
			from
				class_cursor.start
			until
				class_cursor.after
			loop
				l_master_class := class_cursor.item
				if not l_master_class.is_mapped then
					ancestors_cursor := ancestors_list (l_master_class.actual_class).new_cursor
					from
						ancestor_found := False
						ancestors_cursor.start
					until
						ancestors_cursor.after or ancestor_found
					loop
						if ancestors_cursor.item.same_class_name (et_class.name) then
							Result.force_last (class_cursor.key)
							ancestor_found := True
						end
						ancestors_cursor.forth
					end
				end
				class_cursor.forth
			end
		end

end

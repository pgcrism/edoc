indexing

	description:

		"Generate an XML File for a list of all classes in the context."

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_CLASSES_FILE

inherit

	EDOC_XML_OUTPUT_FILE

create

	make

feature -- Basic operations

	generate is
			-- Generate classes file.
		local
			a_class: ET_CLASS
			a_class_cursor: DS_LIST_CURSOR [ET_CLASS]
			a_line: STRING
		do
			open_write

			print_xml_head ("Classes", xml_context.relative_xsd_link)

			print_header_start
			print_header_end

			tag_content ("title", "Classes")

			start_tag ("itemizedlist")
			a_class_cursor := Context.documented_classes.new_cursor
			from
				a_class_cursor.start
			until
				a_class_cursor.after
			loop
				a_class := a_class_cursor.item
				start_tag ("listitem")
				start_tag ("para")
						a_line := print_class_name_to_string (a_class)
						a_line.append_string (tag_content_to_string ("cluster_description", " - Class in "+print_qualified_cluster_name_to_string (a_class.group.cluster, True)))
						content_line (a_line)
				end_tag -- para
				end_tag -- listitem
				a_class_cursor.forth
			end
			end_tag

			print_footer_start
			print_buttons
			print_footer_end

			print_xml_footer
			close
		end

end
